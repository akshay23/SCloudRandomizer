//
//  SearchParams.h
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 1/12/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchParams : NSObject

@property BOOL hasParamsChanged;

- (id)initWithBool:(BOOL)changed;

@end
