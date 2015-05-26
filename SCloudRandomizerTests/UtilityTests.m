//
//  SCloudRandomizerTests.m
//  SCloudRandomizerTests
//
//  Created by Akshay Bharath on 12/3/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Utility.h"

@interface UtilityTests : XCTestCase

@end

@implementation UtilityTests

- (BOOL) formatDuration:(NSString *)expectedFormat durationInMilliseconds:(long) durationInMilliseconds {
    NSString *actualFormat = [Utility formatDuration:durationInMilliseconds];
    return [actualFormat isEqualToString:expectedFormat];
}

- (void) testFormatDurationWithValidDuation {
    
    XCTAssertEqual(true, [self formatDuration:@"3:00" durationInMilliseconds:180000]);
    XCTAssertEqual(true, [self formatDuration:@"5:37" durationInMilliseconds:337000]);
    XCTAssertEqual(true, [self formatDuration:@"0:48" durationInMilliseconds:48000]);
    XCTAssertEqual(true, [self formatDuration:@"0:01" durationInMilliseconds:1000]);
    XCTAssertEqual(true, [self formatDuration:@"0:00" durationInMilliseconds:0]);
    XCTAssertEqual(true, [self formatDuration:@"0:00" durationInMilliseconds:-5]);
}

- (void) teststringIsNilOrEmpty {
    
    XCTAssertEqual(true, [Utility stringIsNilOrEmpty:@""]);
    XCTAssertEqual(true, [Utility stringIsNilOrEmpty:nil]);
    XCTAssertEqual(false, [Utility stringIsNilOrEmpty:@"foo"]);
    XCTAssertEqual(false, [Utility stringIsNilOrEmpty:@" "]);
}


@end
