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
#import "MBProgressHUD.h"
#import "SearchParamsVC.h"
#import "GlobalData.h"
#import "SearchParams.h"

@interface MainViewController : UIViewController

enum {
    Playing = 1,
    Paused = 2,
    Stopped = 3
};
typedef NSUInteger PlayerState;

@property BOOL paramsChanged;
@property (strong, nonatomic) NSArray *tracks;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) SearchParamsVC *searchParamsVC;
@property (strong, nonatomic) SearchParams *mySearchParams;

@property (strong, nonatomic) IBOutlet UIButton *btnSCConnect;
@property (strong, nonatomic) IBOutlet UIButton *btnSCDisconnect;
@property (strong, nonatomic) IBOutlet UIButton *btnPlay;
@property (strong, nonatomic) IBOutlet UIButton *btnNext;
@property (strong, nonatomic) IBOutlet UILabel *lblSongTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblArtist;
@property (strong, nonatomic) IBOutlet UILabel *lblLength;
@property (strong, nonatomic) IBOutlet UIImageView *imgArtwork;
@property (strong, nonatomic) IBOutlet UIButton *btnChangeParams;
@property (strong, nonatomic) IBOutlet UIButton *btnInfo;
@property (strong, nonatomic) IBOutlet UIButton *btnLike;

- (IBAction)logout:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)playSong:(id)sender;
- (IBAction)playNext:(id)sender;
- (IBAction)changeParams:(id)sender;
- (IBAction)favThisSong:(id)sender;
- (IBAction)showTrackInfo:(id)sender;

@end
