//
//  TSRegisterViewController.m
//  TapShield
//
//  Created by Adam Share on 2/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRegisterViewController.h"
#import "TSEmailVerificationViewController.h"
#import "TSRegistrationNavigationDelegate.h"

@interface TSRegisterViewController ()

@end

@implementation TSRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(registerUser:)];
    self.navigationItem.rightBarButtonItem = nextButton;
    
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
        _phoneNumberTextField.text = _user.phoneNumber;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSArray *textFieldArray = @[_phoneNumberTextField, _emailTextField, _passwordTextField];
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
    
    _user.email = _emailTextField.text;
    _user.password = _passwordTextField.text;
    _user.phoneNumber = _phoneNumberTextField.text;
    
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


#pragma mark - Button

- (IBAction)registerUser:(id)sender {
    
    if (![self hasCompletedRequiredFieldsForRegistration]) {
        return;
    }
    
    //Check to see if user already succesfully registerd with username and password
    NSString *storedPassword = [[[TSJavelinAPIClient sharedClient] authenticationManager] getPasswordForEmailAddress:[_emailTextField.text lowercaseString]];
    if (storedPassword) {
        if ([storedPassword isEqualToString:_passwordTextField.text]) {
            [[[TSJavelinAPIClient sharedClient] authenticationManager] setRegistrationRecoveryEmail:_emailTextField.text Password:storedPassword];
            [self segueToEmailVerification];
            return;
        }
    }
    
    _user.email = _emailTextField.text;
    _user.password = _passwordTextField.text;
    _user.phoneNumber = _phoneNumberTextField.text;
    
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
        _emailView.backgroundColor = [TSColorPalette colorByAdjustingColor:[TSColorPalette redColor] Alpha:0.1f];
    }
    
    UIAlertView *signupErrorAlert = [[UIAlertView alloc] initWithTitle:title
                                                               message:errorMessage
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
    [signupErrorAlert show];
}

- (void)segueToEmailVerification {
    
//    TSRegistrationNavigationController *navigationController = (TSRegistrationNavigationController *)self.navigationController;
//    
//    if (!navigationController.emailVerificationViewController) {
//        navigationController.emailVerificationViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TSEmailVerificationViewController"];
//        navigationController.emailVerificationViewController.email = [_emailTextField.text lowercaseString];
//        navigationController.emailVerificationViewController.password = _passwordTextField.text;
//    }
    
    
    [self pushViewControllerWithClass:[TSEmailVerificationViewController class] transitionDelegate:nil navigationDelegate:nil animated:YES];
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
    
//    if (_disarmCodeTextField == textField) {
//        
//        if ([textField.text length] + [string length] - range.length == 4) {
//            textField.text = [textField.text stringByAppendingString:string];
//            [textField resignFirstResponder];
//            return NO;
//        }
//        else if ([textField.text length] + [string length] - range.length > 4) {
//            return NO;
//        }
//    }
    if (_phoneNumberTextField == textField) {
        NSString *alphaNumericTextField = [self removeNonNumericalCharacters:textField.text];
        if ([string isEqualToString:@""]) {
            if ([alphaNumericTextField length] == 4) {
                textField.text = [self removeNonNumericalCharacters:textField.text];
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
        if ([self removeNonNumericalCharacters:textField.text].length == 10) {
            NSMutableString *mutableNumber = [NSMutableString stringWithString:[self removeNonNumericalCharacters:textField.text]];
            [mutableNumber insertString:@"-" atIndex:6];
            [mutableNumber insertString:@") " atIndex:3];
            [mutableNumber insertString:@"(" atIndex:0];
            textField.text = mutableNumber;
        }
    }
}


#pragma mark - TextField Utilities

- (NSString *)removeNonNumericalCharacters:(NSString *)phoneNumber {
    
    NSCharacterSet *charactersToRemove = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    return phoneNumber;
}

- (void)checkEmailTextfieldForValidEmail {
    
    if ([_emailTextField.text rangeOfString:@"@"].location == NSNotFound ||
        [_emailTextField.text rangeOfString:@"."].location == NSNotFound) {
        
    }
}

- (BOOL)hasCompletedRequiredFieldsForRegistration{
    
    BOOL isValid = YES;
    

    if ([_emailTextField.text rangeOfCharacterFromSet: [NSCharacterSet alphanumericCharacterSet]].location == NSNotFound) {
        isValid = NO;
        _emailView.backgroundColor = [TSColorPalette colorByAdjustingColor:[TSColorPalette redColor] Alpha:0.1f];
    }
    if ([_passwordTextField.text rangeOfCharacterFromSet: [NSCharacterSet alphanumericCharacterSet]].location == NSNotFound) {
        isValid = NO;
        _passwordView.backgroundColor = [TSColorPalette colorByAdjustingColor:[TSColorPalette redColor] Alpha:0.1f];
    }
    if ([[self removeNonNumericalCharacters:_phoneNumberTextField.text] length] != 10) {
        isValid = NO;
        _phoneView.backgroundColor = [TSColorPalette colorByAdjustingColor:[TSColorPalette redColor] Alpha:0.1f];
    }

    
    return isValid;
}




@end
