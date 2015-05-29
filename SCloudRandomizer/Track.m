//
//  Track.m
//  SCloudRandomizer
//
//  Created by Asha Balasubramaniam on 4/29/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SCAPI.h>
#import "SCAudioStream.h"
#import "Track.h"

@implementation Track : NSObject

-(id)initWithData:(NSDictionary *)data account:(SCAccount *)account {
    self.Id = [data objectForKey:@"id"];
    self.title = [data objectForKey:@"title"];
    self.artist = [[data objectForKey:@"user"] objectForKey:@"username"];
    self.duration = [[data objectForKey:@"duration"] longValue];
    
    NSString *albumArtUrlString = nil;
    id albumArt = [data objectForKey:@"artwork_url"];
    if (albumArt == [NSNull null]) {
        albumArtUrlString = [[[data objectForKey:@"user"] objectForKey:@"avatar_url"] stringByReplacingOccurrencesOfString:@"-large" withString:@"-t300x300"];
    }
    else {
        albumArtUrlString = [(NSString *)albumArt stringByReplacingOccurrencesOfString:@"-large" withString:@"-t300x300"];
    }
    self.albumArtUrl = [NSURL URLWithString:albumArtUrlString];
    
    self.streamUrl = [data objectForKey:@"stream_url"];
    
    // ToDo - Figure out when this happens and fix
    if (self.streamUrl == nil) {
        NSException* noStreamUrlException = [NSException
                                    exceptionWithName:@"No Stream Url associated with track"
                                    reason:@"Stream Url not Found on System"
                                    userInfo:nil];
        @throw noStreamUrlException;
    }
    
    self.account = account;
    
    self.isLiked = [data objectForKey:@"user_favorite"];
    
    self.likes = [[data objectForKey:@"favoritings_count"] longValue];
    
    self.plays = [[data objectForKey:@"playback_count"] longValue];
    
    self.uploadedOn = [data objectForKey:@"created_at"];
    
    self.songDescription = [data objectForKey:@"description"];
    
    self.bpm = ([data objectForKey:@"bpm"] == [NSNull null]) ? 0 : [[data objectForKey:@"bpm"] integerValue];
    
    return self;
}

-(SCAudioStream *)getStream {
    SCAudioStream *scAudio = [[SCAudioStream alloc] initWithURL:[NSURL URLWithString:self.streamUrl] authentication:self.account];
    return scAudio;
}

@end