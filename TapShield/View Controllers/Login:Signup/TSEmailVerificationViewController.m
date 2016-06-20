//
//  TSEmailVerificationViewController.m
//  TapShield
//
//  Created by Adam Share on 2/18/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEmailVerificationViewController.h"
#import "TSJavelinAPIAuthenticationManager.h"
#import "TSUserSessionManager.h"

@interface TSEmailVerificationViewController ()

@end

@implementation TSEmailVerificationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [TSColorPalette listBackgroundColor];
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Complete" style:UIBarButtonItemStylePlain target:self action:@selector(completeVerification:)];
    self.navigationItem.rightBarButtonItem = nextButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(signUpDidFailToCreateConnectionForLogin:)
                                                 name:kTSJavelinAPIAuthenticationManagerDidFailToCreateConnectionToAuthURL
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(signUpDidFailToLogin:)
                                                 name:kTSJavelinAPIAuthenticationManagerDidFailToLogin
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(verificationFailure:)
                                                 name:kTSJavelinAPIAuthenticationManagerDidFailToVerifyUserNotification
                                               object:nil];
    
    _emailTextField.text = _user.email;
    _emailTextField.userInteractionEnabled = NO;
    
    [TSJavelinAPIAuthenticationManager sharedManager].delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)checkForEmailVerificationAndLogIn {
    
    _errorMessageLabel.text = @"";
    
    _completeVerificationButton.enabled = NO;
    [[self.navigationItem rightBarButtonItem] setEnabled:NO];
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] isLoggedInUserEmailVerified:^(BOOL success) {
        if (success) {
            if ([[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser]) {
                [self.view.findFirstResponder resignFirstResponder];
                [[TSUserSessionManager sharedManager] dismissWindow:^(BOOL finished) {
                    [[TSUserSessionManager sharedManager] userStatusCheck];
                }];
                return;
            }
            
            [[[TSJavelinAPIClient sharedClient] authenticationManager] logInUser:_user.email password:_user.password completion:^(TSJavelinAPIUser *user) {
                
                _completeVerificationButton.enabled = YES;
                
                if (user) {
                    [self.view.findFirstResponder resignFirstResponder];
                    [[TSUserSessionManager sharedManager] dismissWindow:^(BOOL finished) {
                        [[TSUserSessionManager sharedManager] userStatusCheck];
                    }];
                }
            }];
        }
        else {
            _errorMessageLabel.text = @"Email has not been verified.";
            _errorMessageLabel.textColor = [TSColorPalette alertRed];
            _completeVerificationButton.enabled = YES;
            [[self.navigationItem rightBarButtonItem] setEnabled:YES];
        }
    }];
}

- (IBAction)completeVerification:(id)sender {
    
    [self checkForEmailVerificationAndLogIn];
}

- (IBAction)resendVerification:(id)sender {
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] resendVerificationEmailForEmailAddress:_user.email completion:^(BOOL success) {
        if (success) {
            NSLog(@"Re-sent");
        }
        else {
            NSLog(@"Error Re-sending");
            _errorMessageLabel.text = @"Error re-sending verification email.";
        }
    }];
}


#pragma mark - Login Notifications

- (void)signUpDidFailToCreateConnectionForLogin:(NSNotification *)notification {

    NSLog(@"%@", [notification object]);
    _errorMessageLabel.text = @"Network error, please check connection and retry.";
}

- (void)signUpDidFailToLogin:(NSNotification *)notification {
    NSLog(@"%@", [notification object]);
    _errorMessageLabel.text = @"Could not complete verification, please try again";
}

- (void)verificationFailure:(NSNotification *)notification {
    _errorMessageLabel.text = @"Network error, please check connection and try again.";
}

@end
