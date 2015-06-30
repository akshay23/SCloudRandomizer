//
//  GlobalData.m
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 1/12/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import "GlobalData.h"

@implementation GlobalData

@synthesize mainStoryboard;
@synthesize wormhole;

static GlobalData *instance;

+ (GlobalData *)getInstance {
    @synchronized(self) {
        if (instance==nil) {
            instance= [GlobalData new];
        }
    }
    return instance;
}

@end
