//
//  TSChangePasscodeViewController.m
//  TapShield
//
//  Created by Adam Share on 5/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSChangePasscodeViewController.h"
#import "TSPasscodeTableViewController.h"

@interface TSChangePasscodeViewController ()

@property (strong, nonatomic) TSPasscodeTableViewController *tableViewController;

@end

@implementation TSChangePasscodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _tableViewController = (TSPasscodeTableViewController *)[[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSPasscodeTableViewController class])];
    [self addChildViewController:_tableViewController];
    [_tableViewController didMoveToParentViewController:self];
    
    CGRect frame = _tableViewController.view.frame;
    frame.size.height = 60 *3;
    frame.origin.y = 100;
    _tableViewController.view.frame = frame;
    [_scrollView addSubview:_tableViewController.view];
    
    _scrollView.backgroundColor = [TSColorPalette listBackgroundColor];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(savePasscode:)];
    [self.navigationItem setRightBarButtonItem:item];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    _scrollView.contentSize = self.view.frame.size;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)savePasscode:(id)sender {
    
    _tableViewController.currentPasscodeTextField.text = [TSUtilities removeNonNumericalCharacters:_tableViewController.currentPasscodeTextField.text];
    _tableViewController.passcodeTextField.text = [TSUtilities removeNonNumericalCharacters:_tableViewController.passcodeTextField.text];
    _tableViewController.repeatPasscodeTextField.text = [TSUtilities removeNonNumericalCharacters:_tableViewController.repeatPasscodeTextField.text];
    
    BOOL oldText = [[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].disarmCode isEqualToString:_tableViewController.currentPasscodeTextField.text];
    if (!oldText) {
        _tableViewController.currentPasscodeTextField.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.2];
    }
    BOOL newText = [_tableViewController.passcodeTextField.text isEqualToString:_tableViewController.repeatPasscodeTextField.text];
    if (!newText || _tableViewController.passcodeTextField.text.length != 4) {
        newText = NO;
        _tableViewController.passcodeTextField.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.2];
        _tableViewController.repeatPasscodeTextField.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.2];
    }
    
    if (oldText && newText && _tableViewController.passcodeTextField.text.length == 4) {
        [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].disarmCode = _tableViewController.passcodeTextField.text;
        [self.navigationController popViewControllerAnimated:YES];
        [[[TSJavelinAPIClient sharedClient] authenticationManager] updateLoggedInUserDisarmCode:nil];
    }
}


#pragma mark - Keyboard

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
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardBounds.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    
    CGRect rect = [[self.view findFirstResponder] convertRect:[self.view findFirstResponder].superview.frame toView:self.view];
    
    if (!CGRectContainsPoint(aRect, rect.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, rect.origin.y - keyboardBounds.size.height);
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


@end
