//
//  SearchParamsVC.m
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 1/12/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import "SearchParamsVC.h"
#import "Utility.h"

@interface SearchParamsVC ()

@property (strong, nonatomic) SearchParams *searchParams;

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
    self.btnClear.layer.cornerRadius = 2;
    self.btnClear.layer.borderWidth = 1;
    self.btnClear.layer.borderColor = [UIColor blueColor].CGColor;
    
    // Used to hide keyboard when user taps view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Create strong local ref to delegate
    id<MainVCDelegate> strongDelegate = self.delegate;
    self.searchParams = [strongDelegate getCurrentSearchParams];
    
    self.txtKeywords.text = self.searchParams.keywords;
    self.txtDurationFrom.text = (self.searchParams.durationFrom == 0) ? @"" : [NSString stringWithFormat: @"%ld", (long)self.searchParams.durationFrom];
    self.txtDurationTo.text = (self.searchParams.durationTo == 0) ? @"" : [NSString stringWithFormat: @"%ld", (long)self.searchParams.durationTo];
    self.txtBpmFrom.text = (self.searchParams.lowBpm == 0) ? @"" : [NSString stringWithFormat: @"%ld", (long)self.searchParams.lowBpm];
    self.txtBpmTo.text = (self.searchParams.highBpm == 0) ? @"" : [NSString stringWithFormat: @"%ld", (long)self.searchParams.highBpm];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender {
    [self dismissKeyboard];
    
    if(!([self.txtBpmTo.text isEqualToString:@""]) &&
       ([self.txtBpmTo.text intValue] < [self.txtBpmFrom.text intValue]))
    {
        [self showAlertAndFocusOnTextView:self.txtBpmTo title:@"Bad BPM Range" message:@"Please make sure the BPM range is valid!"];
    }
    else if(!([self.txtDurationTo.text isEqualToString:@""]) &&
            ([self.txtDurationTo.text intValue] < [self.txtDurationFrom.text intValue]))
    {
        [self showAlertAndFocusOnTextView:self.txtDurationTo title:@"Bad Duration Range"
                                  message:@"Please make sure the duration range is valid!"];
    }
    else if ([Utility stringIsNilOrEmpty:self.txtKeywords.text])
    {
        [self showAlertAndFocusOnTextView:self.txtKeywords title:@"Need Keyword(s)" message:@"Please enter some keywords!"];
    }
    else if (![Utility stringIsNilOrEmpty:self.txtKeywords.text])
    {
        self.searchParams.hasChanged = YES;
        self.searchParams.keywords = self.txtKeywords.text;
        self.searchParams.lowBpm = ([self.txtBpmFrom.text isEqualToString:@""]) ? 0 : [self.txtBpmFrom.text intValue];
        self.searchParams.highBpm = ([self.txtBpmTo.text isEqualToString:@""]) ? 0 : [self.txtBpmTo.text intValue];
        self.searchParams.durationFrom = ([self.txtDurationFrom.text isEqualToString:@""]) ? 0 : [self.txtDurationFrom.text intValue];
        self.searchParams.durationTo = ([self.txtDurationTo.text isEqualToString:@""]) ? 0 : [self.txtDurationTo.text intValue];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clearFields:(id)sender {
    self.txtBpmTo.text = @"";
    self.txtBpmFrom.text = @"";
    self.txtDurationTo.text = @"";
    self.txtDurationFrom.text = @"";
    self.txtKeywords.text = @"";
}

- (void)dismissKeyboard {
    [self.txtKeywords resignFirstResponder];
    [self.txtBpmTo resignFirstResponder];
    [self.txtBpmFrom resignFirstResponder];
    [self.txtDurationFrom resignFirstResponder];
    [self.txtDurationTo resignFirstResponder];
}

- (void)showAlertAndFocusOnTextView:(UITextView *)textView title:(NSString *)alertTitle message:(NSString *)alertMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    textView.text = @"";
    [textView becomeFirstResponder];
}

@end
