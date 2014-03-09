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
    
    CGRect frame = _textMessageBarBaseView.frame;
    frame.origin.y = 0;
    
    _textMessageBarAccessoryView = [[TSTextMessageBarView alloc] initWithFrame:frame];
    _textMessageBarAccessoryView.alpha = 0.0f;
    _inputAccessoryView = [[TSObservingInputAccessoryView alloc] init];
    _inputAccessoryView.clipsToBounds = NO;
    _textMessageBarAccessoryView.messageBoxTextView.inputAccessoryView = _inputAccessoryView;
    [_inputAccessoryView addSubview:_textMessageBarAccessoryView];
    
    
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
    
    //view did not load hide and reset
    if (_textMessageBarAccessoryView.alpha == 1.0f) {
        _textMessageBarAccessoryView.alpha = 0.0f;
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    self.navigationController.navigationBar.topItem.title = self.title;
    
    if (_textMessageBarAccessoryView.alpha == 0.0f) {
        [_textMessageBarBaseView.messageBoxTextView becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [_textMessageBarAccessoryView.messageBoxTextView resignFirstResponder];
}

#pragma mark - Accessory View Movement

- (void)superviewDidChange:(NSNotification *)notification {
    
    UIView *activeKeyboard = _textMessageBarAccessoryView.messageBoxTextView.inputAccessoryView.superview;
    
    //Accessory frame is heading out of self.view's bounds.  Quick swap textMessageBarViews using alpha
    if (activeKeyboard.frame.origin.y >= self.view.bounds.size.height - _textMessageBarBaseView.frame.size.height) {
        _textMessageBarAccessoryView.alpha = 0.0f;
    }
    else {
        _textMessageBarAccessoryView.alpha = 1.0f;
    }
}

- (void)removeAccessoryViewObserver {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TSObservingInputAccessoryViewSuperviewFrameDidChangeNotification object:nil];
}

- (void)addAccessoryViewObserver {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(superviewDidChange:)
                                                 name:TSObservingInputAccessoryViewSuperviewFrameDidChangeNotification
                                               object:nil];
}

#pragma mark - Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newMessageBarViewFrame = _textMessageBarBaseView.frame;
    newMessageBarViewFrame.origin.y = keyboardTop - _textMessageBarBaseView.frame.size.height;
    
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
    
    if (_textMessageBarAccessoryView.alpha == 0) {
        _textMessageBarBaseView.frame = newMessageBarViewFrame;
    }
    
    [UIView commitAnimations];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    
    //ensure superview notifications are coming through
    [self removeAccessoryViewObserver];
    [self addAccessoryViewObserver];
    
    //show Accessory Bar View
    _inputAccessoryView.frame = _textMessageBarAccessoryView.frame;
    _textMessageBarAccessoryView.alpha = 1.0f;
    [_textMessageBarAccessoryView.messageBoxTextView becomeFirstResponder];
    
    //Base Bar View return to original frame
    CGRect newMessageBarViewFrame = _textMessageBarBaseView.frame;
    newMessageBarViewFrame.origin.y = self.view.frame.size.height - newMessageBarViewFrame.size.height;
    _textMessageBarBaseView.frame = newMessageBarViewFrame;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    //Update Base Bar Text View to be shown with new text
    [_textMessageBarBaseView recreateTextViewWithText:_textMessageBarAccessoryView.messageBoxTextView.text];
    
    //return accessory view to zero height to remove any gap for Keyboard Will Show animation
    CGRect frame = _inputAccessoryView.frame;
    frame.size.height = 0;
    _inputAccessoryView.frame = frame;
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
    //remove observer until Accessory View visible again
    [self removeAccessoryViewObserver];
}


#pragma mark - Table View Delegate Methods 


@end
