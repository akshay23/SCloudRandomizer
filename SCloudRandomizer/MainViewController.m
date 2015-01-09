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
@property NSUInteger currentSongNumber;

@end

@implementation MainViewController

@synthesize player;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Clear the labels
    [self.lblArtist setText:@""];
    [self.lblLength setText:@""];
    [self.lblSongTitle setText:@""];
    self.currentSongNumber = 3;
    
    // Draw border around parameters button
    self.btnChangeParams.layer.cornerRadius = 4;
    self.btnChangeParams.layer.borderWidth = 1;
    self.btnChangeParams.layer.borderColor = [UIColor blueColor].CGColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Disable/enable SC buttons if user is currently logged in
    if ([SCSoundCloud account] != nil)
    {
        [self.btnSCConnect setHidden:YES];
        [self.btnSCDisconnect setHidden:NO];
        [self.imgArtwork setHidden:NO];
        [self.lblArtist setHidden:NO];
        [self.lblLength setHidden:NO];
        [self.lblSongTitle setHidden:NO];
    }
    else
    {
        [self.btnSCConnect setHidden:NO];
        [self.btnSCDisconnect setHidden:YES];
        [self.btnPlay setHidden:YES];
        [self.btnNext setHidden:YES];
    }
    
    [self getTracks];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender
{
    [SCSoundCloud removeAccess];
    [self.btnSCConnect setHidden:NO];
    [self.btnSCDisconnect setHidden:YES];
    [self.btnPlay setHidden:YES];
    [self.btnNext setHidden:YES];
    [self.imgArtwork setHidden:YES];
    [self.lblArtist setHidden:YES];
    [self.lblLength setHidden:YES];
    [self.lblSongTitle setHidden:YES];
    [self.player stop];
    NSLog(@"Logged out.");
}

- (IBAction)login:(id)sender
{
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
        SCLoginViewController *loginViewController;
        loginViewController = [SCLoginViewController loginViewControllerWithPreparedURL:preparedURL
                                  completionHandler:^(NSError *error) {
                                      if (SC_CANCELED(error)) {
                                          NSLog(@"Canceled!");
                                      } else if (error) {
                                          NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
                                      } else {
                                          self.player = [[AVAudioPlayer alloc] init];
                                          NSLog(@"Logged in.");
                                      }
                                  }];
        
        [self presentViewController:loginViewController animated:YES completion:nil];
    }];
}

- (void)getTracks
{
    SCRequestResponseHandler handler;
    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&jsonError];
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
            self.tracks = (NSArray *)jsonResponse;
            [self.btnPlay setHidden:NO];
            [self.btnNext setHidden:NO];
            [self.btnNext setEnabled:NO];
            [self.btnPlay setEnabled:NO];
            [self.btnChangeParams setEnabled:NO];
            NSLog(@"Tracks acquired.");
            
            if ([self.player isPlaying])
            {
                [self.btnNext setEnabled:YES];
            }
            
            self.currentSongNumber = 2 + arc4random() % self.tracks.count - 2;
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
    
    NSString *resourceURL = @"https://api.soundcloud.com/me/favorites.json";
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:nil
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:nil
             responseHandler:handler];
}

- (IBAction)playSong:(id)sender
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

- (IBAction)playNext:(id)sender
{
    NSInteger randomNumber = 2 + arc4random() % self.tracks.count - 2;
    self.currentSongNumber = randomNumber;
    NSDictionary *track = [self.tracks objectAtIndex:randomNumber];
    [self.btnNext setEnabled:NO];
    [self.btnPlay setEnabled:NO];
    [self.btnChangeParams setEnabled:NO];
    [self getTrackInfo:track shouldPlay:YES];

    NSLog(@"Playing next song");
}

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

- (void)getTrackInfo:(NSDictionary *)track shouldPlay:(BOOL)play
{
    NSString *streamURL = [track objectForKey:@"stream_url"];
    SCAccount *account = [SCSoundCloud account];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
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
                 [self.player prepareToPlay];
                 
                 if (play)
                 {
                     [self.player play];
                     [self.btnPlay setImage:[UIImage imageNamed:@"pause_btn.png"] forState:UIControlStateNormal];
                 }
                 
                 [self.btnNext setEnabled:YES];
                 [self.btnPlay setEnabled:YES];
                 [self.btnChangeParams setEnabled:YES];
                 [self.lblSongTitle setText:[track objectForKey:@"title"]];
                 long duration = [[track objectForKey:@"duration"] longValue];
                 [self.lblLength setText:[self convertFromMilliseconds:duration]];
                 NSDictionary *userInfo = [track objectForKey:@"user"];
                 [self.lblArtist setText:[userInfo objectForKey:@"username"]];
                 
                 NSURL *imgUrl = nil;
                 id albumArt = [track objectForKey:@"artwork_url"];
                 if (albumArt == [NSNull null])
                 {
                     imgUrl = [NSURL URLWithString:[userInfo objectForKey:@"avatar_url"]];
                 }
                 else
                 {
                     imgUrl = [NSURL URLWithString:(NSString *)albumArt];
                 }
                 
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                     NSData *imageData = [NSData dataWithContentsOfURL:imgUrl];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         // Update the UI
                         self.imgArtwork.image = [UIImage imageWithData:imageData];
                     });
                 });
                 
                 [hud hide:YES];
             }];

}

@end
