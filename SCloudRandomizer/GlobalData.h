//
//  GlobalData.h
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 1/12/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Used for global objects
@interface GlobalData : NSObject
{
    UIStoryboard *mainStoryboard;
}

@property (nonatomic, strong) UIStoryboard *mainStoryboard;

// Singleton method
+ (GlobalData *)getInstance;

// Check if string is null or empty
+ (BOOL)stringIsNilOrEmpty:(NSString*)aString;

@end
