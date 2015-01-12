//
//  SearchParamsVC.h
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 1/12/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchParamsVC : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
