//
//  TSForgotPasswordViewController.m
//  TapShield
//
//  Created by Adam Share on 5/1/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSForgotPasswordViewController.h"

@interface TSForgotPasswordViewController ()

@end

@implementation TSForgotPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _emailTextField.text = _email;
    
    [self addBottomButtons];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    if (_emailTextField.text.length > 1) {
        [_resetButton setEnabled:YES];
    }
    else {
        [_resetButton setEnabled:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    _scrollView.contentSize = self.view.bounds.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addBottomButtons {
    
    TSBaseButton *leftButton = [self buttonWithTitle:@"Log in" selector:@selector(backToLogin:)];
    TSBaseButton *rightButton = [self buttonWithTitle:@"Sign up" selector:@selector(backToSignUp:)];
    
    CGRect frame = rightButton.frame;
    frame.origin.x = _scrollView.frame.size.width - frame.size.width - 20;
    rightButton.frame = frame;
    
    frame = leftButton.frame;
    frame.origin.x = 20;
    leftButton.frame = frame;
    
    [_scrollView addSubview:leftButton];
    [_scrollView addSubview:rightButton];
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

- (IBAction)backToLogin:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backToSignUp:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)sendPasswordReset:(id)sender {
    
    if (self.emailTextField.text) {
        [[[TSJavelinAPIClient sharedClient] authenticationManager] sendPasswordResetEmail:[self.emailTextField.text lowercaseString] completion:^(BOOL sent) {
            
            NSString *message;
            if (sent) {
                message = @"Reset email sent to:";
            }
            else {
                message = @"Failed sending reset email to:";
            }
            
            UIAlertView *emailSentAlert = [[UIAlertView alloc] initWithTitle:message
                                                                     message:self.emailTextField.text
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
            [emailSentAlert show];
        }];
    }
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (_resetButton.enabled){
        [self performSelector:@selector(sendPasswordReset:) withObject:nil];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (_emailTextField.text.length > 1) {
        [_resetButton setEnabled:YES];
    }
    else {
        [_resetButton setEnabled:NO];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [_resetButton setEnabled:NO];
    return YES;
}
@end
