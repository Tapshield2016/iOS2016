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

@implementation TSChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CGRect frame = _messageBarContainerView.frame;
    frame.origin.y = 0;
    
    _textMessageBarView = [[TSTextMessageBarView alloc] initWithFrame:frame];
    _inputAccessoryView = [[TSObservingInputAccessoryView alloc] init];
    _inputAccessoryView.clipsToBounds = NO;
//    _messageTextView = [[UITextView alloc] init];
//    _messageTextView.inputAccessoryView = _inputAccessoryView;
    
    
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

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    self.navigationController.navigationBar.topItem.title = self.title;
}

- (void)superviewDidChange:(NSNotification *)notification {
    
    
    UIView *activeKeyboard = _textMessageBarView.messageBoxTextView.inputAccessoryView.superview;
    
    if (activeKeyboard.frame.origin.y >= self.view.bounds.size.height - _messageBarContainerView.frame.size.height) {
        _textMessageBarView.alpha = 0.0f;
    }
    
    if (activeKeyboard.frame.origin.y < [UIScreen mainScreen].bounds.size.height - activeKeyboard.frame.size.height - _textMessageBarView.frame.size.height) {
    }
}

#pragma mark - Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    
    
    [self resetAccessoryViewObserver];
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's
    // coordinate system. The bottom of the text view's frame should align with the top
    // of the keyboard's final position.
    //
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newMessageBarViewFrame = _messageBarContainerView.frame;
    newMessageBarViewFrame.origin.y = keyboardTop - _messageBarContainerView.frame.size.height;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    
    if (_textMessageBarView.alpha == 0) {
        _messageBarContainerView.frame = newMessageBarViewFrame;
    }
    
    NSLog(@"Will Show");
    
    [UIView commitAnimations];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    
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
    
    //[_textMessageBarView removeFromSuperview];
    
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
    
    NSLog(@"Will Hide");
    
    
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
