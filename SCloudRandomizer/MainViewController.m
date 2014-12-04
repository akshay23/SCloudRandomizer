//
//  MainViewController.m
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 12/4/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (strong, nonatomic) SCAccount *account;

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
    if (self.account != nil)
    {
        [self.btnSCConnect setHidden:YES];
        [self.btnSCDisconnect setHidden:NO];
        [self.btnGetTracks setHidden:NO];
        [self.btnPlay setHidden:NO];
    }
    else
    {
        [self.btnSCConnect setHidden:NO];
        [self.btnSCDisconnect setHidden:YES];
        [self.btnGetTracks setHidden:YES];
        [self.btnPlay setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender
{
    self.account = nil;
    [self.btnSCConnect setHidden:NO];
    [self.btnSCDisconnect setHidden:YES];
    [self.btnGetTracks setHidden:YES];
    [self.btnPlay setHidden:YES];
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
                                                                              self.account = [SCSoundCloud account];
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
            NSLog(@"Tracks acquired.");
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
                 withAccount:self.account
      sendingProgressHandler:nil
             responseHandler:handler];
}

- (IBAction)playSong:(id)sender
{
}

@end
