//
//  TrackInfoVC.m
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 2/26/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import "TrackInfoVC.h"

@interface TrackInfoVC ()

@end

@implementation TrackInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Draw border around both buttons
    self.btnClose.layer.cornerRadius = 2;
    self.btnClose.layer.borderWidth = 1;
    self.btnClose.layer.borderColor = [UIColor blueColor].CGColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id<MainVCDelegate> strongDelegate = self.delegate;
    NSDictionary *track = [strongDelegate getCurrentTrack];
    
    [self.txtTitle setText:[track objectForKey:@"title"]];
    [self.txtArtist setText:[[track objectForKey:@"user"] objectForKey:@"username"]];
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
