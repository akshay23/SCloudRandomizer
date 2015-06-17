//
//  Utility.h
//  SCloudRandomizer
//
//  Created by Asha Balasubramaniam on 4/30/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

@class SearchParams;
@class MMWormhole;

@interface Utility : NSObject

+ (NSString *)formatDuration:(long)durationInMilliseconds;
+ (dispatch_queue_t)getGlobalBackgroundQueue;
+ (dispatch_queue_t)getMainQueue;
+ (BOOL)stringIsNilOrEmpty:(NSString*)aString;
+ (void)saveSearchParams:(SearchParams *)object key:(NSString *)key;
+ (SearchParams *)loadSearchParamsWithKey:(NSString *)key;

@end
