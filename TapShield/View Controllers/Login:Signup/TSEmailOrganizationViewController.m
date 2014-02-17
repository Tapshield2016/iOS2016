//
//  TSEmailOrganizationViewController.m
//  TapShield
//
//  Created by Adam Share on 2/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEmailOrganizationViewController.h"
#import "TSOrganizationSearchViewController.h"

@interface TSEmailOrganizationViewController ()

@end

@implementation TSEmailOrganizationViewController

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
	// Do any additional setup after loading the view.
    [_yesButton setBackgroundImage:[UIImage imageFromColor:[TSColorPalette tapshieldBlue]] forState:UIControlStateHighlighted];
    [_noButton setBackgroundImage:[UIImage imageFromColor:[TSColorPalette tapshieldDarkBlue]] forState:UIControlStateHighlighted];
    
    UIImageView *lightStrip = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:[TSColorPalette tapshieldBlue]]];
    UIImageView *darkStrip = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:[TSColorPalette tapshieldDarkBlue]]];
    lightStrip.frame = CGRectMake(0.0f, -10.0f, _yesButton.frame.size.width, 10.0f);
    darkStrip.frame = lightStrip.frame;
    [_yesButton addSubview:lightStrip];
    [_noButton addSubview:darkStrip];
    
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
    [self.view addGestureRecognizer:tap];
    
    CALayer *TopBorder = [CALayer layer];
    TopBorder.frame = CGRectMake(0.0f, 0.0f, _buttonContainerView.frame.size.width, 0.3f);
    TopBorder.backgroundColor = [TSColorPalette colorByAdjustingColor:[UIColor lightGrayColor] Alpha:0.1f].CGColor;
    [_buttonContainerView.layer addSublayer:TopBorder];
}

- (void)viewWillAppear:(BOOL)animated {
    _buttonContainerView.alpha = 0.0f;
    _registerEmailButton.alpha = 1.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TSOrganizationSearchViewController *viewController = [segue destinationViewController];
    viewController.emailAddress = _emailTextField.text;
    [self dismissKeyboard];
}


- (IBAction)showEmailTextfield:(id)sender {
    
    [_emailTextField becomeFirstResponder];
    
    [UIView animateWithDuration:0.1f animations:^{
        _registerEmailButton.alpha = 0.0f;
    }];
}

#pragma mark - Keyboard

- (void)dismissKeyboard {
    [_emailTextField resignFirstResponder];
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
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    CGRect frame = _buttonContainerView.frame;
    frame.origin.y = keyboardBounds.origin.y - frame.size.height;
    _buttonContainerView.frame = frame;
    
    // commit animations
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
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    CGRect frame = _buttonContainerView.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
    _buttonContainerView.frame = frame;
    
    // commit animations
    [UIView commitAnimations];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    [self checkEmailTextfieldForValidEmail];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self mailIconSelected:YES];
    [self checkEmailTextfieldForValidEmail];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (_buttonContainerView.alpha == 1.0f) {
        [UIView animateWithDuration:0.2f animations:^{
            _buttonContainerView.alpha = 0.0f;
        }];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2f animations:^{
        [self mailIconSelected:NO];
        _buttonContainerView.alpha = 0.0f;
        _registerEmailButton.alpha = 1.0f;
    }];
}

- (void)checkEmailTextfieldForValidEmail {
    
    if ([_emailTextField.text rangeOfString:@"@"].location == NSNotFound ||
        [_emailTextField.text rangeOfString:@"."].location == NSNotFound) {
        if (_buttonContainerView.alpha == 1.0f) {
            [UIView animateWithDuration:0.2f animations:^{
                _buttonContainerView.alpha = 0.0f;
            }];
        }
    }
    else if (_buttonContainerView.alpha == 0.0f) {
        [UIView animateWithDuration:0.2f animations:^{
            _buttonContainerView.alpha = 1.0f;
        }];
    }
}


- (void)mailIconSelected:(BOOL)editing {
    UIImage *selectedImage = _emailIcon.image;
    
    if (!editing) {
        _emailIcon.image = [UIImage imageNamed:@"mailIcon"];
        return;
    }
    
    //image color change
    CGRect rect = CGRectMake(0, 0, _emailIcon.frame.size.width, _emailIcon.frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, selectedImage.CGImage);
    CGContextSetFillColorWithColor(context, [[TSColorPalette darkGrayColor] CGColor]);
    CGContextFillRect(context, rect);
    selectedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _emailIcon.image = [UIImage imageWithCGImage:selectedImage.CGImage scale:1.0f orientation: UIImageOrientationDownMirrored];
}


@end
