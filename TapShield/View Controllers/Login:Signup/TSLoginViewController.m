//
//  TSLoginViewController.m
//  TapShield
//
//  Created by Adam Share on 2/14/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSLoginViewController.h"
#import "TSForgotPasswordViewController.h"

@interface TSLoginViewController ()

@end

@implementation TSLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[TSJavelinAPIClient sharedClient] authenticationManager].delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self addBottomButtons];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addBottomButtons {
    
    _forgotPasswordButton = [self buttonWithTitle:@"Forgot password?" selector:@selector(forgotPassword:)];
    _noAccountButton = [self buttonWithTitle:@"No account?" selector:@selector(backToSignUp:)];
    
    CGRect forgotFrame = _forgotPasswordButton.frame;
    forgotFrame.origin.x = _scrollView.frame.size.width - forgotFrame.size.width - 20;
    _forgotPasswordButton.frame = forgotFrame;
    
    CGRect noAccountframe = _noAccountButton.frame;
    noAccountframe.origin.x = 20;
    _noAccountButton.frame = noAccountframe;
    
    [_scrollView addSubview:_forgotPasswordButton];
    [_scrollView addSubview:_noAccountButton];
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

- (IBAction)backToSignUp:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)forgotPassword:(id)sender {
    
    TSForgotPasswordViewController *viewcontroller = (TSForgotPasswordViewController *)[[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSForgotPasswordViewController class])];
    viewcontroller.email = _emailTextField.text;
    [self.navigationController pushViewController:viewcontroller animated:YES];
}

- (void)shakeButton {
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.08f];
    [animation setRepeatCount:4.0f];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([_loginButton center].x - 20.0f, [_loginButton center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([_loginButton center].x + 20.0f, [_loginButton center].y)]];
    [[_loginButton layer] addAnimation:animation forKey:@"position"];
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
    
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
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
    if (textField == _emailTextField) {
        [_passwordTextField becomeFirstResponder];
    }
    else if (_loginButton.enabled){
        [self performSelector:@selector(loginUser:) withObject:nil];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (_emailTextField.text.length > 1 && _passwordTextField.text.length > 1) {
        [_loginButton setEnabled:YES];
    }
    else {
        [_loginButton setEnabled:NO];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [_loginButton setEnabled:NO];
    return YES;
}

#pragma mark - Log In

- (IBAction)loginUser:(id)sender {
    
    _errorLabel.text = @"";
    [self.navigationItem.backBarButtonItem setEnabled:NO];
    [_loginButton setEnabled:NO];
    
    _emailTextField.text = [_emailTextField.text lowercaseString];
    [[[TSJavelinAPIClient sharedClient] authenticationManager] logInUser:_emailTextField.text password:_passwordTextField.text completion:^(TSJavelinAPIUser *user) {
        if (user) {
            NSLog(@"Now we're logged in!");
        }
    }];
}


- (void)logInFailedWithMessage:(NSString *)messageToUser {
    
    _errorLabel.text = messageToUser;
    
    [self shakeButton];
}

#pragma mark - TSJavelinAuthenticationManager Delegate

- (void)loginSuccessful:(TSJavelinAPIAuthenticationResult *)result {
    
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginFailed:(TSJavelinAPIAuthenticationResult *)result {
    
    [self.navigationItem.backBarButtonItem setEnabled:YES];
    [_loginButton setEnabled:YES];
    
    NSString *message = @"Login Failed";
    
    if (result.loginFailureReason == kTSJavelinAPIAuthenticationManagerLoginFailureInactiveAccount) {
        message = @"Your account is inactive. Please contact your administrator.";
    }
    else if (result.loginFailureReason == kTSJavelinAPIAuthenticationManagerLoginFailureInvalidCredentials) {
        message = @"Incorrect Email or Password.";
    }
    [self logInFailedWithMessage:message];
}

@end
