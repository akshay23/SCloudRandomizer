//
//  TrackInfoVC.h
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 2/26/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>

// Forward declaration of MainVCDelegate
@protocol MainVCDelegate;

@interface TrackInfoVC : UIViewController

// Delegate properties should always be weak references
// See http://stackoverflow.com/a/4796131/263871 for the rationale
@property (weak, nonatomic) id<MainVCDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *btnClose;
@property (strong, nonatomic) IBOutlet UITextView *txtTitle;
@property (strong, nonatomic) IBOutlet UITextView *txtArtist;

- (IBAction)close:(id)sender;

@end

// Protocol definition
@protocol MainVCDelegate<NSObject>

- (NSDictionary *)getCurrentTrack;

@end

