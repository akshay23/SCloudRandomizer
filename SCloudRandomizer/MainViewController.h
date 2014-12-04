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

@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, strong) AVAudioPlayer *player;

@property (strong, nonatomic) IBOutlet UIButton *btnSCConnect;
@property (strong, nonatomic) IBOutlet UIButton *btnSCDisconnect;
@property (strong, nonatomic) IBOutlet UIButton *btnGetTracks;
@property (strong, nonatomic) IBOutlet UIButton *btnPlay;

- (IBAction)logout:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)getTracks:(id)sender;
- (IBAction)playSong:(id)sender;

@end
