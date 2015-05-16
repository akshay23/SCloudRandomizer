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

- (id)initWithBool:(BOOL)changed keywords:(NSString *)theKeywords {
    if (self = [super init]) {
        self.hasChanged = changed;
        self.keywords = theKeywords;
        self.lowBpm = 0;
        self.highBpm = 0;
        self.durationFrom = 0;
        self.durationTo = 0;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.hasChanged = [aDecoder decodeBoolForKey:@"hasChanged"];
        self.keywords = [aDecoder decodeObjectForKey:@"keywords"];
        self.lowBpm = [aDecoder decodeIntegerForKey:@"lowBpm"];
        self.highBpm = [aDecoder decodeIntegerForKey:@"highBpm"];
        self.durationFrom = [aDecoder decodeIntegerForKey:@"durationFrom"];
        self.durationTo = [aDecoder decodeIntegerForKey:@"durationTo"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:self.hasChanged forKey:@"hasChanged"];
    [aCoder encodeObject:self.keywords forKey:@"keywords"];
    [aCoder encodeInteger:self.lowBpm forKey:@"lowBpm"];
    [aCoder encodeInteger:self.highBpm forKey:@"highBpm"];
    [aCoder encodeInteger:self.durationTo forKey:@"durationTo"];
    [aCoder encodeInteger:self.durationFrom forKey:@"durationFrom"];
}

@end
