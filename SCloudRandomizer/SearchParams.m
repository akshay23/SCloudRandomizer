//
//  SearchParams.m
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 1/12/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import "SearchParams.h"

@implementation SearchParams

- (id)initWithBool:(BOOL)changed
{
    self.hasParamsChanged = changed;
    
    return self;
}

@end
