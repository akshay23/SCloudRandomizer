//
//  Utility.m
//  SCloudRandomizer
//
//  Created by Asha Balasubramaniam on 4/30/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"

@implementation Utility

+ (NSString *)convertFromMilliseconds:(long)duration {
    NSInteger minutes = floor(duration / 60000);
    NSInteger seconds = ((duration % 60000) / 1000);
    NSString *formatted = nil;
    if (seconds < 10) {
        formatted = [NSString stringWithFormat:@"%ld:0%ld", (long)minutes, (long)seconds];
    }
    else {
        formatted = [NSString stringWithFormat:@"%ld:%ld", (long)minutes, (long)seconds];
    }
    
    return formatted;
}

+ (dispatch_queue_t)getGlobalBackgroundQueue {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
}

+ (dispatch_queue_t)getMainQueue {
    return dispatch_get_main_queue();
}

+ (BOOL)stringIsNilOrEmpty:(NSString*)aString {
    return !(aString && aString.length);
}

@end
