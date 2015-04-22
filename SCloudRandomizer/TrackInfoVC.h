//
//  TrackInfoVC.h
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 2/26/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainVCDelegate.h"

@interface TrackInfoVC : UIViewController

// Delegate properties should always be weak references
// See http://stackoverflow.com/a/4796131/263871 for the rationale
@property (weak, nonatomic) id<MainVCDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *btnClose;
@property (strong, nonatomic) IBOutlet UITextView *songTitle;
@property (strong, nonatomic) IBOutlet UILabel *artist;
@property (strong, nonatomic) IBOutlet UILabel *likes;
@property (strong, nonatomic) IBOutlet UITextView *songDescription;
@property (strong, nonatomic) IBOutlet UILabel *numOfPlays;
@property (strong, nonatomic) IBOutlet UILabel *uploadedTime;
@property (strong, nonatomic) IBOutlet UITextView *tags;

- (IBAction)close:(id)sender;

@end
