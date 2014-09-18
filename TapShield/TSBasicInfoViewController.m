//
//  TSBasicInfoViewController.m
//  TapShield
//
//  Created by Adam Share on 4/15/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBasicInfoViewController.h"
#import "TSBasicInfoTableViewController.h"

@interface TSBasicInfoViewController ()

@property (strong, nonatomic) TSBasicInfoTableViewController *tableViewController;

@end

@implementation TSBasicInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tableViewController.tableView.backgroundColor = [TSColorPalette listBackgroundColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _tableViewController = (TSBasicInfoTableViewController *)[[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSBasicInfoTableViewController class])];
    [self addChildViewController:_tableViewController];
    [_tableViewController didMoveToParentViewController:self];
    _tableViewController.userProfile = _userProfile;
    
    CGRect frame = _tableViewController.view.frame;
    frame.size.height = 60 * 4;
    frame.origin.y = 100;
    _tableViewController.view.frame = frame;
    [_scrollView addSubview:_tableViewController.view];
    
    _scrollView.backgroundColor = [TSColorPalette listBackgroundColor];
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
    
    if (_tableViewController.birthdayTextField.text.length == 10) {
        _userProfile.birthday = _tableViewController.birthdayTextField.text;
    }
    else {
        _userProfile.birthday = nil;
    }
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].firstName = _tableViewController.firstNameTextField.text;
    [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].lastName = _tableViewController.lastNameTextField.text;
    [[[TSJavelinAPIClient sharedClient] authenticationManager] updateLoggedInUser:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
