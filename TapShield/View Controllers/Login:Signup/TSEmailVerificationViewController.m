//
//  TSEmailVerificationViewController.m
//  TapShield
//
//  Created by Adam Share on 2/18/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEmailVerificationViewController.h"
#import "TSJavelinAPIAuthenticationManager.h"
#import "TSPhoneVerificationViewController.h"

@interface TSEmailVerificationViewController ()

@end

@implementation TSEmailVerificationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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
    
    [_resendEmailButton setBackgroundImage:[UIImage imageFromColor:[TSColorPalette tapshieldBlue]] forState:UIControlStateNormal];
    [_resendEmailButton setBackgroundImage:[UIImage imageHighlightedFromColor:[TSColorPalette tapshieldBlue]] forState:UIControlStateHighlighted];
    [_completeVerificationButton setBackgroundImage:[UIImage imageFromColor:[TSColorPalette tapshieldDarkBlue]] forState:UIControlStateNormal];
    [_completeVerificationButton setBackgroundImage:[UIImage imageHighlightedFromColor:[TSColorPalette tapshieldDarkBlue]] forState:UIControlStateHighlighted];
    
    _emailAddressLabel.text = _email;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)segueToPhoneVerification {
    
    _errorMessageLabel.text = @"";
    
    if ([[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].phoneNumberVerified) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
         TSPhoneVerificationViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TSPhoneVerificationViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}


- (void)checkForEmailVerificationAndLogIn {
    
    _errorMessageLabel.text = @"";
    
    if ([[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].isEmailVerified) {
        [self segueToPhoneVerification];
        return;
    }
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] isLoggedInUserEmailVerified:^(BOOL success) {
        if (success) {
            if ([[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser]) {
                [self segueToPhoneVerification];
                return;
            }
            
            [[[TSJavelinAPIClient sharedClient] authenticationManager] logInUser:_email password:_password completion:^(TSJavelinAPIUser *user) {
                if (user) {
                    [self segueToPhoneVerification];
                }
            }];
        }
        else {
            _errorMessageLabel.text = @"Email has not been verified.";
        }
    }];
}

- (IBAction)completeVerification:(id)sender {
    
    [self checkForEmailVerificationAndLogIn];
}

- (IBAction)resendVerification:(id)sender {
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] resendVerificationEmailForEmailAddress:_email completion:^(BOOL success) {
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
