//
//  SearchParamsVC.h
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 1/12/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainVCDelegate.h"

@interface SearchParamsVC : UIViewController

// Delegate properties should always be weak references
// See http://stackoverflow.com/a/4796131/263871 for the rationale
@property (weak, nonatomic) id<MainVCDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
@property (strong, nonatomic) IBOutlet UITextView *txtKeywords;
@property (strong, nonatomic) IBOutlet UITextView *txtBpmFrom;
@property (strong, nonatomic) IBOutlet UITextView *txtBpmTo;
@property (strong, nonatomic) IBOutlet UITextView *txtLikes;
@property (strong, nonatomic) IBOutlet UITextView *txtPlays;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
