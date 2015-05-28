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

// This tests the MusicSource::getRandomTrack by mocking
// out the Soundcloud data using OCMock
- (void) testgettingRandomTracks {
    
    // Partially mock out MusicSource since we want to test
    // one of its methods but mock out the ones that use Soundcloud
    // API's
    MusicSource *musicSource = [MusicSource getInstance];
    id partialMusicSourceMock = OCMPartialMock(musicSource);

    NSString *keyword = @"test";
    SearchParams *searchParams = [[SearchParams alloc]
                                  initWithBool:YES
                                  keywords:keyword];
    
    // Since getRandomTrack is an async method that invokes a completion handler,
    // create a stubbed block that will be invoked using OCMock's andDo method
    void (^stubbedResponseHandler)(NSInvocation *) = ^(NSInvocation *invocation) {
        NSString *mockedResponse = @"[{ \"id\": 13158665, \"stream_url\": \"http://foo.com\" }]";
        NSData *jsonData = [mockedResponse dataUsingEncoding:NSUTF8StringEncoding];
        
        // NOTE: Reason being [invocation getArgument] expects
        // a (void*) pointer and so ARC does not retain the reference for
        // responseHandler. Since we don't want a corresponding
        // release, adding __unsafe_unretained to avoid a over release
        // Source: http://stackoverflow.com/questions/13268502/exc-bad-access-when-accessing-parameters-in-anddo-of-ocmock
        __unsafe_unretained SCRequestResponseHandler responseHandler;
        
        [invocation getArgument:&responseHandler atIndex:7];
        
        responseHandler(nil, jsonData, nil);
    };
    
    // Stub out fetchTracks and invoke the stubbed response
    // block when the test eventually gets to this method
    
    OCMStub([partialMusicSourceMock fetchTracks:SCRequestMethodGET
                                onResource:[OCMArg any]
                           usingParameters:[OCMArg any]
                               withAccount:[OCMArg any]
                    sendingProgressHandler:[OCMArg any]
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
