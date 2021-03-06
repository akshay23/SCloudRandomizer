//
//  MusicSource.h
//  SCloudRandomizer
//
//  Created by Asha Balasubramaniam on 4/29/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Track;
@class SearchParams;
@class SCRequest;

@interface MusicSource: NSObject

enum MusicSourceError {
    None,
    ZeroData,
    NoConnection,
    TrackError,
    DeserializationError
};

typedef void(^tracksFetchedCompletionHandler)(NSArray* tracks, enum MusicSourceError error);
typedef void(^singleTrackFetchedCompletionHandler)(Track* track, enum MusicSourceError error);

+ (MusicSource *) getInstance;

- (SCAccount*) isUserLoggedIn;
- (void) getRandomTrack:(SearchParams *)searchParams completionHandler:(singleTrackFetchedCompletionHandler)completionHandler;
- (void) logout;
- (void) updateLikeState:(BOOL)isSongLiked trackId:(NSString*)trackIdToUpdate;
- (NSURL *)generateResourceURL:(SearchParams *)params;

+ (SCAccount*) account;

+ (void) fetchTracks:(SCRequestMethod)aMethod
                        onResource:(NSURL *)aResource
                        usingParameters:(NSDictionary *)someParameters
                        withAccount:(SCAccount *)anAccount
                        sendingProgressHandler:(SCRequestSendingProgressHandler)aProgressHandler
                        responseHandler:(SCRequestResponseHandler)aResponseHandler;

@end
