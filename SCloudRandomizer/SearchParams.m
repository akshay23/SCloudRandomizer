//
//  SearchParams.m
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 1/12/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import "SearchParams.h"
#import "GlobalData.h"

@implementation SearchParams

- (id)initWithBool:(BOOL)changed keywords:(NSString *)theKeywords
{
    self.hasChanged = changed;
    self.keywords = theKeywords;
    self.lowBpm = -1;
    self.highBpm = -1;
    self.durationFrom = -1;
    self.durationTo = -1;
    
    return self;
}

@end
