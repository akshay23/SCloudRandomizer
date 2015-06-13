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

static const double OffsetForKeyboard = 70.0;

@interface SearchParamsVC ()

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
    self.btnClear.layer.cornerRadius = 2;
    self.btnClear.layer.borderWidth = 1;
    self.btnClear.layer.borderColor = [UIColor blueColor].CGColor;
    
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

//method to move the view up/down whenever the keyboard is shown/dismissed
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
    if (textField != self.txtKeywords) {
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
    if (textField != self.txtKeywords) {
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

@end
