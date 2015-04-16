//
//  MainViewController.m
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 12/4/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (strong, nonatomic) NSData *currentSongData;
@property BOOL isCurrentSongLiked;
@property NSUInteger currentSongNumber;
@property (strong, nonatomic) NSDictionary *currentTrack;
@property (strong, nonatomic) SearchParams *mySearchParams;

@end

@implementation MainViewController

@synthesize player;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Storyboard
    if (![GlobalData getInstance].mainStoryboard)
    {
        // Instantiate new main storyboard instance
        [GlobalData getInstance].mainStoryboard = self.storyboard;
        NSLog(@"mainStoryboard instantiated");
    }
    
    // New search params view instance and track info VC
    self.searchParamsVC = [[GlobalData getInstance].mainStoryboard instantiateViewControllerWithIdentifier:@"searchParamsVC"];
    self.searchParamsVC.delegate = self;
    self.trackInfoVC = [[GlobalData getInstance].mainStoryboard instantiateViewControllerWithIdentifier:@"trackInfoVC"];
    self.trackInfoVC.delegate = self;
    self.mySearchParams = [[SearchParams alloc] initWithBool:YES keywords:@"Biggie,2pac,remix" lowBpm:[NSNumber numberWithInt:80] highBpm:[NSNumber numberWithInt:150]];
    
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
    
    // Disable/enable SC buttons if user is currently logged in
    if ([self isPlayerLoggedIn])
    {
        [self.btnSCConnect setHidden:YES];
        [self.btnSCDisconnect setHidden:NO];
        self.backgroundImage.alpha = 0.2;
        
        if (self.mySearchParams.hasParamsChanged)
        {
            
            if ([self.player isPlaying])
            {
                [self refreshTrackList];
                [self doPlayNextSong];
            }
            else
            {
                [self getTracks];
            }
            
            self.mySearchParams.hasParamsChanged = NO;
        }
    }
    else
    {
        self.backgroundImage.alpha = 0.7;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //End recieving events
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
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

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (IBAction)logout:(id)sender
{
    [self.player stop];
    [SCSoundCloud removeAccess];
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
    self.backgroundImage.alpha = 0.7;
    self.mySearchParams.hasParamsChanged = YES;
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

- (BOOL)isPlayerLoggedIn
{
    SCAccount *account = [SCSoundCloud account];
    return (account != nil);
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

- (IBAction)favThisSong:(id)sender
{
    NSString *resourceURL = @"https://api.soundcloud.com/me/favorites/";
    NSURL *postURL = [NSURL URLWithString:[resourceURL stringByAppendingString: [[self.currentTrack objectForKey:@"id"] stringValue]]];
    
    if (self.isCurrentSongLiked)
    {
        [SCRequest performMethod:SCRequestMethodDELETE onResource:postURL usingParameters:nil withAccount:[SCSoundCloud account] sendingProgressHandler:nil responseHandler:nil];
        [self.btnLike setImage:[UIImage imageNamed:@"Heart-white-transparent.png"] forState:UIControlStateNormal];
        NSLog(@"Removed from favs list");
    }
    else
    {
        [SCRequest performMethod:SCRequestMethodPUT onResource:postURL usingParameters:nil withAccount:[SCSoundCloud account] sendingProgressHandler:nil responseHandler:nil];
        [self.btnLike setImage:[UIImage imageNamed:@"Heart-red-transparent.png"] forState:UIControlStateNormal];
        NSLog(@"Added to favs list");
    }
    
    self.isCurrentSongLiked = !self.isCurrentSongLiked;
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

// Get tracks based on SearchParams
- (void)getTracks
{
    SCRequestResponseHandler handler;
    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&jsonError];
        if (!jsonError &&
            [jsonResponse isKindOfClass:[NSArray class]]) {
            self.tracks = (NSArray *)jsonResponse;
            [self.btnPlay setHidden:NO];
            [self.btnNext setHidden:NO];
            [self.btnNext setEnabled:NO];
            [self.btnPlay setEnabled:NO];
            [self.btnChangeParams setEnabled:NO];
            NSLog(@"Tracks acquired.");
            
            self.currentSongNumber = arc4random_uniform((uint32_t) self.tracks.count);
            NSDictionary *track = [self.tracks objectAtIndex:self.currentSongNumber];
            [self getTrackInfo:track shouldPlay:NO];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not get your tracks! Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            NSLog(@"Could not get tracks.");
        }
    };
    
    // Replace spaces with '%20' and then replace commas with '%2C'
    NSString *cleanedKeywords = [[self.mySearchParams.keywords stringByReplacingOccurrencesOfString:@" " withString:@"%20"] stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    NSString *resourceURL = [NSString stringWithFormat:@"https://api.soundcloud.com/tracks?format=json&q=%@", cleanedKeywords];
    NSLog(@"The resourceURL is %@", resourceURL);
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:nil
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:nil
             responseHandler:handler];
}

// Actually play the next sont
- (void)doPlayNextSong
{
    [self.player stop];
    [self refreshTrackList];
    NSInteger randomNumber = arc4random_uniform((uint32_t) self.tracks.count);
    self.currentSongNumber = randomNumber;
    NSDictionary *track = [self.tracks objectAtIndex:randomNumber];
    [self.btnNext setEnabled:NO];
    [self.btnPlay setEnabled:NO];
    [self.btnChangeParams setEnabled:NO];
    [self.btnInfo setEnabled:NO];
    [self.btnLike setEnabled:NO];
    self.imgArtwork.alpha = 0.5;
    [self getTrackInfo:track shouldPlay:YES];
    
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

// Display the track info and play song if needed
- (void)getTrackInfo:(NSDictionary *)track shouldPlay:(BOOL)play
{
    NSString *streamURL = [track objectForKey:@"stream_url"];
    NSLog(@"The streamURL is: %@", streamURL);
    
    while ([GlobalData stringIsNilOrEmpty:streamURL])
    {
        NSLog(@"streamURL is null");
        [self refreshTrackList];
        NSInteger randomNumber = arc4random_uniform((uint32_t) self.tracks.count);
        self.currentSongNumber = randomNumber;
        NSDictionary *track2 = [self.tracks objectAtIndex:randomNumber];
        streamURL = [track2 objectForKey:@"stream_url"];
    }
    
    SCAccount *account = [SCSoundCloud account];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading Track";
    hud.detailsLabelText = @"Please wait..";
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:streamURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:^(unsigned long long bytesSent, unsigned long long bytesTotal) {
                                hud.progress = ((float)bytesSent / bytesTotal);
                            }
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
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

                 [hud hide:YES];
             }];

}

// Load songs based on SearchParams
// Refresh/reload track list
- (void)refreshTrackList
{
    SCRequestResponseHandler handler = ^(NSURLResponse *response, NSData *data, NSError *error)
    {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]])
        {
            self.tracks = (NSArray *)jsonResponse;
            NSLog(@"Tracks list refreshed.");
        }
    };
    
    // Replace spaces with '%20' and then replace commas with '%2C'
    NSString *cleanedKeywords = [[self.mySearchParams.keywords stringByReplacingOccurrencesOfString:@" " withString:@"%20"] stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    NSString *resourceURL = [NSString stringWithFormat:@"https://api.soundcloud.com/tracks?format=json&q=%@", cleanedKeywords];
    NSLog(@"The resourceURL is %@", resourceURL);
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:nil
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:nil
             responseHandler:handler];
}

// Set the like button accordingly
- (void)checkFavouritesList
{
    if ([[self.currentTrack objectForKey:@"user_favorite"]  isEqual: @"0"])
    {
        self.isCurrentSongLiked = YES;
        [self.btnLike setImage:[UIImage imageNamed:@"Heart-red-transparent.png"] forState:UIControlStateNormal];
    }
    else
    {
        self.isCurrentSongLiked = NO;
        [self.btnLike setImage:[UIImage imageNamed:@"Heart-white-transparent.png"] forState:UIControlStateNormal];
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
        MPMediaItemArtwork *albumArtwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithData:imageData]];
        
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
    return self.mySearchParams;
}

@end
