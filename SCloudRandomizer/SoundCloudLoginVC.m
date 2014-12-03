//
//  SoundCloudLoginVC.m
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 12/3/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "SoundCloudLoginVC.h"

@interface SoundCloudLoginVC ()

@property (strong, nonatomic) SCAccount *account;

@end

@implementation SoundCloudLoginVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender
{
    if (self.account != nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logged in" message:@"You have already logged in!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        NSLog(@"Already logged in!");
    }
    else
    {
        [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
            
            SCLoginViewController *loginViewController;
            loginViewController = [SCLoginViewController loginViewControllerWithPreparedURL:preparedURL
                                                                          completionHandler:^(NSError *error){
                                                                              
                                                                              if (SC_CANCELED(error)) {
                                                                                  NSLog(@"Canceled!");
                                                                              } else if (error) {
                                                                                  NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
                                                                              } else {
                                                                                  self.account = [SCSoundCloud account];
                                                                                  NSLog(@"Done!");
                                                                              }
                                                                          }];
            
            [self presentViewController:loginViewController animated:YES completion:nil];
            
        }];
    }
}
@end
