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
#import "SCAudioStream.h"

static const double LoggedOutBackgroundImageOpacity = 0.7;
static const double LoggedInBackgroundImageOpacity = 0.2;

// Private declarations
@interface MainViewController ()

typedef void(^singleTrackDownloaded)(void);

@property BOOL isCurrentSongLiked;
@property BOOL isPlayingForFirstTime;
@property NSUInteger currentSongNumber;
@property MusicSource *musicSource;
@property (strong, nonatomic) Track *currentTrack;
@property (strong, nonatomic) SearchParams *searchParams;
@property (strong, nonatomic) SCAudioStream *scAudioStream;
@property (strong, nonatomic) MBProgressHUD *prepToPlayHud;

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
    self.searchParams = [Utility loadSearchParamsWithKey:@"SearchParams"];
    if (self.searchParams == nil) {
        self.searchParams = [[SearchParams alloc] initWithBool:YES keywords:@"Biggie,2pac,remix"];
    }
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"StreamCompleted"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"ReadyToPlay"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.musicSource isUserLoggedIn]) {
        [self.btnSCConnect setHidden:YES];
        [self.btnSCDisconnect setHidden:NO];
        self.backgroundImage.alpha = LoggedInBackgroundImageOpacity;
        
        if (self.searchParams.hasChanged) {
            if (self.scAudioStream.playState == Playing) {
                [self playNextTrack];
            }
            else {
                [self getNextTrack:nil];
            }
            
            [Utility saveSearchParams:self.searchParams key:@"SearchParams"];
            self.searchParams.hasChanged = NO;
        }
    }
    else
    {
        self.backgroundImage.alpha = LoggedOutBackgroundImageOpacity;
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

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (IBAction)logout:(id)sender {
    [self.musicSource logout];
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
    self.backgroundImage.alpha = LoggedOutBackgroundImageOpacity;
    self.searchParams.hasChanged = YES;
    
    if (self.scAudioStream != nil) {
        [self.scAudioStream pause];
        self.scAudioStream = nil;
    }
    
    NSLog(@"Logged out.");
}

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

- (void)updateFavIcon:(BOOL)isLiked {
    if (isLiked) {
        [self.btnLike setImage:[UIImage imageNamed:@"Heart-red-transparent.png"] forState:UIControlStateNormal];
    } else {
        [self.btnLike setImage:[UIImage imageNamed:@"Heart-white-transparent.png"] forState:UIControlStateNormal];
    }
}

- (void)getFavState:(Track*) track {
    NSLog(@"Fav value: %@", track.isLiked);
    self.isCurrentSongLiked = ([track.isLiked isEqual:@0]) ? NO : YES;
    [self updateFavIcon:self.isCurrentSongLiked];
}

- (void)enableButtons:(BOOL)enable {
    [self.btnNext setEnabled:enable];
    [self.btnPlay setEnabled:enable];
    [self.btnInfo setEnabled:enable];
    [self.btnLike setEnabled:enable];
    [self.btnChangeParams setEnabled:enable];
    
    if (enable) {
        self.imgArtwork.alpha = 1;
    } else {
        self.imgArtwork.alpha = 0.5;
        self.imgArtwork.layer.borderWidth = 1;
    }
}

- (void)playTrack {
    if (self.isPlayingForFirstTime) {
        self.prepToPlayHud = [self getProgressBar:MBProgressHUDModeIndeterminate progressHudLabel:@"Preparing to play" progressHudDetailsLabel:@"Please wait.."];
        [self.prepToPlayHud show:YES];
        [self enableButtons:NO];
    }
    [self.scAudioStream play];
    [self.btnPlay setImage:[UIImage imageNamed:@"pause_btn.png"] forState:UIControlStateNormal];
}

- (void)playPauseSong {
    if (self.scAudioStream.playState != SCAudioStreamState_Playing) {
        if (self.scAudioStream == nil) {
            [self getNextTrack:^{
                [self playTrack];
            }];
        }
        [self playTrack];
        NSLog(@"Playing song");
    }
    else {
        [self.btnPlay setImage:[UIImage imageNamed:@"play_btn.png"] forState:UIControlStateNormal];
        [self.scAudioStream pause];
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

- (void)downloadTrack:(Track *)track
          progressHud: (MBProgressHUD *) progressHud
    completionHandler:(singleTrackDownloaded)completionHandler {
    NSLog(@"The streamURL is: %@", track.streamUrl);
    dispatch_async([Utility getMainQueue], ^{
        self.scAudioStream = [track getStream];
        if (completionHandler) completionHandler();
        [progressHud hide:YES];
    });
}

- (void)getNextTrack:(singleTrackDownloaded)completionHandler {
    [self.btnPlay setHidden:NO];
    [self.btnNext setHidden:NO];
    [self enableButtons:NO];
    self.isPlayingForFirstTime = YES;
    
    MBProgressHUD* progressHud = [self getProgressBar:MBProgressHUDModeIndeterminate
                                     progressHudLabel:@"Loading next track"
                              progressHudDetailsLabel:@"Please wait.."];
    
    [self.musicSource getRandomTrack:self.searchParams completionHandler:^(Track *track) {
        self.currentTrack = track;
        [self setupLockScreenInfo:track];
        [self setupUI:track];
        [self getFavState:track];
        [self downloadTrack:track progressHud:progressHud completionHandler: completionHandler];
    }];
}

- (void)playNextTrack {
    [self getNextTrack: ^{
        [self playTrack];
        NSLog(@"Will play next song");
    }];
}

- (void)setupLockScreenInfo:(Track*)track {
    dispatch_async([Utility getGlobalBackgroundQueue], ^{
        
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
        
        dispatch_async([Utility getMainQueue], ^{
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
        });
    });
}

// Set the UI after getting track info
- (void)setupUI:(Track *)track {
    [self.btnInfo setHidden:NO];
    [self.btnLike setHidden:NO];
    [self.imgArtwork setHidden:NO];
    [self.btnChangeParams setHidden:NO];
    [self enableButtons:YES];
    
    [self.lblArtistValue setHidden:NO];
    [self.lblLengthValue setHidden:NO];
    [self.lblTitleValue setHidden:NO];
    [self.lblTitle setHidden:NO];
    [self.lblArtist setHidden:NO];
    [self.lblLength setHidden:NO];
    
    [self.lblLengthValue setText:[Utility formatDuration:track.duration]];
    [self.lblArtistValue setText:track.artist];
    [self.lblTitleValue setText:track.title];
    self.btnChangeParams.layer.borderColor = [UIColor blackColor].CGColor;
    
    dispatch_async([Utility getGlobalBackgroundQueue], ^{
        NSData *albumArtData = [NSData dataWithContentsOfURL:track.albumArtUrl];
        
        dispatch_async([Utility getMainQueue], ^{
            self.imgArtwork.image = [UIImage imageWithData:albumArtData];
        });
    });
}

// Lock screen control actions
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
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

// Do something based on specific notifications
- (void)receiveNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"StreamCompleted"]) {
        NSLog (@"Recieved StreamCompleted notification!");
        [self playNextTrack];
    } else if ([[notification name] isEqualToString:@"ReadyToPlay"]) {
        NSLog(@"Recieved ReadyToPlay notification!");
        if (self.prepToPlayHud != nil) {
            [self.prepToPlayHud hide:YES];
            [self enableButtons:YES];
            self.prepToPlayHud = nil;
            self.isPlayingForFirstTime = NO;
        }
    }
}

// MainVCDelegate method
// Return current track
- (Track *)getCurrentTrack {
    return self.currentTrack;
}

// MainVCDelegate method
// Return current search params
- (SearchParams *)getCurrentSearchParams {
    return self.searchParams;
}

@end
