//
//  MainViewController.m
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 12/4/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "MainViewController.h"

const double LoggedOutBackgroundImage_Opacity = 0.7;

@interface MainViewController ()

// Private properties
@property (strong, nonatomic) NSData *currentSongData;
@property BOOL isCurrentSongLiked;
@property NSUInteger currentSongNumber;
@property (strong, nonatomic) NSDictionary *currentTrack;
@property (strong, nonatomic) SearchParams *searchParams;
@property MusicSource *musicSource;

@end

@implementation MainViewController


- (void)viewDidLoad
{
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.musicSource isUserLoggedIn])
    {
        [self.btnSCConnect setHidden:YES];
        [self.btnSCDisconnect setHidden:NO];
        self.backgroundImage.alpha = 0.2;
        
        if (self.searchParams.hasChanged)
        {
            if ([self.player isPlaying])
            {
                [self doPlayNextSong];
            }
            else
            {
                [self getTracks:YES shouldPlay:NO];
            }
            
            self.searchParams.hasChanged = NO;
        }
    }
    else
    {
        self.backgroundImage.alpha = LoggedOutBackgroundImage_Opacity;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Once the view has loaded then we can register to begin recieving controls and we can become the first responder
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender
{
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

- (IBAction)login:(id)sender
{
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

- (IBAction)playSong:(id)sender
{
    [self playPauseSong];
}

- (IBAction)playNext:(id)sender
{
    [self doPlayNextSong];
}

- (IBAction)changeParams:(id)sender
{
    [self presentViewController:self.searchParamsVC animated:YES completion:nil];
}

- (IBAction)toggleFavState:(id)sender
{
    self.isCurrentSongLiked = !self.isCurrentSongLiked;
    
    [self.musicSource updateLikedState:self.isCurrentSongLiked
                               trackId:[[self.currentTrack objectForKey:@"id"] stringValue]];
    
    if (self.isCurrentSongLiked)
    {
        [self.btnLike setImage:[UIImage imageNamed:@"Heart-red-transparent.png"] forState:UIControlStateNormal];
        NSLog(@"Added to favs list");
    }
    else
    {
        [self.btnLike setImage:[UIImage imageNamed:@"Heart-white-transparent.png"] forState:UIControlStateNormal];
        NSLog(@"Removed from favs list");
    }
}

- (IBAction)showTrackInfo:(id)sender
{
    // Custom animation
    CATransition *animation = [CATransition animation];
    animation.duration = 0.3;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromRight;

    [self.view.window.layer addAnimation:animation forKey:kCATransition];
    [self presentViewController:self.trackInfoVC animated:NO completion:nil];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)playPauseSong
{
    if (![self.player isPlaying])
    {
        if (self.player.data == nil && self.currentSongData == nil)
        {
            NSDictionary *track = [self.tracks objectAtIndex:1];
            self.currentSongNumber = 1;
            [self getTrackInfo:track shouldPlay:YES];
            NSLog(@"Playing song for first time");
        }
        else
        {
            [self.player prepareToPlay];
            [self.player play];
            [self.btnPlay setImage:[UIImage imageNamed:@"pause_btn.png"] forState:UIControlStateNormal];
            NSLog(@"Resuming song");
        }
    }
    else
    {
        [self.btnPlay setImage:[UIImage imageNamed:@"play_btn.png"] forState:UIControlStateNormal];
        [self.player pause];
        NSLog(@"Pausing song");
    }
}

- (MBProgressHUD*) getProgressBar:(MBProgressHUDMode)progressHudMode
                                progressHudLabel:(NSString*) progressHudTitle
                                progressHudDetailsLabel:(NSString*) progressHudDetails
{
    MBProgressHUD* progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHud.mode = progressHudMode;
    progressHud.labelText =  progressHudTitle;
    progressHud.detailsLabelText = progressHudDetails;
    return progressHud;
}

// Get/refresh tracks based on SearchParams
- (void)getTracks:(BOOL)shouldGetTrackInfo shouldPlay:(BOOL)playBool
{
    // Disable buttons
    self.imgArtwork.alpha = 0.5;
    [self.btnPlay setHidden:NO];
    [self.btnNext setHidden:NO];
    [self.btnNext setEnabled:NO];
    [self.btnPlay setEnabled:NO];
    [self.btnInfo setEnabled:NO];
    [self.btnLike setEnabled:NO];
    [self.btnChangeParams setEnabled:NO];
    
    MBProgressHUD* progressHud = [self getProgressBar:MBProgressHUDModeIndeterminate
          progressHudLabel:@"Refreshing Track List"
          progressHudDetailsLabel:@"Please wait.."];
    
    SCRequestSendingProgressHandler progressHandler =
        ^(unsigned long long bytesSent, unsigned long long bytesTotal) {
                progressHud.progress = ((float)bytesSent / bytesTotal);
        };
    
    SCRequestResponseHandler responseHandler =
        ^(NSURLResponse *response, NSData *data, NSError *error)
        {
            NSError *jsonError = nil;
            NSJSONSerialization *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
                self.tracks = (NSArray *)jsonResponse;
                self.currentSongNumber = arc4random_uniform((uint32_t) self.tracks.count);
                
                if (shouldGetTrackInfo)
                {
                    NSDictionary *track = [self.tracks objectAtIndex:self.currentSongNumber];
                    [self getTrackInfo:track shouldPlay:playBool];
                }
                
                NSLog(@"Tracks acquired.");
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Could not get your tracks! Please try again."
                                                                delegate:self
                                                                cancelButtonTitle:@"Ok"
                                                                otherButtonTitles:nil];
                [alert show];
                NSLog(@"Could not get tracks.");
            }
            
            [progressHud hide:YES];
        };
    
    // Replace spaces with '%20' and then replace commas with '%2C'
    NSString *cleanedKeywords = [[self.searchParams.keywords stringByReplacingOccurrencesOfString:@" " withString:@"%20"] stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    NSString *resourceURL = [NSString stringWithFormat:@"https://api.soundcloud.com/tracks?format=json&q=%@", cleanedKeywords];
    NSLog(@"The resourceURL is %@", resourceURL);

    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:nil
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:progressHandler
             responseHandler:responseHandler];
}

// Display the track info and play song if needed
- (void)getTrackInfo:(NSDictionary *)track shouldPlay:(BOOL)play
{
    NSString *streamURL = [track objectForKey:@"stream_url"];
    NSLog(@"The streamURL is: %@", streamURL);
    
    // Get new track if stream URL is nil
    while ([GlobalData stringIsNilOrEmpty:streamURL])
    {
        NSLog(@"streamURL is null");
        [self getTracks:NO shouldPlay:NO];
        NSDictionary *track2 = [self.tracks objectAtIndex:self.currentSongNumber];
        streamURL = [track2 objectForKey:@"stream_url"];
    }
    
    MBProgressHUD* progressHud = [self getProgressBar:MBProgressHUDModeIndeterminate
                            progressHudLabel:@"Loading Track"
                            progressHudDetailsLabel:@"Please wait.."];
    
    SCRequestSendingProgressHandler progressHandler =
        ^(unsigned long long bytesSent, unsigned long long bytesTotal)
         {
                progressHud.progress = ((float)bytesSent / bytesTotal);
         };
    
    SCRequestResponseHandler responseHandler =
        ^(NSURLResponse *response, NSData *data, NSError *error)
        {
                self.currentSongData = data;
                self.player = [[AVAudioPlayer alloc] initWithData:data error:nil];
                self.player.delegate = self;
                
                [self setupLockScreenInfo:track];
                [self setupUI:track];
                [self checkFavouritesList];
                
                if (play)
                {
                    [self.player prepareToPlay];
                    [self.player play];
                    [self.btnPlay setImage:[UIImage imageNamed:@"pause_btn.png"] forState:UIControlStateNormal];
                }
                
                [progressHud hide:YES];
        };
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:streamURL]
             usingParameters:nil
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:progressHandler
             responseHandler:responseHandler];
}

// Actually play the next sont
- (void)doPlayNextSong
{
    [self.player stop];
    [self getTracks:YES shouldPlay:YES];
    
    NSLog(@"Will play next song");
}

// Convert to ms
- (NSString *)convertFromMilliseconds:(long)duration
{
    NSInteger minutes = floor(duration / 60000);
    NSInteger seconds = ((duration % 60000) / 1000);
    NSString *formatted = nil;
    if (seconds < 10)
    {
        formatted = [NSString stringWithFormat:@"%ld:0%ld", (long)minutes, (long)seconds];
    }
    else
    {
        formatted = [NSString stringWithFormat:@"%ld:%ld", (long)minutes, (long)seconds];
    }

    return  formatted;
}

// Set the like button accordingly
- (void)checkFavouritesList
{
    NSNumber *favValue = [self.currentTrack objectForKey:@"user_favorite"];
    NSLog(@"Fav value: %@", favValue);
    if ([favValue isEqual:@0])
    {
        self.isCurrentSongLiked = NO;
        [self.btnLike setImage:[UIImage imageNamed:@"Heart-white-transparent.png"] forState:UIControlStateNormal];
    }
    else
    {
        self.isCurrentSongLiked = YES;
        [self.btnLike setImage:[UIImage imageNamed:@"Heart-red-transparent.png"] forState:UIControlStateNormal];
    }
}

// Play next song as the current song is finishing
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self doPlayNextSong];
}

// Set up the lock screen
- (void)setupLockScreenInfo:(NSDictionary *)track
{
    NSString *trackTitle = [track objectForKey:@"title"];
    NSString *trackArtist = [[track objectForKey:@"user"] objectForKey:@"username"];
    long duration = [[track objectForKey:@"duration"] longValue];
    NSNumber *actualDuration = [NSNumber numberWithInt:(int)(duration/1000)];
    NSString *urlString = nil;

    id albumArt = [track objectForKey:@"artwork_url"];
    if (albumArt == [NSNull null])
    {
        urlString = [[[track objectForKey:@"user"] objectForKey:@"avatar_url"] stringByReplacingOccurrencesOfString:@"-large" withString:@"-t300x300"];
    }
    else
    {
        urlString = [(NSString *)albumArt stringByReplacingOccurrencesOfString:@"-large" withString:@"-t300x300"];
    }
    
    NSURL *imgUrl = [NSURL URLWithString:urlString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imgUrl];
        MPMediaItemArtwork *albumArtwork;
        if (!imageData)
        {
            albumArtwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"Music-icon.png"]];
        }
        else
        {
            albumArtwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithData:imageData]];
        }
        
        NSArray *keys = [NSArray arrayWithObjects:MPMediaItemPropertyArtist, MPMediaItemPropertyTitle, MPMediaItemPropertyArtwork, MPMediaItemPropertyPlaybackDuration, MPNowPlayingInfoPropertyPlaybackRate, nil];
        NSArray *values = [NSArray arrayWithObjects:trackArtist, trackTitle, albumArtwork, actualDuration, [NSNumber numberWithInt:1], nil];
        NSDictionary *mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
        });
    });
}

// Set the UI after getting track info
- (void)setupUI:(NSDictionary *)track
{
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
    
    long duration = [[track objectForKey:@"duration"] longValue];
    [self.lblLengthValue setText:[self convertFromMilliseconds:duration]];
    [self.lblArtistValue setText:[[track objectForKey:@"user"] objectForKey:@"username"]];
    [self.lblTitleValue setText:[track objectForKey:@"title"]];
    self.currentTrack = track;
    self.imgArtwork.layer.borderWidth = 1;
    self.imgArtwork.alpha = 1.0;
    self.btnChangeParams.layer.borderColor = [UIColor blackColor].CGColor;
    
    NSString *urlString = nil;
    id albumArt = [track objectForKey:@"artwork_url"];
    if (albumArt == [NSNull null])
    {
        urlString = [[[track objectForKey:@"user"] objectForKey:@"avatar_url"] stringByReplacingOccurrencesOfString:@"-large" withString:@"-t300x300"];
    }
    else
    {
        urlString = [(NSString *)albumArt stringByReplacingOccurrencesOfString:@"-large" withString:@"-t300x300"];
    }
    
    NSURL *imgUrl = [NSURL URLWithString:urlString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imgUrl];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            self.imgArtwork.image = [UIImage imageWithData:imageData];
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
            [self doPlayNextSong];
        }
    }
}

// MainVCDelegate method
// Return current track
- (NSDictionary *)getCurrentTrack
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
