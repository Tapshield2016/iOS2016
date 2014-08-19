//
//  TSAddSecondaryViewController.m
//  TapShield
//
//  Created by Adam Share on 8/15/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAddSecondaryViewController.h"
#import "TSJavelinAPIEmail.h"

static NSString * const kResendEmail = @"Re-send Verification Email";
static NSString * const kEmailSent = @"We've sent you a verification link to";
static NSString * const kEnterEmail = @"Enter your organization's email address";
static NSString * const kPleaseEnterEmail = @"Enter your %@ email address";

@interface TSAddSecondaryViewController ()

@end

@implementation TSAddSecondaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _topLabel.text = [NSString stringWithFormat:kPleaseEnterEmail, _agency.domain];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)emailWasSent {
    
    if (_completeButton.hidden) {
        [UIView animateWithDuration:0.3 animations:^{
            for (UIView *view in self.view.subviews) {
                view.hidden = NO;
            }
            
            [_resendButton setTitle:kResendEmail forState:UIControlStateNormal];
            CGRect frame = _resendButton.frame;
            frame.origin.y = _bottomLabel.frame.origin.y + _bottomLabel.frame.size.height;
            _resendButton.frame = frame;
        }];
    }
    
    _topLabel.text = kEmailSent;
}

- (void)emailWasVerified {
    
    
}

- (IBAction)completeVerification:(id)sender {
    [[TSJavelinAPIAuthenticationManager sharedManager] isSecondaryEmailVerified:_emailTextField.text completion:^(BOOL verified, NSString *errorMessage) {
        if (verified) {
            [self emailWasVerified];
        }
        else {
            _topLabel.text = errorMessage;
            _topLabel.textColor = [TSColorPalette alertRed];
        }
    }];
}

- (IBAction)sendVerification:(id)sender {

    TSJavelinAPIEmail *secEmail = [[TSJavelinAPIClient loggedInUser] hasSecondaryEmail:_emailTextField.text];
    if (secEmail) {
        if (secEmail.isActive) {
            [self emailWasVerified];
        }
        else {
            [[TSJavelinAPIAuthenticationManager sharedManager] resendSecondaryEmailActivation:_emailTextField.text completion:^(BOOL success, NSString *errorMessage) {
                if (success) {
                    [self emailWasSent];
                }
                else {
                    _topLabel.text = errorMessage;
                    _topLabel.textColor = [TSColorPalette alertRed];
                }
            }];
        }
        
        return;
    }
    
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] addSecondaryEmail:_emailTextField.text completion:^(BOOL success, NSString *errorMessage) {
        if (success) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self emailWasSent];
            }];
        }
        else {
            _topLabel.text = errorMessage;
            _topLabel.textColor = [TSColorPalette alertRed];
        }
    }];
}

#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    _topLabel.text = kEnterEmail;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.text.length > 1) {
        _resendButton.enabled = YES;
        _completeButton.enabled = YES;
    }
    
    return YES;
}


@end
