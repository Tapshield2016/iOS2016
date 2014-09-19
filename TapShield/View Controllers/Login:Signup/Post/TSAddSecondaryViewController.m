//
//  TSAddSecondaryViewController.m
//  TapShield
//
//  Created by Adam Share on 8/15/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAddSecondaryViewController.h"
#import "TSJavelinAPIEmail.h"
#import "TSUserSessionManager.h"

static NSString * const kResendEmail = @"Re-send Verification Email";
static NSString * const kEmailSent = @"We've sent you a verification link to";
static NSString * const kEnterEmail = @"Enter your organization's email address";
static NSString * const kPleaseEnterEmail = @"Enter your %@ email address";
static NSString * const kDomainMatchEmail = @"You must enter a %@ email address";

@interface TSAddSecondaryViewController ()

@end

@implementation TSAddSecondaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _topLabel.text = [NSString stringWithFormat:kPleaseEnterEmail, _agency.domain];
    
    self.view.backgroundColor = [TSColorPalette listBackgroundColor];
    
    if (self.navigationController.viewControllers.count == 1) {
        [self addCancelButton];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    _topLabel.text = [NSString stringWithFormat:kPleaseEnterEmail, _agency.domain];
    
    for (TSJavelinAPIEmail *email in [TSJavelinAPIClient loggedInUser].secondaryEmails) {
        if ([_agency domainMatchesEmail:email.email] && !email.isActive) {
            _emailTextField.text = email.email;
            [self emailWasSent];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    
}

- (void)addCancelButton {
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
}

- (void)cancel {
    
    [[TSUserSessionManager sharedManager] dismissWindow:nil];
}


- (void)emailWasSent {
    
    if (_completeButton.hidden) {
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:300.0 initialSpringVelocity:5.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
            _sendButtonTopLayout.constant = _resendButton.frame.size.height*4;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                for (UIView *view in self.view.subviews) {
                    if (view.hidden) {
                        view.hidden = NO;
                    }
                    view.alpha = 1.0;
                }
                [_resendButton setTitle:kResendEmail forState:UIControlStateNormal];
            }];
        }];
    }
    
    _topLabel.text = kEmailSent;
    _topLabel.textColor = [TSColorPalette activeTextColor];
    [_emailTextField resignFirstResponder];
    _resendButton.enabled = YES;
}

- (void)emailWasVerified {
    
    if ([TSUserSessionManager shouldShowPhoneVerification]) {
        [TSUserSessionManager showPhoneVerification];
    }
    else if ([[TSUserSessionManager sharedManager] didJoinFromSelectedAgency]) {
        [[TSUserSessionManager sharedManager] dismissWindow:nil];
    }
}

- (void)domainMatchError {
    
    _topLabel.text = [NSString stringWithFormat:kDomainMatchEmail, _agency.domain];
    _topLabel.textColor = [TSColorPalette alertRed];
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

- (void)checkVerified {
    
    [[TSJavelinAPIAuthenticationManager sharedManager] isSecondaryEmailVerified:_emailTextField.text completion:^(BOOL verified, NSString *errorMessage) {
        if (verified) {
            [self emailWasVerified];
        }
    }];
}

- (IBAction)sendVerification:(id)sender {
    
    if (![_agency domainMatchesEmail:_emailTextField.text]) {
        [self domainMatchError];
        return;
    }

    TSJavelinAPIEmail *secEmail = [[TSJavelinAPIClient loggedInUser] hasSecondaryEmail:_emailTextField.text];
    if (secEmail) {
        if (secEmail.isActive) {
            [self emailWasVerified];
        }
        else {
            [[TSJavelinAPIAuthenticationManager sharedManager] resendSecondaryEmailActivation:_emailTextField.text completion:^(BOOL success, NSString *errorMessage) {
                if (success) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self emailWasSent];
                    }];
                }
                else {
                    _topLabel.text = errorMessage;
                    _topLabel.textColor = [TSColorPalette alertRed];
                    
                    [self checkVerified];
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
            
            [self checkVerified];
        }
    }];
}

#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    _topLabel.text = [NSString stringWithFormat:kPleaseEnterEmail, _agency.domain];
    _topLabel.textColor = [TSColorPalette activeTextColor];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *afterString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (afterString.length == 0) {
        _resendButton.enabled = NO;
    }
    else {
        _resendButton.enabled = YES;
        _completeButton.enabled = YES;
    }
    
    return YES;
}

- (void)dismissKeyboard {
    [[self.view findFirstResponder] resignFirstResponder];
}

@end
