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

@interface MusicSource: NSObject

typedef void(^tracksFetchedCompletionHandler)(NSArray* tracks);
typedef void(^singleTrackFetchedCompletionHandler)(Track* track);

+ (MusicSource *) getInstance;
- (BOOL)isUserLoggedIn;
- (void)getRandomTrack:(SearchParams *)searchParams completionHandler:(singleTrackFetchedCompletionHandler)completionHandler;
- (void)logout;
- (void)updateLikeState:(BOOL)isSongLiked trackId:(NSString*)trackIdToUpdate;

@end