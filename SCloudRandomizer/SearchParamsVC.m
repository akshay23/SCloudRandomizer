//
//  SearchParamsVC.m
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 1/12/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import "SearchParamsVC.h"

@interface SearchParamsVC ()

@property (strong, nonatomic) SearchParams *searchParams;

@end

@implementation SearchParamsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Draw border around both buttons
    self.btnCancel.layer.cornerRadius = 2;
    self.btnCancel.layer.borderWidth = 1;
    self.btnCancel.layer.borderColor = [UIColor blueColor].CGColor;
    self.btnSave.layer.cornerRadius = 2;
    self.btnSave.layer.borderWidth = 1;
    self.btnSave.layer.borderColor = [UIColor blueColor].CGColor;
    
    // Used to hide keyboard when user taps view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Create strong local ref to delegate
    id<MainVCDelegate> strongDelegate = self.delegate;
    self.searchParams = [strongDelegate getCurrentSearchParams];
    
    self.txtKeywords.text = self.searchParams.keywords;
    self.txtBpmFrom.text = [self.searchParams.lowBpm stringValue];
    self.txtBpmTo.text = [self.searchParams.highBpm stringValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender
{
    [self dismissKeyboard];
    
    if (![GlobalData stringIsNilOrEmpty:self.txtKeywords.text])
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        self.searchParams.hasParamsChanged = YES;
        self.searchParams.keywords = self.txtKeywords.text;
        self.searchParams.lowBpm = [formatter numberFromString:self.txtBpmFrom.text];
        self.searchParams.highBpm = [formatter numberFromString:self.txtBpmTo.text];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Need Keyword(s)" message:@"Please enter some keywords!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [self.txtKeywords becomeFirstResponder];
    }
}

- (IBAction)cancel:(id)sender
{
    [self dismissKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissKeyboard
{
    [self.txtKeywords resignFirstResponder];
    [self.txtBpmTo resignFirstResponder];
    [self.txtBpmFrom resignFirstResponder];
}

@end
