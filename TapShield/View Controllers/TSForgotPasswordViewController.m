//
//  TSForgotPasswordViewController.m
//  TapShield
//
//  Created by Adam Share on 5/1/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSForgotPasswordViewController.h"

@interface TSForgotPasswordViewController ()

@end

@implementation TSForgotPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _emailTextField.text = _email;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self addBottomButtons];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    if (_emailTextField.text.length > 1) {
        [_resetButton setEnabled:YES];
    }
    else {
        [_resetButton setEnabled:NO];
    }
    
    _errorLabel.numberOfLines = 1;
    _errorLabel.textColor = [TSColorPalette alertRed];
    [_errorLabel setAdjustsFontSizeToFitWidth:YES];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splash_logo_small"]];
    imageView.frame = _shimmeringView.bounds;
    imageView.contentMode = UIViewContentModeCenter;
    _shimmeringView.contentView = imageView;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    _scrollView.contentSize = self.view.bounds.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addBottomButtons {
    
    TSBaseButton *leftButton = [self buttonWithTitle:@"Log in" selector:@selector(backToLogin:)];
    TSBaseButton *rightButton = [self buttonWithTitle:@"Sign up" selector:@selector(backToSignUp:)];
    
    CGRect frame = rightButton.frame;
    frame.origin.x = _scrollView.frame.size.width - frame.size.width - 20;
    rightButton.frame = frame;
    
    frame = leftButton.frame;
    frame.origin.x = 20;
    leftButton.frame = frame;
    
    [_scrollView addSubview:leftButton];
    [_scrollView addSubview:rightButton];
    _scrollView.contentSize = [UIScreen mainScreen].bounds.size;
}

- (TSBaseButton *)buttonWithTitle:(NSString *)name selector:(SEL)selector {
    
    TSBaseButton *button = [[TSBaseButton alloc] initWithFrame:CGRectZero fontSize:17];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:name forState:UIControlStateNormal];
    [button sizeToFit];
    
    CGRect frame = button.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - 1.25*frame.size.height;
    button.frame = frame;
    
    return button;
}

- (IBAction)backToLogin:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backToSignUp:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)sendPasswordReset:(id)sender {
    
    _shimmeringView.shimmering = YES;
    
    if (self.emailTextField.text) {
        [[[TSJavelinAPIClient sharedClient] authenticationManager] sendPasswordResetEmail:[self.emailTextField.text lowercaseString] completion:^(BOOL sent) {
            
            NSString *title;
            if (sent) {
                title = @"Reset email sent to:";
                _errorLabel.textColor = [TSColorPalette tapshieldBlue];
            }
            else {
                title = @"Failed sending reset email to:";
                _errorLabel.textColor = [TSColorPalette alertRed];
            }
            
            title = [NSString stringWithFormat:@"%@\n\n%@", title, _emailTextField.text];
            
//            NSDictionary *attributes = @{ NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue]};
//            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:title
//                                                   attributes:nil];
//            
//            NSRange range = [title rangeOfString:_emailTextField.text];
//            [attributedText setAttributes:attributes range:range];
            
            
            _shimmeringView.shimmering = NO;
//            _errorLabel.text = message;
            
            UIAlertView *emailSentAlert = [[UIAlertView alloc] initWithTitle:title
                                                                     message:@"\nIf you don't receive an email, please make sure you've entered the address you registered with."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
            [emailSentAlert show];
        }];
    }
}


#pragma mark - Keyboard

- (void)dismissKeyboard {
    [[self.view findFirstResponder] resignFirstResponder];
}


- (void)keyboardWillShow:(NSNotification *)notification {
    
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0f, 0.0f, keyboardBounds.size.height, 0.0f);
    
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardBounds.size.height;
    if (!CGRectContainsPoint(aRect, [self.view findFirstResponder].superview.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, [self.view findFirstResponder].superview.frame.origin.y - keyboardBounds.size.height);
        [_scrollView setContentOffset:scrollPoint];
    }
    
    [UIView commitAnimations];
    
    [_scrollView setScrollEnabled:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
    
    [_scrollView setScrollEnabled:NO];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (_resetButton.enabled){
        [self performSelector:@selector(sendPasswordReset:) withObject:nil];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (_emailTextField.text.length > 1) {
        [_resetButton setEnabled:YES];
    }
    else {
        [_resetButton setEnabled:NO];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [_resetButton setEnabled:NO];
    return YES;
}
@end
