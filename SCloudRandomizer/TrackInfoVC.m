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

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    long duration = [[track objectForKey:@"duration"] longValue];
    long likes = [[track objectForKey:@"favoritings_count"] longValue];
    long plays = [[track objectForKey:@"playback_count"] longValue];
    NSString *desc = [track objectForKey:@"description"];
    NSString *uploaded = [track objectForKey:@"created_at"];
    
    if ([desc isEqualToString:@""])
    {
        desc = @"No description";
    }

    [self.songTitle setText:[track objectForKey:@"title"]];
    [self.songTitle sizeToFit];
    
    [self.artist setText:[[track objectForKey:@"user"] objectForKey:@"username"]];
    [self.likes setText: [[NSNumber numberWithLong:likes] stringValue]];
    [self.numOfPlays setText: [[NSNumber numberWithLong:plays] stringValue]];
    [self.songDescription setText:desc];
    
    [self.uploadedTime
      setText: [NSString stringWithFormat: @"Uploaded at %@", [uploaded substringToIndex:10]]];
    
    [self.tags setText:[track objectForKey:@"tag_list"]];
    
    NSLog(@"Track details displayed!");
}

- (IBAction)close:(id)sender
{
    // Custom animation
    CATransition *animation = [CATransition animation];
    animation.duration = 0.3;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromLeft;
    
    [self.view.window.layer addAnimation:animation forKey:kCATransition];
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
