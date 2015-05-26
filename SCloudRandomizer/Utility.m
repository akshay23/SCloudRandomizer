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

+ (NSString *)formatDuration:(long)durationInMilliseconds {
    NSInteger minutes = floor(durationInMilliseconds / 60000);
    NSInteger seconds = ((durationInMilliseconds % 60000) / 1000);
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

+ (void)saveSearchParams:(SearchParams *)object key:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
}

+ (SearchParams *)loadSearchParamsWithKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    SearchParams *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}

@end
