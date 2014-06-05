//
//  TSDisarmPadViewController.m
//  TapShield
//
//  Created by Adam Share on 3/4/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSDisarmPadViewController.h"
#import "TSPageViewController.h"

@interface TSDisarmPadViewController ()

@property (strong, nonatomic) TSPageViewController *pageViewController;
@property (assign, nonatomic) NSUInteger failAttempts;
@property (strong, nonatomic) UIAlertView *passwordAttemptAlertView;
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

- (void)setSuperviewViewController:(UIViewController *)superviewViewController {
    
    _superviewViewController = superviewViewController;
    
    if ([superviewViewController isKindOfClass:[TSPageViewController class]]) {
        _pageViewController = (TSPageViewController *)superviewViewController;
    }
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
    for (TSCircularButton *circle in _codeCircleArray) {
        
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
    
    _passwordAttemptAlertView = [[UIAlertView alloc] initWithTitle:@"Forgot your passcode?"
                                                    message:@"Enter your account password"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Forgot Password", @"Disarm", nil];
    _passwordAttemptAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [_passwordAttemptAlertView textFieldAtIndex:0];
    [textField setPlaceholder:@"password"];
    [textField setTextAlignment:NSTextAlignmentLeft];
    [textField setSecureTextEntry:YES];
    [textField setKeyboardType:UIKeyboardTypeASCIICapable];
    [textField setKeyboardAppearance:UIKeyboardAppearanceLight];
    [textField setDelegate:self];
    
    [_passwordAttemptAlertView show];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView == _passwordAttemptAlertView) {
        
        switch (buttonIndex) {
            case 0:
                
                break;
                
            case 1:
                [self sendPasswordReset];
                break;
                
            case 2:
                [self checkPassword:[alertView textFieldAtIndex:0].text];
                break;
                
            default:
                break;
        }
    }
    else {
        [self disarmViaPassword];
    }
}

- (void)checkPassword:(NSString *)password {
    
    if (_didSendReset) {
        [self loginWithPassword:password];
    }
    else {
        if ([[[[TSJavelinAPIClient sharedClient] authenticationManager] getPasswordForEmailAddress:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].email] isEqualToString:password]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Change Passcode"
                                                                message:@"Go to 'Settings' in the side menu to change your passcode"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            [self disarm];
        }
        else {
            [self disarmViaPassword];
        }
    }
}

- (void)disarm {
    [[TSAlertManager sharedManager] disarmAlert];
    [[TSJavelinAPIClient sharedClient] disarmAlert];
    [[TSJavelinAPIClient sharedClient] cancelAlert];
    
    [_pageViewController.homeViewController mapAlertModeToggle];
    [_pageViewController.toolbar setTranslucent:NO];
    [_pageViewController.toolbar setAlpha:0.5f];
    [_pageViewController.homeViewController viewWillAppear:NO];
    [_pageViewController.homeViewController viewDidAppear:NO];
    [_pageViewController.homeViewController whiteNavigationBar];
    [_pageViewController dismissViewControllerAnimated:YES completion:nil];
    
    if ([TSVirtualEntourageManager sharedManager].isEnabled &&
        ![TSVirtualEntourageManager sharedManager].endTimer) {
        [[TSVirtualEntourageManager sharedManager] recalculateEntourageTimerETA];
    }
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
        
        UIAlertView *emailSentAlert = [[UIAlertView alloc] initWithTitle:title
                                                                 message:nil
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
        [emailSentAlert show];
    }];
}


@end
