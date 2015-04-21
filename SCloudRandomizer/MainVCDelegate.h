//
//  MainVCDelegate.h
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 4/16/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import "SearchParams.h"

#ifndef SCloudRandomizer_MainVCDelegate_h
#define SCloudRandomizer_MainVCDelegate_h

// Protocol definition
@protocol MainVCDelegate<NSObject>

- (NSDictionary *)getCurrentTrack;
- (SearchParams *)getCurrentSearchParams;

@end

#endif