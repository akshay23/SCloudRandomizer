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
#import <MediaPlayer/MediaPlayer.h>
#import "MBProgressHUD.h"
#import "SearchParamsVC.h"
#import "GlobalData.h"
#import "SearchParams.h"
#import "TrackInfoVC.h"
#import "MusicSource.h"

@interface MainViewController : UIViewController<AVAudioPlayerDelegate, MainVCDelegate>

enum {
    Playing = 1,
    Paused = 2,
    Stopped = 3
};
typedef NSUInteger PlayerState;

@property (strong, nonatomic) SearchParamsVC *searchParamsVC;
@property (strong, nonatomic) TrackInfoVC *trackInfoVC;

@property (strong, nonatomic) IBOutlet UIButton *btnSCConnect;
@property (strong, nonatomic) IBOutlet UIButton *btnSCDisconnect;
@property (strong, nonatomic) IBOutlet UIButton *btnPlay;
@property (strong, nonatomic) IBOutlet UIButton *btnNext;
@property (strong, nonatomic) IBOutlet UILabel *lblTitleValue;
@property (strong, nonatomic) IBOutlet UILabel *lblArtistValue;
@property (strong, nonatomic) IBOutlet UILabel *lblLengthValue;
@property (strong, nonatomic) IBOutlet UILabel *lblCurrentTime;
@property (strong, nonatomic) IBOutlet UIImageView *imgArtwork;
@property (strong, nonatomic) IBOutlet UIButton *btnChangeParams;
@property (strong, nonatomic) IBOutlet UIButton *btnInfo;
@property (strong, nonatomic) IBOutlet UIButton *btnLike;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet UIImageView *refreshImage;
@property (strong, nonatomic) IBOutlet UISlider *scrubber;

- (IBAction)logout:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)playSong:(id)sender;
- (IBAction)playNext:(id)sender;
- (IBAction)changeParams:(id)sender;
- (IBAction)setFavState:(id)sender;
- (IBAction)showTrackInfo:(id)sender;

@end
