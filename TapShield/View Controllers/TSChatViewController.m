//
//  TSChatViewController.m
//  TapShield
//
//  Created by Adam Share on 3/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSChatViewController.h"

@interface TSChatViewController ()


@end

CGRect keyboardRect;

@implementation TSChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CGRect frame = _messageBarContainerView.frame;
    frame.origin.y = 0;
    
    _textMessageBarView = [[TSTextMessageBarView alloc] initWithFrame:frame];
    _textMessageBarView.alpha = 0.0f;
    _inputAccessoryView = [[TSObservingInputAccessoryView alloc] init];
    _inputAccessoryView.clipsToBounds = NO;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (_textMessageBarView.alpha == 1.0f) {
        _textMessageBarView.alpha = 0.0f;
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    self.navigationController.navigationBar.topItem.title = self.title;
    
    if (_textMessageBarView.alpha == 0.0f) {
        [_messageBarContainerView.messageBoxTextView becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [_textMessageBarView.messageBoxTextView resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
}

- (void)superviewDidChange:(NSNotification *)notification {
    
    
    UIView *activeKeyboard = _textMessageBarView.messageBoxTextView.inputAccessoryView.superview;
    
    if (activeKeyboard.frame.origin.y >= self.view.bounds.size.height - _messageBarContainerView.frame.size.height) {
        _textMessageBarView.alpha = 0.0f;
    }
    else {
        _textMessageBarView.alpha = 1.0f;
    }
    
    if (activeKeyboard.frame.origin.y < [UIScreen mainScreen].bounds.size.height - activeKeyboard.frame.size.height - _textMessageBarView.frame.size.height) {
    }
}

#pragma mark - Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSLog(@"Will Show");
    
    [self resetAccessoryViewObserver];
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newMessageBarViewFrame = _messageBarContainerView.frame;
    newMessageBarViewFrame.origin.y = keyboardTop - _messageBarContainerView.frame.size.height;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    
    if (_textMessageBarView.alpha == 0 && _messageBarContainerView.frame.origin.y > 400) {
        _messageBarContainerView.frame = newMessageBarViewFrame;
    }
    
    [UIView commitAnimations];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    
    NSLog(@"Did Show");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(superviewDidChange:)
                                                 name:TSObservingInputAccessoryViewSuperviewFrameDidChangeNotification
                                               object:nil];
    
    CGRect newMessageBarViewFrame = _messageBarContainerView.frame;
    newMessageBarViewFrame.origin.y = self.view.frame.size.height - newMessageBarViewFrame.size.height;
    _messageBarContainerView.frame = newMessageBarViewFrame;
    
    _inputAccessoryView.frame = _textMessageBarView.frame;
    
    if (_inputAccessoryView.subviews.count == 0) {
        [_inputAccessoryView addSubview:_textMessageBarView];
    }
    _textMessageBarView.alpha = 1.0f;
    [_textMessageBarView.messageBoxTextView becomeFirstResponder];
    _textMessageBarView.messageBoxTextView.inputAccessoryView = _inputAccessoryView;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSLog(@"Will Hide");
    
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect newMessageBarViewFrame = _messageBarContainerView.frame;
    newMessageBarViewFrame.origin.y = self.view.bounds.size.height - _messageBarContainerView.frame.size.height;
    
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    
    
    [UIView commitAnimations];
    
    [_messageBarContainerView recreateTextViewWithText:_textMessageBarView.messageBoxTextView.text];
    
    CGRect frame = _inputAccessoryView.frame;
    frame.size.height = 0;
    _inputAccessoryView.frame = frame;
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
    [self resetAccessoryViewObserver];
}

- (void)resetAccessoryViewObserver {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TSObservingInputAccessoryViewSuperviewFrameDidChangeNotification object:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}

#pragma mark - Table View Delegate Methods 


@end
