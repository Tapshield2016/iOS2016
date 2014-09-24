//
//  TSDisarmPadViewController.m
//  TapShield
//
//  Created by Adam Share on 3/4/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSDisarmPadViewController.h"
#import "TSPageViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface TSDisarmPadViewController ()

@property (assign, nonatomic) NSUInteger failAttempts;
@property (assign, nonatomic) BOOL didSendReset;

@end

@implementation TSDisarmPadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _didSendReset = NO;
    
    _failAttempts = 0;
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    _codeCircleArray = @[_codeCircle1, _codeCircle2, _codeCircle3, _codeCircle4];
    
    _disarmTextField.text = @"";
    
    if (![self touchIDAvailable]) {
        [_touchIDButton setTitle:@"Disarm with account password" forState:UIControlStateNormal];
        [_touchIDButton setImage:nil forState:UIControlStateNormal];
        [_touchIDButton setTitleEdgeInsets:UIEdgeInsetsZero];
    }
    else {
        [_touchIDButton setTitle:@"Disarm with Touch ID" forState:UIControlStateNormal];
    }
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
    
    [self blackNavigationBar];
}

#pragma mark - Disarm Code

- (IBAction)numberPressed:(id)sender {
    
    if (_disarmTextField.text) {
        _disarmTextField.text = [NSString stringWithFormat:@"%@%@", _disarmTextField.text, ((UIButton *)sender).titleLabel.text];
    }
    else {
        _disarmTextField.text = ((UIButton *)sender).titleLabel.text;
    }
    
    [self selectCodeCircles];
    
    [self checkDisarmCode];
}

- (IBAction)clearDisarmText:(id)sender {
    
    _disarmTextField.text = @"";
    
    [self selectCodeCircles];
}

- (IBAction)deleteDisarmText:(id)sender {
    
    if ([_disarmTextField.text length] > 0) {
        _disarmTextField.text = [_disarmTextField.text substringToIndex:_disarmTextField.text.length - 1];
    }
    
    [self selectCodeCircles];
}

- (void)selectCodeCircles {
    int i = 1;
    for (TSCircularButton *circle in [_codeCircleArray copy]) {
        
        if (_disarmTextField.text.length < i) {
            circle.selected = NO;
        }
        else {
            circle.selected = YES;
        }
        i++;
    }
}

- (void)checkDisarmCode {
    
    if (_disarmTextField.text.length != 4) {
        return;
    }
    
    if ([_disarmTextField.text isEqualToString:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].disarmCode]) {
        [self disarm];
    }
    else {
        _failAttempts++;
        [self shakeDisarmCircles];
        _disarmTextField.text = @"";
        [self performSelector:@selector(selectCodeCircles) withObject:nil afterDelay:0.08 * 4];
        
        if (_failAttempts > 4) {
            [self disarmViaPassword];
        }
    }
}

- (void)disarmViaPassword {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter Account Password"
                                                                             message:@"Go to 'Settings' in the side menu to change your passcode"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:@"password"];
        [textField setTextAlignment:NSTextAlignmentLeft];
        [textField setSecureTextEntry:YES];
        [textField setKeyboardType:UIKeyboardTypeASCIICapable];
        [textField setKeyboardAppearance:UIKeyboardAppearanceLight];
        [textField setDelegate:self];
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Disarm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self checkPassword:((UITextField *)alertController.textFields[0]).text];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Forgot Password" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self sendPasswordReset];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)checkPassword:(NSString *)password {
    
    if (_didSendReset) {
        [self loginWithPassword:password];
    }
    else {
        if ([[[[TSJavelinAPIClient sharedClient] authenticationManager] getPasswordForEmailAddress:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].email] isEqualToString:password]) {
            
            UIAlertController *errorController = [UIAlertController alertControllerWithTitle:@"Please Change Passcode"
                                                                                     message:@"Go to 'Settings' in the side menu to change your passcode"
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            [errorController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:errorController animated:YES completion:nil];
            
            [self disarm];
        }
        else {
            [self disarmViaPassword];
        }
    }
}

- (void)disarm {
    [[TSAlertManager sharedManager] disarmAlert];
    
    TSPageViewController *pageViewController = (TSPageViewController *)self.parentViewController;
    [pageViewController.homeViewController mapAlertModeToggle];
    [pageViewController.homeViewController whiteNavigationBar];
    [pageViewController.homeViewController.reportManager showSpotCrimes];
}

#pragma mark - Animations

- (void)shakeDisarmCircles {
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.08f];
    [animation setRepeatCount:2.0f];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([_codeCircleContainerView center].x - 20.0f, [_codeCircleContainerView center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([_codeCircleContainerView center].x + 20.0f, [_codeCircleContainerView center].y)]];
    [[_codeCircleContainerView layer] addAnimation:animation forKey:@"position"];
}



#pragma mark - Authentication

- (void)loginWithPassword:(NSString *)password {
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] logInUser:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].email password:password completion:^(TSJavelinAPIUser *user) {
        if (user) {
            [self disarm];
        }
        else {
            [self disarmViaPassword];
        }
    }];
}

- (void)sendPasswordReset {
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] sendPasswordResetEmail:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].email completion:^(BOOL sent) {
        
        NSString *title;
        if (sent) {
            title = @"Reset email sent to:";
            _didSendReset = YES;
        }
        else {
            title = @"Failed sending reset email to:";
        }
        
        title = [NSString stringWithFormat:@"%@\n\n%@", title, [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].email];
        
        UIAlertController *errorController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        [errorController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self disarmViaPassword];
        }]];
        [self presentViewController:errorController animated:YES completion:nil];
    }];
}


#pragma mark - Touch ID

- (IBAction)useTouchID:(id)sender {
    
    _touchIDButton.enabled = NO;
    
    LAContext *context = [[LAContext alloc] init];
    
    if ([self touchIDAvailable]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:@"Disarm alert"
                          reply:^(BOOL success, NSError *error) {
                              
                              [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                  if (error) {
                                      
                                      if (error.code == kLAErrorUserCancel ||
                                          error.code == kLAErrorSystemCancel) {
                                          
                                      }
                                      else if (error.code == kLAErrorUserFallback) {
                                          [self disarmViaPassword];
                                      }
                                      else {
                                          UIAlertController *errorController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                                          [errorController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
                                          [self presentViewController:errorController animated:YES completion:nil];
                                      }
                                  }
                                  else if (success) {
                                      _disarmTextField.text = [TSJavelinAPIClient loggedInUser].disarmCode;
                                      [self selectCodeCircles];
                                      [self disarm];
                                  }
                                  _touchIDButton.enabled = YES;
                              }];
                          }];
        
    }
    else {
        
        [self disarmViaPassword];
        
        _touchIDButton.enabled = YES;
        
//        UIAlertController *errorController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Touch ID not available at this time."preferredStyle:UIAlertControllerStyleAlert];
//        [errorController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
//        [self presentViewController:errorController animated:YES completion:nil];
        
    }
}

- (BOOL)touchIDAvailable {
    
    LAContext *context = [[LAContext alloc] init];
    NSError *error;
    
    return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
}

@end
