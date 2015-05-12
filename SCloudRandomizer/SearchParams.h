//
//  SearchParams.h
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 1/12/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchParams : NSObject

@property BOOL hasChanged;
@property NSInteger lowBpm;
@property NSInteger highBpm;
@property NSInteger durationFrom;
@property NSInteger durationTo;
@property (strong, nonatomic) NSString *keywords;

- (id)initWithBool:(BOOL)changed keywords:(NSString *)theKeywords;

@end
