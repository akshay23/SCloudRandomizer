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
    
    // Draw border around both buttons
    self.btnClose.layer.cornerRadius = 4;
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
    
    long duration = [[track objectForKey:@"duration"] longValue];
    long likes = [[track objectForKey:@"favoritings_count"] longValue];
    long plays = [[track objectForKey:@"playback_count"] longValue];
    NSString *desc = [track objectForKey:@"description"];
    NSString *uploaded = [track objectForKey:@"created_at"];
    
    if ([desc isEqualToString:@""])
    {
        desc = @"No description";
    }

    [self.txtTitle scrollRangeToVisible:NSMakeRange(0, 0)];
    [self.txtTitle setText:[track objectForKey:@"title"]];
    [self.txtArtist setText:[[track objectForKey:@"user"] objectForKey:@"username"]];
    [self.txtDuration setText:[self convertFromMilliseconds:duration]];
    [self.txtLikes setText:[[NSNumber numberWithLong:likes] stringValue]];
    [self.txtPlays setText:[[NSNumber numberWithLong:plays] stringValue]];
    [self.txtDesc scrollRangeToVisible:NSMakeRange(0, 0)];
    [self.txtDesc setText:desc];
    [self.txtUploaded setText:[uploaded substringToIndex:10]];
    [self.txtTags scrollRangeToVisible:NSMakeRange(0, 0)];
    [self.txtTags setText:[track objectForKey:@"tag_list"]];
    
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

@end
