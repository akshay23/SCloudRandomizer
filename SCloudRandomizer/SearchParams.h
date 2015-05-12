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
@property (strong, nonatomic) NSNumber *lowBpm;
@property (strong, nonatomic) NSNumber *highBpm;
@property (strong, nonatomic) NSString *keywords;

- (id)initWithBool:(BOOL)changed keywords:(NSString *)theKeywords lowBpm:(NSNumber *)lBpm highBpm:(NSNumber *)hBpm;

@end
