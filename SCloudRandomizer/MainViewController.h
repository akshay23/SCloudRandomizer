//
//  MainViewController.h
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 12/4/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SCUI.h>
#import <AVFoundation/AVFoundation.h>

@interface MainViewController : UIViewController

enum {
    Playing = 1,
    Paused = 2,
    Stopped = 3
};
typedef NSUInteger PlayerState;

@property (strong, nonatomic) NSArray *tracks;
@property (strong, nonatomic) AVAudioPlayer *player;

@property (strong, nonatomic) IBOutlet UIButton *btnSCConnect;
@property (strong, nonatomic) IBOutlet UIButton *btnSCDisconnect;
@property (strong, nonatomic) IBOutlet UIButton *btnGetTracks;
@property (strong, nonatomic) IBOutlet UIButton *btnPlay;
@property (strong, nonatomic) IBOutlet UIButton *btnNext;

- (IBAction)logout:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)getTracks:(id)sender;
- (IBAction)playSong:(id)sender;
- (IBAction)playNext:(id)sender;

@end
