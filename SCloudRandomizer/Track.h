//
//  Track.h
//  SCloudRandomizer
//
//  Created by Asha Balasubramaniam on 4/29/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

@class SCAccount;
@class SCAudioStream;

@interface Track : NSObject

@property (nonatomic) NSNumber *Id;
@property (nonatomic) NSString *streamUrl;
@property (nonatomic) NSNumber *isLiked;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *artist;
@property (nonatomic) long duration;
@property (nonatomic) NSURL *albumArtUrl;
@property (nonatomic) SCAccount *account;
@property (nonatomic) long likes;
@property (nonatomic) long plays;
@property (nonatomic) NSString *uploadedOn;
@property (nonatomic) NSString *songDescription;
@property (nonatomic) NSString *tags;
@property (nonatomic) NSInteger bpm;

typedef void(^trackDownloaded)(SCAudioStream *scAudio);

- (id)initWithData:(NSDictionary*)data account:(SCAccount *) account;
- (void) download:(trackDownloaded)completionHandler;

@end
