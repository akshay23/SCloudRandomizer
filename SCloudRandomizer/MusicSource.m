//
//  MusicSource.m
//  SCloudRandomizer
//
//  Created by Asha Balasubramaniam on 4/29/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <SCSoundCloud.h>
#import <SCRequest.h>
#import <Reachability.h>

#import "MusicSource.h"
#import "Track.h"
#import "SearchParams.h"

static MusicSource *instance;

@interface MusicSource ()

@end

@implementation MusicSource : NSObject

+ (MusicSource*)getInstance {
    @synchronized(self)
    {
        if (instance == nil) {
            instance = [[MusicSource alloc] init];
        }
    }
    
    return instance;
}

- (SCAccount *)isUserLoggedIn {
    return [SCSoundCloud account];
}

- (void)getRandomTrack:(SearchParams *)searchParams completionHandler:(singleTrackFetchedCompletionHandler)completionHandler {
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There is no internet connection");
        completionHandler(nil, NoConnection);
    } else {
        [self getTracks:searchParams completionHandler:^(NSArray* tracks, enum MusicSourceError error) {
            if (error != None) {
                completionHandler(nil, error);
            } else {
                int randomSongIndex = arc4random_uniform((uint32_t) tracks.count);
                @try {
                    Track* track = [[Track alloc] initWithData:[tracks objectAtIndex:randomSongIndex] account:[MusicSource account]];
                    completionHandler(track, None);
                }
                @catch (NSException * e) {
                    NSLog(@"Exception: %@", e);
                    completionHandler(nil, TrackError);
                }
            }
        }];
    }
}

- (void)getTracks:(SearchParams *)searchParams completionHandler:(tracksFetchedCompletionHandler)completionHandler {
    SCRequestResponseHandler responseHandler =
    ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSArray* tracks = nil;
        if (data != nil) {
            NSJSONSerialization *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
                tracks = (NSArray *)jsonResponse;
                
                if (tracks.count > 0) {
                    NSLog(@"Tracks acquired.");
                    completionHandler(tracks, None);
                } else {
                    NSLog(@"No tracks acquired");
                    completionHandler(tracks, ZeroData);
                }
            }
            else {
                NSLog(@"Error deserializing tracks");
                completionHandler(tracks, DeserializationError);
            }
        } else {
            NSLog(@"Error fetching tracks");
            completionHandler(tracks, NoConnection);
        }
    };
    

    [MusicSource fetchTracks:SCRequestMethodGET
                  onResource:[self generateResourceURL:searchParams]
             usingParameters:nil
                 withAccount:[MusicSource account]
      sendingProgressHandler:nil
             responseHandler:responseHandler];
}

- (NSURL *)generateResourceURL:(SearchParams *)params {
    NSString *fromBpm = @"";
    if (params.lowBpm > 0) {
        fromBpm = [NSString stringWithFormat:@"&bpm[from]=%ld", (long)params.lowBpm];
    }
    
    NSString *toBpm = @"";
    if (params.highBpm > 0) {
        toBpm = [NSString stringWithFormat:@"&bpm[to]=%ld", (long)params.highBpm];
    }
    
    NSString *durationFrom = @"";
    if (params.durationFrom > 0) {
        durationFrom = [NSString stringWithFormat:@"&duration[from]=%ld", (long)(params.durationFrom * 60000)];
    }
    
    NSString *durationTo = @"";
    if (params.durationTo > 0) {
        durationTo = [NSString stringWithFormat:@"&duration[to]=%ld", (long)(params.durationTo * 60000)];
    }
    
    // Replace spaces with '%20' and then replace commas with '%2C' in the keywords
    // then create the resourceURL using the keywords and bpm
    NSString *cleanedKeywords = [[params.keywords stringByReplacingOccurrencesOfString:@" " withString:@"%20"] stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    
    NSString *resourceURL = [NSString stringWithFormat:@"https://api.soundcloud.com/tracks?format=json&limit=200&filter=all&q=%@%@%@%@%@", cleanedKeywords, fromBpm, toBpm, durationFrom, durationTo];
    NSLog(@"The resourceURL is %@", resourceURL);
    
    return [NSURL URLWithString:resourceURL];
}

- (void)logout {
    [SCSoundCloud removeAccess];
}

- (void)updateLikeState:(BOOL)isSongLiked trackId:(NSString *)trackIdToUpdate {
    NSString *resourceURL = @"https://api.soundcloud.com/me/favorites/";
    NSURL *postURL = [NSURL URLWithString:[resourceURL stringByAppendingString: trackIdToUpdate]];
    
    SCRequestMethod requestMethod;
    
    if (isSongLiked) {
        requestMethod = SCRequestMethodPUT;
    } else {
        requestMethod = SCRequestMethodDELETE;
    }
    
    [SCRequest performMethod:requestMethod
            onResource:postURL
            usingParameters:nil
            withAccount:[SCSoundCloud account]
            sendingProgressHandler:nil
            responseHandler:nil];
}

+ (void) fetchTracks:(SCRequestMethod)aMethod
                        onResource:(NSURL *)aResource
                        usingParameters:(NSDictionary *)someParameters
                        withAccount:(SCAccount *)anAccount
                        sendingProgressHandler:(SCRequestSendingProgressHandler)aProgressHandler
     responseHandler:(SCRequestResponseHandler)aResponseHandler {
    
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:aResource
             usingParameters:someParameters
                 withAccount:anAccount
      sendingProgressHandler:aProgressHandler
             responseHandler:aResponseHandler];
}

+ (SCAccount*) account {
    return [SCSoundCloud account];
}

@end