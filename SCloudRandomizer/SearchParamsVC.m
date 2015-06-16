//
//  SearchParamsVC.m
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 1/12/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

#import "SearchParamsVC.h"
#import "Utility.h"
#import <QuartzCore/QuartzCore.h>

static const double OffsetForKeyboard = 90.0;

@interface SearchParamsVC ()

@property BOOL areKeywordsValid;
@property BOOL areDurationValuesValid;
@property BOOL areBPMValuesValid;
@property (strong, nonatomic) SearchParams *searchParams;
@property (strong, nonatomic) UITextView *activeField;

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
    
    // Add inner shadows to each UITextView
    [self addInnerShadowToTextView:self.txtKeywords];
    [self addInnerShadowToTextView:self.txtDurationFrom];
    [self addInnerShadowToTextView:self.txtDurationTo];
    [self addInnerShadowToTextView:self.txtBpmTo];
    [self addInnerShadowToTextView:self.txtBpmFrom];
    
    // Add self as delegate for txtViews
    self.txtBpmFrom.delegate = self;
    self.txtBpmTo.delegate = self;
    self.txtDurationFrom.delegate = self;
    self.txtDurationTo.delegate = self;
    self.txtKeywords.delegate = self;
    
    // Used to hide keyboard when user taps view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    // Add done button to numberpad
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.txtDurationFrom.inputAccessoryView = numberToolbar;
    self.txtDurationTo.inputAccessoryView = numberToolbar;
    self.txtBpmFrom.inputAccessoryView = numberToolbar;
    self.txtBpmTo.inputAccessoryView = numberToolbar;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set defaults
    self.areKeywordsValid = YES;
    self.areDurationValuesValid = YES;
    self.areBPMValuesValid = YES;
    [self.txtKeywords setBackgroundColor:[UIColor whiteColor]];
    [self.txtDurationFrom setBackgroundColor:[UIColor whiteColor]];
    [self.txtDurationTo setBackgroundColor:[UIColor whiteColor]];
    [self.txtBpmFrom setBackgroundColor:[UIColor whiteColor]];
    [self.txtBpmTo setBackgroundColor:[UIColor whiteColor]];
    
    // Create strong local ref to delegate
    id<MainVCDelegate> strongDelegate = self.delegate;
    self.searchParams = [strongDelegate getCurrentSearchParams];
    
    // Disable cancel button if no tracks available
    if (![strongDelegate areTracksAvailable]) {
        self.btnCancel.enabled = NO;
    }
    
    // Fill in the values
    self.txtKeywords.text = self.searchParams.keywords;
    self.txtDurationFrom.text = (self.searchParams.durationFrom == 0) ? @"" : [NSString stringWithFormat: @"%ld",
                                                                               (long)self.searchParams.durationFrom];
    self.minDurationStepper.value = self.searchParams.durationFrom;
    self.txtDurationTo.text = (self.searchParams.durationTo == 0) ? @"" : [NSString stringWithFormat: @"%ld",
                                                                           (long)self.searchParams.durationTo];
    self.maxDurationStepper.value = (self.searchParams.durationTo == 0) ? self.searchParams.durationFrom : self.searchParams.durationTo;

    self.txtBpmFrom.text = (self.searchParams.lowBpm == 0) ? @"" : [NSString stringWithFormat: @"%ld", (long)self.searchParams.lowBpm];
    self.minBpmStepper.value = self.searchParams.lowBpm;
    self.txtBpmTo.text = (self.searchParams.highBpm == 0) ? @"" : [NSString stringWithFormat: @"%ld", (long)self.searchParams.highBpm];
    self.maxBpmStepper.value = (self.searchParams.highBpm == 0) ? self.searchParams.lowBpm : self.searchParams.highBpm;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender {
    [self dismissKeyboard];
    
    if (!self.areKeywordsValid) {
        [self showAlertWithTitle:@"Need Keyword(s)" message:@"Please enter some keywords!"];
    } else if(!self.areDurationValuesValid) {
        [self showAlertWithTitle:@"Bad Duration Range" message:@"Please make sure the duration range is valid!"];
    } else if(!self.areBPMValuesValid) {
        [self showAlertWithTitle:@"Bad BPM Range" message:@"Please make sure the BPM range is valid!"];
    } else if (self.areKeywordsValid && self.areDurationValuesValid && self.areBPMValuesValid) {
        self.searchParams.hasChanged = YES;
        self.searchParams.keywords = self.txtKeywords.text;
        self.searchParams.lowBpm = ([self.txtBpmFrom.text isEqualToString:@""]) ? 0 : [self.txtBpmFrom.text intValue];
        self.searchParams.highBpm = ([self.txtBpmTo.text isEqualToString:@""]) ? 0 : [self.txtBpmTo.text intValue];
        self.searchParams.durationFrom = ([self.txtDurationFrom.text isEqualToString:@""]) ? 0 : [self.txtDurationFrom.text intValue];
        self.searchParams.durationTo = ([self.txtDurationTo.text isEqualToString:@""]) ? 0 : [self.txtDurationTo.text intValue];
        self.btnCancel.enabled = YES;
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeMinDuration:(id)sender {
    [self dismissKeyboard];
    self.txtDurationFrom.text = [NSString stringWithFormat:@"%.f", self.minDurationStepper.value];
    
    if (self.maxDurationStepper.value < self.minDurationStepper.value && [Utility stringIsNilOrEmpty:self.txtDurationTo.text]) {
        self.maxDurationStepper.value = self.minDurationStepper.value;
    }

    [self checkValues];
}

- (IBAction)changeMaxDuration:(id)sender {
    [self dismissKeyboard];
    self.txtDurationTo.text = [NSString stringWithFormat:@"%.f", self.maxDurationStepper.value];
    [self checkValues];
}

- (IBAction)changeMinBpm:(id)sender {
    [self dismissKeyboard];
    self.txtBpmFrom.text = [NSString stringWithFormat:@"%.f", self.minBpmStepper.value];
    
    if (self.maxBpmStepper.value < self.minBpmStepper.value && [Utility stringIsNilOrEmpty:self.txtBpmTo.text]) {
        self.maxBpmStepper.value = self.minBpmStepper.value;
    }
    
    [self checkValues];
}

- (IBAction)changeMaxBpm:(id)sender {
    [self dismissKeyboard];
    self.txtBpmTo.text = [NSString stringWithFormat:@"%.f", self.maxBpmStepper.value];
    [self checkValues];
}

- (void)dismissKeyboard {
    [self.txtKeywords resignFirstResponder];
    [self.txtBpmTo resignFirstResponder];
    [self.txtBpmFrom resignFirstResponder];
    [self.txtDurationFrom resignFirstResponder];
    [self.txtDurationTo resignFirstResponder];
}

- (void)doneWithNumberPad{
    [self dismissKeyboard];
}

- (void)showAlertWithTitle:(NSString *)alertTitle message:(NSString *)alertMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (!self.areKeywordsValid) {
        [self.txtKeywords becomeFirstResponder];
    } else if (!self.areBPMValuesValid) {
        [self.txtBpmTo becomeFirstResponder];
    } else if (!self.areDurationValuesValid) {
        [self.txtDurationTo becomeFirstResponder];
    }
}

- (void)addInnerShadowToTextView:(UITextView *)textView {
    [textView.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [textView.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [textView.layer setBorderWidth: 1.0];
    [textView.layer setCornerRadius:6.0f];
    [textView.layer setMasksToBounds:NO];
    [textView.layer setShadowRadius:2.0f];
    textView.layer.shadowColor = [[UIColor blackColor] CGColor];
    textView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    textView.layer.shadowOpacity = 10.0f;
    textView.layer.shadowRadius = 1.0f;
}

// Move the view up/down whenever the keyboard is shown/dismissed
- (void)setViewMovedUp:(BOOL)movedUp {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= OffsetForKeyboard;
        rect.size.height += OffsetForKeyboard;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += OffsetForKeyboard;
        rect.size.height -= OffsetForKeyboard;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

// Check duration and BPM values
- (void)checkValues {
    if ([Utility stringIsNilOrEmpty:self.txtKeywords.text]) {
        self.areKeywordsValid = NO;
        [self.txtKeywords setBackgroundColor:[UIColor colorWithRed:240/255.0 green:81/255.0 blue:81/255.0 alpha:1]];
    } else {
        self.areKeywordsValid = YES;
        [self.txtKeywords setBackgroundColor:[UIColor whiteColor]];
    }
    
    if(!([self.txtDurationTo.text isEqualToString:@""]) &&
       ([self.txtDurationTo.text intValue] < [self.txtDurationFrom.text intValue]))
    {
        self.areDurationValuesValid = NO;
        [self.txtDurationFrom setBackgroundColor:[UIColor colorWithRed:240/255.0 green:81/255.0 blue:81/255.0 alpha:1]];
        [self.txtDurationTo setBackgroundColor:[UIColor colorWithRed:240/255.0 green:81/255.0 blue:81/255.0 alpha:1]];
    } else {
        self.areDurationValuesValid = YES;
        [self.txtDurationFrom setBackgroundColor:[UIColor whiteColor]];
        [self.txtDurationTo setBackgroundColor:[UIColor whiteColor]];
    }
    
    if(!([self.txtBpmTo.text isEqualToString:@""]) &&
       ([self.txtBpmTo.text intValue] < [self.txtBpmFrom.text intValue]))
    {
        self.areBPMValuesValid = NO;
        [self.txtBpmFrom setBackgroundColor:[UIColor colorWithRed:240/255.0 green:81/255.0 blue:81/255.0 alpha:1]];
        [self.txtBpmTo setBackgroundColor:[UIColor colorWithRed:240/255.0 green:81/255.0 blue:81/255.0 alpha:1]];
    } else {
        self.areBPMValuesValid = YES;
        [self.txtBpmFrom setBackgroundColor:[UIColor whiteColor]];
        [self.txtBpmTo setBackgroundColor:[UIColor whiteColor]];
    }
}

#pragma MARK - UITextViewDelegate method

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    // Do not allow enter/newline key
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textField {
    if (textField == self.txtBpmFrom || textField == self.txtBpmTo) {
        if (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
        else if (self.view.frame.origin.y < 0)
        {
            [self setViewMovedUp:NO];
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textField {
    if (textField == self.txtBpmFrom || textField == self.txtBpmTo) {
        if (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
        else if (self.view.frame.origin.y < 0)
        {
            [self setViewMovedUp:NO];
        }
    }
    
    if (textField == self.txtDurationFrom) {
        self.minDurationStepper.value = [textField.text doubleValue];
    }
    
    if (textField == self.txtDurationTo) {
        self.maxDurationStepper.value = [textField.text doubleValue];
    }
    
    if (textField == self.txtBpmFrom) {
        self.minBpmStepper.value = [textField.text doubleValue];
    }
    
    if (textField == self.txtBpmTo) {
        self.maxBpmStepper.value = [textField.text doubleValue];
    }
    
    [self checkValues];
}

@end
