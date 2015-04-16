//
//  SearchParams.m
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 1/12/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import "SearchParams.h"

@implementation SearchParams

- (id)initWithBool:(BOOL)changed keywords:(NSString *)theKeywords lowBpm:(NSNumber *)lBpm highBpm:(NSNumber *)hBpm
{
    self.hasParamsChanged = changed;
    self.keywords = theKeywords;
    self.lowBpm = lBpm;
    self.highBpm = hBpm;
    
    return self;
}

@end
