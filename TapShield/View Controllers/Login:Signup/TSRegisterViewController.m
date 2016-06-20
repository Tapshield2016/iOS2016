//
//  TSRegisterViewController.m
//  TapShield
//
//  Created by Adam Share on 2/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRegisterViewController.h"
#import "TSEmailVerificationViewController.h"

@interface TSRegisterViewController ()

@end

@implementation TSRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requiresDomainName:)
                                                 name:kTSJavelinAPIAuthenticationManagerDidFailToRegisterUserRequiresDomain
                                               object:nil];
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Up" style:UIBarButtonItemStylePlain target:self action:@selector(registerUser:)];
    self.navigationItem.rightBarButtonItem = nextButton;

    if (self.navigationController.viewControllers.count <= 1) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissRegistration:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    _containerView.backgroundColor = [TSColorPalette listBackgroundColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [_scrollView addGestureRecognizer:tap];
    
    
    
    if (_user) {
        _emailTextField.text = _user.email;
        _passwordTextField.text = _user.password;
//        _phoneNumberTextField.text = _user.phoneNumber;
    }
    else {
        _user = [[TSJavelinAPIUser alloc] init];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSArray *textFieldArray = @[_emailTextField, _passwordTextField];
    ;
    
    for (UITextField *textField in textFieldArray) {
        if (!textField.text || textField.text.length == 0) {
            [textField becomeFirstResponder];
            break;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController respondsToSelector:@selector(setUser:)]) {
            [viewController performSelector:@selector(setUser:) withObject:_user];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requiresDomainName:(NSNotification *)note {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ requires an %@ email address", _user.agency.name, _user.agency.domain]
                                                                             message:@"Please register with your organization's email account or deselect this organization to continue"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}


#pragma mark - Button

- (IBAction)dismissRegistration:(id)sender {
    
    [self.view.findFirstResponder resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }];
}

- (IBAction)registerUser:(id)sender {
    
    if (![self hasCompletedRequiredFieldsForRegistration]) {
        return;
    }
    
    _user.email = _emailTextField.text;
    _user.password = _passwordTextField.text;
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] registerUser:_user completion:^(id responseObject) {
        NSLog(@"%@", responseObject);
        [self parseResponseObject:responseObject];
    }];
}

- (void)parseResponseObject:(id)responseObject {
    
    if ([[responseObject objectForKey:@"email"] isKindOfClass:[NSString class]]) {
        if ([[responseObject objectForKey:@"email"] isEqualToString:_emailTextField.text]) {
            [self segueToEmailVerification];
            return;
        }
    }
    
    NSString *title = @"Sign up request failed";
    NSString *errorMessage = @"Check network connection and try again";
    
    
    NSArray *resultsArray = [(NSDictionary *)responseObject allValues];
    if (resultsArray) {
        if ([[resultsArray firstObject] isKindOfClass:[NSArray class]]) {
            errorMessage = [[resultsArray firstObject] firstObject];
        }
    }
    
    if ([responseObject objectForKey:@"email"]) {
        _emailView.backgroundColor = [TSColorPalette colorByAdjustingColor:[TSColorPalette alertRed] Alpha:0.1f];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:errorMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void)segueToEmailVerification {
    
    TSRegisterViewController *emailVerificationViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSEmailVerificationViewController class])];
    if (_user) {
        emailVerificationViewController.user = _user;
    }
    
    [self.navigationController pushViewController:emailVerificationViewController animated:YES];
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
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0f, keyboardBounds.size.height, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
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

    [UIView commitAnimations];
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
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    
    [UIView commitAnimations];
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    [textField superview].backgroundColor = [UIColor whiteColor];
    
    if (_phoneNumberTextField == textField) {
        NSString *alphaNumericTextField = [TSUtilities removeNonNumericalCharacters:textField.text];
        if ([string isEqualToString:@""]) {
            if ([alphaNumericTextField length] == 4) {
                textField.text = [TSUtilities removeNonNumericalCharacters:textField.text];
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
        textField.text = [TSUtilities formatPhoneNumber:textField.text];
    }
    
    _user.email = _emailTextField.text;
    _user.password = _passwordTextField.text;
    _user.phoneNumber = _phoneNumberTextField.text;
}


#pragma mark - TextField Utilities

- (void)checkEmailTextfieldForValidEmail {
    
    if ([_emailTextField.text rangeOfString:@"@"].location == NSNotFound ||
        [_emailTextField.text rangeOfString:@"."].location == NSNotFound) {
        
    }
}

- (BOOL)hasCompletedRequiredFieldsForRegistration{
    
    BOOL isValid = YES;
    

    if ([_emailTextField.text rangeOfCharacterFromSet: [NSCharacterSet alphanumericCharacterSet]].location == NSNotFound) {
        isValid = NO;
        _emailView.backgroundColor = [TSColorPalette colorByAdjustingColor:[TSColorPalette alertRed] Alpha:0.1f];
    }
    if ([_passwordTextField.text rangeOfCharacterFromSet: [NSCharacterSet alphanumericCharacterSet]].location == NSNotFound) {
        isValid = NO;
        _passwordView.backgroundColor = [TSColorPalette colorByAdjustingColor:[TSColorPalette alertRed] Alpha:0.1f];
    }
//    if ([[TSUtilities removeNonNumericalCharacters:_phoneNumberTextField.text] length] != 10) {
//        isValid = NO;
//        _phoneView.backgroundColor = [TSColorPalette colorByAdjustingColor:[TSColorPalette alertRed] Alpha:0.1f];
//    }

    
    return isValid;
}




@end
