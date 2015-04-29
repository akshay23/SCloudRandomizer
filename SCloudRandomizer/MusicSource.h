//
//  MusicSource.h
//  SCloudRandomizer
//
//  Created by Asha Balasubramaniam on 4/29/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicSource: NSObject

+ (MusicSource*) getInstance;
- (BOOL)isUserLoggedIn;
- (void)getTracks:(BOOL)shouldGetTrackInfo shouldPlay:(BOOL)playBool;
- (void)getTrackInfo:(NSDictionary *)track shouldPlay:(BOOL)play;
- (void)logout;
- (void)updateLikedState:(BOOL)isSongLiked trackId:(NSString*)trackIdToUpdate;

@end
