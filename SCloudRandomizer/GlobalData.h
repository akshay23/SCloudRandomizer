//
//  GlobalData.h
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 1/12/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MMWormhole.h"

// Used for global objects
@interface GlobalData : NSObject
{
    UIStoryboard *mainStoryboard;
    MMWormhole *wormhole;
}

@property (nonatomic, strong) UIStoryboard *mainStoryboard;
@property (nonatomic, strong) MMWormhole *wormhole;

// Singleton method
+ (GlobalData *)getInstance;

@end
