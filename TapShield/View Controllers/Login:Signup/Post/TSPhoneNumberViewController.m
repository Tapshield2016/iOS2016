//
//  TSPhoneNumberViewController.m
//  TapShield
//
//  Created by Adam Share on 8/19/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSPhoneNumberViewController.h"
#import "TSAddSecondaryViewController.h"
#import "TSUserSessionManager.h"

#ifdef DEV
#import "TapShield_Dev-Swift.h"
#else
#import "TapShield-Swift.h"
#endif

static NSString * const kResendSMS = @"Re-send Verification SMS";
static NSString * const kSMSSent = @"We've sent you a verification code to";
static NSString * const kEnterPhoneNumber = @"Please enter your 10-digit number";

@interface TSPhoneNumberViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation TSPhoneNumberViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [TSColorPalette listBackgroundColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    if ([TSJavelinAPIClient loggedInUser].phoneNumber.length) {
        
        _phoneNumberTextField.text = [TSJavelinAPIClient loggedInUser].phoneNumber;
        _sendVerificationButton.enabled = YES;
        
        if ([_phoneNumberTextField.text numeric].length == 10) {
            _phoneNumberTextField.text = [self formatPhoneNumber:_phoneNumberTextField.text];
        }
        
        if (self.navigationController.viewControllers.count > 1) {
            [self smsWasSent];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self removeSecondaryEmailVC];
}

- (void)removeSecondaryEmailVC {
    
    NSMutableArray *mutable = [[NSMutableArray alloc] initWithCapacity:self.navigationController.viewControllers.count];
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if (![vc isKindOfClass:[TSAddSecondaryViewController class]]) {
            [mutable addObject:vc];
        }
    }
    
    [self.navigationController setViewControllers:mutable];
    
    if (self.navigationController.viewControllers.count == 1) {
        [self addCancelButton];
    }
}

- (void)addCancelButton {
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
}

- (void)cancel {
    
    [[TSUserSessionManager sharedManager] dismissWindowWithAnimationType:kAlertWindowAnimationTypeDown completion:nil];
}

- (void)applicationWillEnterForeground {
    
    [_codeTextField becomeFirstResponder];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if ([pasteboard.string numeric].length == 4) {
        // Do something
        _codeTextField.text = [pasteboard.string numeric];
        [_codeTextField resignFirstResponder];
    }
}

- (void)smsWasSent {
    
    if (_codeView.hidden) {
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _sendButtonTopLayout.constant = _sendVerificationButton.frame.size.height*4;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3 animations:^{
                    for (UIView *view in self.view.subviews) {
                        if (view.hidden) {
                            view.hidden = NO;
                        }
                        view.alpha = 1.0;
                    }
                    [_sendVerificationButton setTitle:kResendSMS forState:UIControlStateNormal];
                }];
            }];
    }
    
//    [_codeTextField becomeFirstResponder];
    
    _topLabel.text = kSMSSent;
    _topLabel.textColor = [TSColorPalette activeTextColor];
}

- (IBAction)sendVerification:(id)sender {
    
    [self sendVerificationCodeTo:[_phoneNumberTextField.text numeric]];
}


- (void)sendVerificationCodeTo:(NSString *)phoneNumber {
    
    _sendVerificationButton.enabled = NO;
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] sendPhoneNumberVerificationRequest:phoneNumber completion:^(id responseObject, NSError *error) {
        _sendVerificationButton.enabled = YES;
        if (!error) {
            [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].phoneNumber = phoneNumber;
            [[TSJavelinAPIAuthenticationManager sharedManager] updateLoggedInUser:nil];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self smsWasSent];
            }];
        }
        else {
            _topLabel.text = @"Failed to send verification code";
            if ([responseObject objectForKey:@"message"]) {
                _topLabel.text = [responseObject objectForKey:@"message"];
            }
            _topLabel.textColor = [TSColorPalette alertRed];
            [self incorrectShakeView:_phoneNumberTextField];
//            [_phoneNumberTextField becomeFirstResponder];
        }
    }];
}


#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    _topLabel.text = kEnterPhoneNumber;
    _topLabel.textColor = [TSColorPalette activeTextColor];
}

- (void)dismissKeyboard {
    [[self.view findFirstResponder] resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    [textField superview].backgroundColor = [UIColor whiteColor];
    
    if (_codeTextField == textField) {
        
        if ([textField.text length] + [string length] - range.length == 4) {
            textField.text = [textField.text stringByAppendingString:string];
            [textField resignFirstResponder];
            return NO;
        }
        else if ([textField.text length] + [string length] - range.length > 4) {
            return NO;
        }
    }
    else if (_phoneNumberTextField == textField) {
        NSString *afterString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (afterString.length == 0) {
            _sendVerificationButton.enabled = NO;
        }
        else {
            _sendVerificationButton.enabled = YES;
        }
        
        NSString *alphaNumericString = [textField.text numeric];
        if ([string isEqualToString:@""]) {
            
            if ([alphaNumericString length] == 4) {
                textField.text = [textField.text numeric];
            }
            if ([alphaNumericString length] == 7) {
                textField.text = [textField.text substringToIndex:[textField.text length]-1];
            }
            return YES;
        }
        
        if ([alphaNumericString length] == 3) {
            textField.text = [NSString stringWithFormat:@"(%@) ",textField.text];
        }
        
        if ([alphaNumericString length] == 6) {
            textField.text = [NSString stringWithFormat:@"%@-",textField.text];
        }
        NSUInteger newTextFieldTextLength = [alphaNumericString length] + [string length] - range.length;
        if (newTextFieldTextLength > 10) {
            textField.text = [@"+" stringByAppendingString:[[textField.text stringByReplacingCharactersInRange:range withString:string] numeric]];
            return NO;
        }
    }
    
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (_phoneNumberTextField == textField) {
        
        if ([textField.text numeric].length == 10) {
            textField.text = [self formatPhoneNumber:textField.text];
        }
    }
    else if (_codeTextField == textField) {
        
        if (textField.text.length == 4) {
            [self verifyCode];
        }
    }
}


#pragma mark - TextField Utilities

- (NSString *)formatPhoneNumber:(NSString *)rawString {
    
    NSMutableString *mutableNumber = [NSMutableString stringWithString:[rawString numeric]];
    [mutableNumber insertString:@"-" atIndex:6];
    [mutableNumber insertString:@") " atIndex:3];
    [mutableNumber insertString:@"(" atIndex:0];
    return mutableNumber;
}

- (void)incorrectShakeView:(UIView *)view {
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.08f];
    [animation setRepeatCount:4.0f];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([view center].x - 20.0f, [view center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([view center].x + 20.0f, [view center].y)]];
    [[view layer] addAnimation:animation forKey:@"position"];
    
    view.superview.backgroundColor = [TSColorPalette colorByAdjustingColor:[TSColorPalette alertRed] Alpha:0.1f];
}


#pragma mark - Activity Indicator

- (void)startCodeVerificationIndicator {
    
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [_codeTextField.rightView addSubview:_activityIndicatorView];
    }
    
    
    [_activityIndicatorView startAnimating];
    [UIView animateWithDuration:0.1f animations:^{
        _activityIndicatorView.alpha = 1.0f;
    }];
}

- (void)stopCodeVerificationIndicator {
    [_activityIndicatorView stopAnimating];
    [UIView animateWithDuration:0.1f animations:^{
        _activityIndicatorView.alpha = 0.0f;
    }];
}


#pragma mark - Network Requests

- (void)verifyCode {
    
    [self startCodeVerificationIndicator];
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] checkPhoneVerificationCode:_codeTextField.text completion:^(id responseObject, NSError *error) {
        if (!error) {
            [self stopCodeVerificationIndicator];
            
            [[TSUserSessionManager sharedManager] didJoinFromSelectedAgency];
            [[TSUserSessionManager sharedManager] dismissWindowWithAnimationType:kAlertWindowAnimationTypeDown completion:nil];
            
            _codeTextField.text = @"";
        }
        else {
            [self stopCodeVerificationIndicator];
            [self incorrectShakeView:_codeTextField];
            _topLabel.text = @"Phone number verification failed";
            if ([responseObject objectForKey:@"message"]) {
                _topLabel.text = [responseObject objectForKey:@"message"];
            }
            _topLabel.textColor = [TSColorPalette alertRed];
        }
    }];
}

@end
