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

static MusicSource *instance;

@interface MusicSource ()

@end


@implementation MusicSource : NSObject

+ (MusicSource*) getInstance
{
    if (instance == nil) {
        instance = [[MusicSource alloc] init];
    }
    
    return instance;
}

- (BOOL) isUserLoggedIn
{
    return [SCSoundCloud account];
}

- (void)getTracks:(BOOL)shouldGetTrackInfo shouldPlay:(BOOL)playBool
{
    
}

- (void)getTrackInfo:(NSDictionary *)track shouldPlay:(BOOL)play
{
    
}

- (void)logout
{
    [SCSoundCloud removeAccess];
}

- (void) updateLikedState:(BOOL)isSongLiked trackId:(NSString *)trackIdToUpdate
{
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