//
//  TrackInfoVC.m
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 2/26/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import "TrackInfoVC.h"
#import "Track.h"

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<MainVCDelegate> strongDelegate = self.delegate;
    Track *track = [strongDelegate getCurrentTrack];
    

    NSString* songDescription = track.songDescription;
    if ([songDescription length] == 0) {
        songDescription = @"No description";
    }
    
    [self.songDescription setText:songDescription];
    [self.songTitle setText:track.title];
    [self.artist setText:track.artist];
    [self.likes setText: [[NSNumber numberWithLong:track.likes] stringValue]];
    [self.numOfPlays setText: [[NSNumber numberWithLong:track.plays] stringValue]];
    
    [self.uploadedTime
      setText: [NSString stringWithFormat: @"Uploaded on %@", [track.uploadedOn substringToIndex:10]]];
    
    NSString* tags = track.tags;
    if ([tags length] == 0) {
        [self.tags setText:@"None"];
    } else {
        [self.tags setText:tags];
    }
    
    NSLog(@"Track details displayed!");
}

- (IBAction)close:(id)sender {
    // Custom animation
    CATransition *animation = [CATransition animation];
    animation.duration = 0.3;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromLeft;
    
    [self.view.window.layer addAnimation:animation forKey:kCATransition];
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
