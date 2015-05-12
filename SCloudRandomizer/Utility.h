//
//  Utility.h
//  SCloudRandomizer
//
//  Created by Asha Balasubramaniam on 4/30/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

@interface Utility : NSObject

+ (NSString *)convertFromMilliseconds:(long)duration;
+ (dispatch_queue_t)getGlobalBackgroundQueue;
+ (dispatch_queue_t)getMainQueue;
+ (BOOL)stringIsNilOrEmpty:(NSString*)aString;

@end
