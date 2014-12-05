//
//  MainViewController.m
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 12/4/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize player;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Disable/enable SC buttons if user is currently logged in
    if ([SCSoundCloud account] != nil)
    {
        [self.btnSCConnect setHidden:YES];
        [self.btnSCDisconnect setHidden:NO];
        [self.btnGetTracks setHidden:NO];
    }
    else
    {
        [self.btnSCConnect setHidden:NO];
        [self.btnSCDisconnect setHidden:YES];
        [self.btnGetTracks setHidden:YES];
        [self.btnPlay setHidden:YES];
        [self.btnNext setHidden:YES];
    }
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
    [self.btnGetTracks setHidden:YES];
    [self.btnPlay setHidden:YES];
    [self.btnNext setHidden:YES];
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
                                                                              NSLog(@"Logged in.");
                                                                          }
                                                                      }];
        
        [self presentViewController:loginViewController animated:YES completion:nil];
    }];
}

- (IBAction)getTracks:(id)sender
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tracks" message:@"Tracks acquired" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [self.btnPlay setHidden:NO];
            [self.btnNext setHidden:NO];
            [self.btnNext setEnabled:NO];
            NSLog(@"Tracks acquired.");
            
            if ([self.player isPlaying])
            {
                [self.btnNext setEnabled:YES];
            }
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not get your tracks! Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            NSLog(@"Could not get tracks.");
        }
    };
    
    NSString *resourceURL = @"https://api.soundcloud.com/me/tracks.json";
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
        if (self.player.data == nil)
        {
            NSDictionary *track = [self.tracks objectAtIndex:0];
            NSString *streamURL = [track objectForKey:@"stream_url"];
            
            SCAccount *account = [SCSoundCloud account];
            
            [SCRequest performMethod:SCRequestMethodGET
                          onResource:[NSURL URLWithString:streamURL]
                     usingParameters:nil
                         withAccount:account
              sendingProgressHandler:nil
                     responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                         NSError *playerError;
                         player = [[AVAudioPlayer alloc] initWithData:data error:&playerError];
                         [player prepareToPlay];
                         [player play];
                         [self.btnNext setEnabled:YES];
                         [self.btnPlay setImage:[UIImage imageNamed:@"pause_btn.png"] forState:UIControlStateNormal];
            }];
        }
        else
        {
            [self.player play];
            [self.btnPlay setImage:[UIImage imageNamed:@"pause_btn.png"] forState:UIControlStateNormal];
        }
    }
    else
    {
        [self.btnPlay setImage:[UIImage imageNamed:@"play_btn.png"] forState:UIControlStateNormal];
        [self.player pause];
    }
}

- (IBAction)playNext:(id)sender
{
    NSInteger randomNumber = 2 + arc4random() % self.tracks.count - 2;
    NSDictionary *track = [self.tracks objectAtIndex:randomNumber];
    NSString *streamURL = [track objectForKey:@"stream_url"];
    
    SCAccount *account = [SCSoundCloud account];
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:streamURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                 NSError *playerError;
                 player = [[AVAudioPlayer alloc] initWithData:data error:&playerError];
                 [player prepareToPlay];
                 [player play];
                 [self.btnNext setEnabled:YES];
                 [self.btnPlay setImage:[UIImage imageNamed:@"pause_btn.png"] forState:UIControlStateNormal];
    }];
}

@end
