//
//  MainViewController.m
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 12/4/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "MainViewController.h"
#import "Utility.h"
#import "Track.h"

const double LoggedOutBackgroundImage_Opacity = 0.7;
const double LoggedInBackgroundImage_Opacity = 0.2;

// Private declarations
@interface MainViewController ()

typedef void(^singleTrackDownloaded)(NSData* trackData);

@property BOOL isCurrentSongLiked;
@property NSUInteger currentSongNumber;
@property (strong, nonatomic) Track *currentTrack;
@property (strong, nonatomic) SearchParams *searchParams;
@property MusicSource *musicSource;

- (void)getNextTrack:(singleTrackDownloaded)completionHandler;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.musicSource = [MusicSource getInstance];
    
    if (![GlobalData getInstance].mainStoryboard)
    {
        // Instantiate new main storyboard instance
        [GlobalData getInstance].mainStoryboard = self.storyboard;
        NSLog(@"mainStoryboard instantiated");
    }
    
    self.searchParamsVC = [[GlobalData getInstance].mainStoryboard instantiateViewControllerWithIdentifier:@"searchParamsVC"];
    self.searchParamsVC.delegate = self;
    self.trackInfoVC = [[GlobalData getInstance].mainStoryboard instantiateViewControllerWithIdentifier:@"trackInfoVC"];
    self.trackInfoVC.delegate = self;
    self.searchParams = [[SearchParams alloc] initWithBool:YES keywords:@"Biggie,2pac,remix" lowBpm:[NSNumber numberWithInt:80] highBpm:[NSNumber numberWithInt:150]];
    
    // Clear the labels
    [self.lblArtistValue setText:@""];
    [self.lblLengthValue setText:@""];
    [self.lblTitleValue setText:@""];
    self.currentSongNumber = 3;
    
    // Draw border around parameters button
    self.btnChangeParams.layer.cornerRadius = 4;
    self.btnChangeParams.layer.borderWidth = 1;
    self.btnChangeParams.layer.borderColor = [UIColor blueColor].CGColor;
    self.paramsChanged = YES;
}

- (void) initPlayer:(NSData*) trackData {
    self.player = [[AVAudioPlayer alloc] initWithData:trackData error:nil];
    self.player.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.musicSource isUserLoggedIn]) {
        [self.btnSCConnect setHidden:YES];
        [self.btnSCDisconnect setHidden:NO];
        self.backgroundImage.alpha = LoggedInBackgroundImage_Opacity;
        
        if (self.searchParams.hasChanged) {
            if ([self.player isPlaying]) {
                [self playNextTrack];
            }
            else {
                [self getNextTrack:^(NSData* trackData) {
                    [self initPlayer:trackData];
                }];
            }
            
            self.searchParams.hasChanged = NO;
        }
    }
    else
    {
        self.backgroundImage.alpha = LoggedOutBackgroundImage_Opacity;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Once the view has loaded then we can register to begin recieving controls and we can become the first responder
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender {
    [self.musicSource logout];
    
    [self.player stop];
    [self.btnSCConnect setHidden:NO];
    [self.btnSCDisconnect setHidden:YES];
    [self.btnPlay setImage:[UIImage imageNamed:@"play_btn.png"] forState:UIControlStateNormal];
    [self.btnPlay setHidden:YES];
    [self.btnNext setHidden:YES];
    [self.btnInfo setHidden:YES];
    [self.btnLike setHidden:YES];
    [self.imgArtwork setHidden:YES];
    [self.lblArtist setHidden:YES];
    [self.lblLength setHidden:YES];
    [self.lblTitle setHidden:YES];
    [self.lblTitleValue setHidden:YES];
    [self.lblArtistValue setHidden:YES];
    [self.lblLengthValue setHidden:YES];
    [self.btnChangeParams setHidden:YES];
    self.backgroundImage.alpha = LoggedOutBackgroundImage_Opacity;
    self.searchParams.hasChanged = YES;
    NSLog(@"Logged out.");
}

// ToDo - Move this into a login view
- (IBAction)login:(id)sender {
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
        SCLoginViewController *loginViewController = [SCLoginViewController loginViewControllerWithPreparedURL:preparedURL
                                  completionHandler:^(NSError *error) {
                                      if (SC_CANCELED(error)) {
                                          NSLog(@"Canceled!");
                                      } else if (error) {
                                          NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
                                      } else {
                                          NSLog(@"Logged in.");
                                      }
                                  }];
        
        [self presentViewController:loginViewController animated:YES completion:nil];
    }];
}

- (IBAction)playSong:(id)sender {
    [self playPauseSong];
}

- (IBAction)playNext:(id)sender {
    [self playNextTrack];
}

- (IBAction)changeParams:(id)sender {
    [self presentViewController:self.searchParamsVC animated:YES completion:nil];
}

- (IBAction)setFavState:(id)sender {
    self.isCurrentSongLiked = !self.isCurrentSongLiked;
    [self.musicSource updateLikeState:self.isCurrentSongLiked trackId:[self.currentTrack.Id stringValue]];
    [self updateFavIcon:self.isCurrentSongLiked];
}

- (IBAction)showTrackInfo:(id)sender {
    // Custom animation
    CATransition *animation = [CATransition animation];
    animation.duration = 0.3;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromRight;

    [self.view.window.layer addAnimation:animation forKey:kCATransition];
    [self presentViewController:self.trackInfoVC animated:NO completion:nil];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)getFavState: (Track*) track {
    NSLog(@"Fav value: %@", track.isLiked);
    self.isCurrentSongLiked = track.isLiked;
    [self updateFavIcon:track.isLiked];
}

- (void)updateFavIcon:(BOOL)isLiked {
    if (isLiked) {
        [self.btnLike setImage:[UIImage imageNamed:@"Heart-red-transparent.png"] forState:UIControlStateNormal];
    } else {
        [self.btnLike setImage:[UIImage imageNamed:@"Heart-white-transparent.png"] forState:UIControlStateNormal];
    }
}

- (void)playPauseSong {
    if (![self.player isPlaying]) {
        if (self.player.data == nil) {
            [self getNextTrack:^(NSData* trackData) {
                [self initPlayer:trackData];
                [self playNextTrack];
                NSLog(@"Playing song for first time");
            }];
        } else {
            [self playTrack];
            NSLog(@"Resuming song");
        }
    }
    else {
        [self.btnPlay setImage:[UIImage imageNamed:@"play_btn.png"] forState:UIControlStateNormal];
        [self.player pause];
        NSLog(@"Pausing song");
    }
}

- (MBProgressHUD*) getProgressBar:(MBProgressHUDMode)progressHudMode
                                progressHudLabel:(NSString*) progressHudTitle
                                progressHudDetailsLabel:(NSString*) progressHudDetails {
    MBProgressHUD* progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHud.mode = progressHudMode;
    progressHud.labelText =  progressHudTitle;
    progressHud.detailsLabelText = progressHudDetails;
    return progressHud;
}

- (void)getNextTrack:(singleTrackDownloaded)completionHandler {
    self.imgArtwork.alpha = 0.5;
    [self.btnPlay setHidden:NO];
    [self.btnNext setHidden:NO];
    [self.btnNext setEnabled:NO];
    [self.btnPlay setEnabled:NO];
    [self.btnInfo setEnabled:NO];
    [self.btnLike setEnabled:NO];
    [self.btnChangeParams setEnabled:NO];
    
    MBProgressHUD* progressHud = [self getProgressBar:MBProgressHUDModeIndeterminate
          progressHudLabel:@"Loading next track"
          progressHudDetailsLabel:@"Please wait.."];
    
    [self.musicSource getRandomTrack:self.searchParams.keywords
                        completionHandler:^(Track *track) {
                            self.currentTrack = track;
                            [self setupLockScreenInfo:track];
                            [self setupUI:track];
                            [self getFavState:track];
                            [self downloadTrack:track progressHud:progressHud completionHandler: completionHandler];
    }];
}

- (void)playTrack {
    [self.player prepareToPlay];
    [self.player play];
    [self.btnPlay setImage:[UIImage imageNamed:@"pause_btn.png"] forState:UIControlStateNormal];
}

- (void)stopPlayingTrack {
    [self.player stop];
}

- (void)downloadTrack:(Track *)track
        progressHud: (MBProgressHUD *) progressHud
        completionHandler:(singleTrackDownloaded)completionHandler {
    NSLog(@"The streamURL is: %@", track.streamUrl);
    
    [track download:^(NSData* trackData) {
        [progressHud hide:YES];
        completionHandler(trackData);
    }];
}

// Todo - Should this always play by default?
- (void)playNextTrack
{
    [self stopPlayingTrack];
    [self getNextTrack: ^(NSData* trackData) {
        [self initPlayer:trackData];
        [self playTrack];
        NSLog(@"Will play next song");
    }];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self playNextTrack];
}

- (void)setupLockScreenInfo:(Track*)track {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSNumber *songDurationInSeconds = [NSNumber numberWithInt:(int)(track.duration / 1000)];
        
        // ToDo - Replace dataWithContentsOfURL with async call
        NSData *albumArtData = [NSData dataWithContentsOfURL:track.albumArtUrl];
        MPMediaItemArtwork *albumArtwork = nil;
        if (!albumArtData) {
            albumArtwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"Music-icon.png"]];
        }
        else {
            albumArtwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithData:albumArtData]];
        }
        
        NSArray *keys = [NSArray arrayWithObjects:MPMediaItemPropertyArtist, MPMediaItemPropertyTitle, MPMediaItemPropertyArtwork, MPMediaItemPropertyPlaybackDuration, MPNowPlayingInfoPropertyPlaybackRate, nil];
        NSArray *values = [NSArray arrayWithObjects:track.artist, track.title, albumArtwork, songDurationInSeconds, [NSNumber numberWithInt:1], nil];
        NSDictionary *mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
        });
    });
}

// Set the UI after getting track info
- (void)setupUI:(Track *)track {
    [self.btnInfo setHidden:NO];
    [self.btnLike setHidden:NO];
    [self.btnNext setEnabled:YES];
    [self.btnPlay setEnabled:YES];
    [self.btnInfo setEnabled:YES];
    [self.btnLike setEnabled:YES];
    [self.imgArtwork setHidden:NO];
    [self.btnChangeParams setHidden:NO];
    [self.btnChangeParams setEnabled:YES];
    
    [self.lblArtistValue setHidden:NO];
    [self.lblLengthValue setHidden:NO];
    [self.lblTitleValue setHidden:NO];
    [self.lblTitle setHidden:NO];
    [self.lblArtist setHidden:NO];
    [self.lblLength setHidden:NO];
    
    [self.lblLengthValue setText:[Utility convertFromMilliseconds:track.duration]];
    [self.lblArtistValue setText:track.artist];
    [self.lblTitleValue setText:track.title];
    
    self.imgArtwork.layer.borderWidth = 1;
    self.imgArtwork.alpha = 1.0;
    self.btnChangeParams.layer.borderColor = [UIColor blackColor].CGColor;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *albumArtData = [NSData dataWithContentsOfURL:track.albumArtUrl];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imgArtwork.image = [UIImage imageWithData:albumArtData];
        });
    });
}

// Lock screen control actions
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl)
    {
        if (event.subtype == UIEventSubtypeRemoteControlPlay ||
            event.subtype == UIEventSubtypeRemoteControlPause ||
            event.subtype == UIEventSubtypeRemoteControlTogglePlayPause)
        {
            [self playPauseSong];
        }
        else if (event.subtype == UIEventSubtypeRemoteControlNextTrack)
        {
            [self playNextTrack];
        }
    }
}

// MainVCDelegate method
// Return current track
- (Track *)getCurrentTrack
{
    return self.currentTrack;
}

// MainVCDelegate method
// Return current search params
- (SearchParams *)getCurrentSearchParams
{
    return self.searchParams;
}

@end
