//
//  TSPhoneVerificationViewController.m
//  TapShield
//
//  Created by Adam Share on 2/18/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSPhoneVerificationViewController.h"

@interface TSPhoneVerificationViewController ()

@end

@implementation TSPhoneVerificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [_resendButton setBackgroundImage:[UIImage imageFromColor:[TSColorPalette tapshieldBlue]] forState:UIControlStateNormal];
    [_resendButton setBackgroundImage:[UIImage imageHighlightedFromColor:[TSColorPalette tapshieldBlue]] forState:UIControlStateHighlighted];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    _phoneNumberTextField.text = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].phoneNumber;
    [self sendVerificationCodeTo:_phoneNumberTextField.text];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applicationWillEnterForeground {
    
    [_verificationCodeTextField becomeFirstResponder];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if ([self removeNonNumericalCharacters:pasteboard.string].length == 4) {
        // Do something
        _verificationCodeTextField.text = pasteboard.string;
        [_verificationCodeTextField resignFirstResponder];
    }
}


- (IBAction)resendSMS:(id)sender {
    
    [self sendVerificationCodeTo:_phoneNumberTextField.text];
}


#pragma mark - TextField Delegate

- (void)dismissKeyboard {
    [[self.view findFirstResponder] resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    [textField superview].backgroundColor = [UIColor whiteColor];
    
    if (_verificationCodeTextField == textField) {
        
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
        NSString *alphaNumericTextField = [self removeNonNumericalCharacters:textField.text];
        if ([string isEqualToString:@""]) {
            if ([alphaNumericTextField length] == 4) {
                textField.text = [self removeNonNumericalCharacters:textField.text];
            }
            if ([alphaNumericTextField length] == 7) {
                textField.text = [textField.text substringToIndex:[textField.text length]-1];
            }
            return YES;
        }
        if ([alphaNumericTextField length] == 3) {
            textField.text = [NSString stringWithFormat:@"(%@) ",textField.text];
        }
        
        if ([alphaNumericTextField length] == 6) {
            textField.text = [NSString stringWithFormat:@"%@-",textField.text];
        }
        NSUInteger newTextFieldTextLength = [alphaNumericTextField length] + [string length] - range.length;
        if (newTextFieldTextLength > 10) {
            return NO;
        }
    }
    
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (_phoneNumberTextField == textField) {
        
        if ([self removeNonNumericalCharacters:textField.text].length == 10) {
            textField.text = [self formatPhoneNumber:textField.text];
        }
        
        textField.textColor = [TSColorPalette whiteColor];
        [self phoneIconSelected:NO];
        [UIView animateWithDuration:0.1f animations:^{
            _phoneNumberBackgroundView.alpha = 1.0f;
        }];
    }
    else if (_verificationCodeTextField == textField) {
        
        if (textField.text.length == 4) {
            [self verifyCode];
        }
    }
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (_phoneNumberTextField == textField) {
        textField.textColor = [TSColorPalette blackColor];
        [self phoneIconSelected:YES];
        
        [UIView animateWithDuration:0.1f animations:^{
            _phoneNumberBackgroundView.alpha = 0.0f;
        }];
    }
    
}


#pragma mark - TextField Utilities

- (NSString *)removeNonNumericalCharacters:(NSString *)phoneNumber {
    
    NSCharacterSet *charactersToRemove = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    return phoneNumber;
}

- (NSString *)formatPhoneNumber:(NSString *)rawString {
    
    NSMutableString *mutableNumber = [NSMutableString stringWithString:[self removeNonNumericalCharacters:rawString]];
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
    
    view.superview.backgroundColor = [TSColorPalette colorByAdjustingColor:[TSColorPalette redColor] Alpha:0.1f];
}

- (void)phoneIconSelected:(BOOL)editing {
    UIImage *selectedImage = _iPhoneImageView.image;
    
    if (!editing) {
        _iPhoneImageView.image = [UIImage imageNamed:@"iPhoneIcon"];
        return;
    }
    
    //image color change
    CGRect rect = CGRectMake(0, 0, _iPhoneImageView.frame.size.width, _iPhoneImageView.frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, selectedImage.CGImage);
    CGContextSetFillColorWithColor(context, [[TSColorPalette darkGrayColor] CGColor]);
    CGContextFillRect(context, rect);
    selectedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _iPhoneImageView.image = [UIImage imageWithCGImage:selectedImage.CGImage scale:1.0f orientation: UIImageOrientationDownMirrored];
}

#pragma mark - Activity Indicator

- (void)startCodeVerificationIndicator {
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
    
    _errorLabel.text = @"";
    
    [self startCodeVerificationIndicator];
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] checkPhoneVerificationCode:_verificationCodeTextField.text completion:^(id responseObject) {
        if (!responseObject) {
            [self stopCodeVerificationIndicator];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [self stopCodeVerificationIndicator];
            [self incorrectShakeView:_verificationCodeTextField];
            _errorLabel.text = @"Phone number verification failed";
            if ([responseObject objectForKey:@"message"]) {
                _errorLabel.text = [responseObject objectForKey:@"message"];
            }
        }
    }];
}


- (void)sendVerificationCodeTo:(NSString *)phoneNumber {
    
    _errorLabel.text = @"";
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] sendPhoneNumberVerificationRequest:phoneNumber completion:^(id responseObject) {
        if (!responseObject) {
            [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].phoneNumber = phoneNumber;
        }
        else {
            _errorLabel.text = @"Failed to send verification code";
                if ([responseObject objectForKey:@"message"]) {
                    _errorLabel.text = [responseObject objectForKey:@"message"];
                }
            [self incorrectShakeView:_phoneNumberTextField];
            [_phoneNumberTextField becomeFirstResponder];
        }
    }];
}

@end
