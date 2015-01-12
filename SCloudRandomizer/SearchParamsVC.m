//
//  SearchParamsVC.m
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 1/12/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import "SearchParamsVC.h"

@interface SearchParamsVC ()

@end

@implementation SearchParamsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Draw border around both buttons
    self.btnCancel.layer.cornerRadius = 2;
    self.btnCancel.layer.borderWidth = 1;
    self.btnCancel.layer.borderColor = [UIColor blueColor].CGColor;
    self.btnSave.layer.cornerRadius = 2;
    self.btnSave.layer.borderWidth = 1;
    self.btnSave.layer.borderColor = [UIColor blueColor].CGColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender
{
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
