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
    
    self.view.backgroundColor = [TSColorPalette listBackgroundColor];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(completeVerification:)];
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
            
            [[[TSJavelinAPIClient sharedClient] authenticationManager] logInUser:_user.email password:_user.password completion:^(TSJavelinAPIUser *user) {
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
