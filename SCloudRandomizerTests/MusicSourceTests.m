//
//  MusicSourceTests.m
//  SCloudRandomizer
//
//  Created by Asha Balasubramaniam on 5/14/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <SCRequest.h>
#import <SCSoundCloud.h>
#import <SCAccount.h>

#import "MusicSource.h"
#import "SearchParams.h"
#import "Track.h"

@interface MusicSourceTests : XCTestCase

@end

@implementation MusicSourceTests

- (void) testgettingRandomTracks {
    
    MusicSource *musicSource = [MusicSource getInstance];
    id partialMusicSourceMock = OCMPartialMock(musicSource);
    
    id mockedSCAccount = OCMClassMock([SCAccount class]);
    
    OCMStub([partialMusicSourceMock account]).andReturn(mockedSCAccount);
    
    NSString *keyword = @"test";
    SearchParams *searchParams = [[SearchParams alloc]
                                  initWithBool:YES
                                  keywords:keyword
                                  lowBpm:[NSNumber numberWithInt:10]
                                  highBpm:[NSNumber numberWithInt:30]];
    
    void (^stubbedResponseHandler)(NSInvocation *) = ^(NSInvocation *invocation) {
        NSString *mockedResponse = @"[{ \"id\": 13158665, \"stream_url\": \"http://foo.com\" }]";
        NSData *jsonData = [mockedResponse dataUsingEncoding:NSUTF8StringEncoding];
        
        void (^responseHandler)(NSURLResponse *response, NSData *responseData, NSError *error);
        
        [invocation getArgument:&responseHandler atIndex:7];
        
        responseHandler(nil, jsonData, nil);
    };
    
    NSString *resourceURL = [NSString stringWithFormat:@"https://api.soundcloud.com/tracks?format=json&q=%@", keyword];
    OCMStub([partialMusicSourceMock fetchTracks:SCRequestMethodGET
                                onResource:[NSURL URLWithString:resourceURL]
                           usingParameters:nil
                               withAccount:mockedSCAccount
                    sendingProgressHandler:nil
                           responseHandler:[OCMArg any]]).andDo(stubbedResponseHandler);
    

    XCTestExpectation *randomTrack1FetchExpectation = [self expectationWithDescription:@"Random track 1 fetched"];
   [musicSource getRandomTrack:searchParams
             completionHandler:^(Track *track) {
                 XCTAssert(track != nil);
                 XCTAssertEqual(13158665, [track.Id intValue]);
                 [randomTrack1FetchExpectation fulfill];
             }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];

}

@end
