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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_registerButton setBackgroundImage:[UIImage imageFromColor:[TSColorPalette tapshieldBlue]] forState:UIControlStateNormal];
    [_registerButton setBackgroundImage:[UIImage imageHighlightedFromColor:[TSColorPalette tapshieldBlue]] forState:UIControlStateHighlighted];
    
    [_addOrganizationButton setBackgroundImage:[UIImage imageFromColor:[TSColorPalette darkGrayColor]] forState:UIControlStateNormal];
    [_addOrganizationButton setBackgroundImage:[UIImage imageHighlightedFromColor:[TSColorPalette darkGrayColor]] forState:UIControlStateHighlighted];
    
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
    
	// Do any additional setup after loading the view.
    _checkAgreeButton.layer.shadowColor = [UIColor grayColor].CGColor;
    _checkAgreeButton.layer.shadowOffset = CGSizeMake(0, 1);
    _checkAgreeButton.layer.shadowOpacity = 1;
    _checkAgreeButton.layer.shadowRadius = 1.0;
    _checkAgreeButton.clipsToBounds = NO;
    
    if (_emailAddress) {
        _emailTextField.text = _emailAddress;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (_agency) {
        _organizationLabel.text = _agency.name;
        _addOrganizationButton.alpha = 0.0f;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button

- (IBAction)removeOrganization:(id)sender {
    _agency = nil;
    _organizationLabel.text = @"";
    _addOrganizationButton.alpha = 1.0f;
}

- (IBAction)selectAgree:(id)sender {
    _checkAgreeButton.selected = !_checkAgreeButton.selected;
    
    _termsView.backgroundColor = [UIColor clearColor];
}

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
    
    NSUInteger identifier = 1;
    if (_agency) {
        identifier = _agency.identifier;
    }
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] registerUserWithAgencyID:identifier
                                                                           emailAddress:[_emailTextField.text lowercaseString]
                                                                               password:_passwordTextField.text
                                                                            phoneNumber:_phoneNumberTextField.text
                                                                             disarmCode:_disarmCodeTextField.text
                                                                              firstName:_firstNameTextField.text
                                                                               lastName:_lastNameTextField.text
                                                                             completion:^(id responseObject) {
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
    
    TSEmailVerificationViewController *emailVerificationViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TSEmailVerificationViewController"];
    emailVerificationViewController.email = [_emailTextField.text lowercaseString];
    emailVerificationViewController.password = _passwordTextField.text;
    
    if ([[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].isEmailVerified) {
        [emailVerificationViewController segueToPhoneVerification];
        return;
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
    
    if (_disarmCodeTextField == textField) {
        
        if ([textField.text length] + [string length] - range.length == 4) {
            textField.text = [textField.text stringByAppendingString:string];
            [textField resignFirstResponder];
            return NO;
        }
        else if ([textField.text length] + [string length] - range.length > 4) {
            return NO;
        }
    }
    else if (_phoneNumberTextField == textField) {
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
    
    if ([_firstNameTextField.text rangeOfCharacterFromSet: [NSCharacterSet letterCharacterSet]].location == NSNotFound) {
        isValid = NO;
        _firstNameView.backgroundColor = [TSColorPalette colorByAdjustingColor:[TSColorPalette redColor] Alpha:0.1f];
    }
    if ([_lastNameTextField.text rangeOfCharacterFromSet: [NSCharacterSet letterCharacterSet]].location == NSNotFound) {
        isValid = NO;
        _lastNameView.backgroundColor = [TSColorPalette colorByAdjustingColor:[TSColorPalette redColor] Alpha:0.1f];
    }
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
    if ([[self removeNonNumericalCharacters:_disarmCodeTextField.text] length] != 4) {
        isValid = NO;
        _disarmCodeView.backgroundColor = [TSColorPalette colorByAdjustingColor:[TSColorPalette redColor] Alpha:0.1f];
    }
    if (!_checkAgreeButton.selected) {
        isValid = NO;
        _termsView.backgroundColor = [TSColorPalette colorByAdjustingColor:[TSColorPalette redColor] Alpha:0.1f];
    }
    
    return isValid;
}




@end
