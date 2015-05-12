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

- (BOOL)isUserLoggedIn {
    return [SCSoundCloud account];
}

- (void)getRandomTrack:(SearchParams *)searchParams completionHandler:(singleTrackFetchedCompletionHandler)completionHandler {
    [self getTracks:searchParams completionHandler:^(NSArray* tracks) {
        int randomSongIndex = arc4random_uniform((uint32_t) tracks.count);
        Track* track = [[Track alloc] initWithData:[tracks objectAtIndex:randomSongIndex] account:[SCSoundCloud account]];
        completionHandler(track);
    }];
}

- (void)getTracks:(SearchParams *)searchParams completionHandler:(tracksFetchedCompletionHandler)completionHandler {
    SCRequestResponseHandler responseHandler =
    ^(NSURLResponse *response, NSData *data, NSError *error)
    {
        NSError *jsonError = nil;
        NSArray* tracks = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
            tracks = (NSArray *)jsonResponse;
            NSLog(@"Tracks acquired.");
        }
        else
        {
            NSLog(@"Could not get tracks.");
        }
        
        completionHandler(tracks);
    };
    
    // Replace spaces with '%20' and then replace commas with '%2C'
    NSString *cleanedKeywords = [[searchParams.keywords stringByReplacingOccurrencesOfString:@" " withString:@"%20"] stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    NSString *resourceURL = [NSString stringWithFormat:@"https://api.soundcloud.com/tracks?format=json&q=%@", cleanedKeywords];
    NSLog(@"The resourceURL is %@", resourceURL);
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:nil
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:nil
             responseHandler:responseHandler];
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

@end