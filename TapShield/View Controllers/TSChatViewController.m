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
    
    [self setTranslucentBackground:YES];
    
    CGRect frame = _textMessageBarBaseView.frame;
    frame.origin.y = -frame.size.height;
    
    _textMessageBarAccessoryView = [[TSTextMessageBarView alloc] initWithFrame:frame];
    _textMessageBarAccessoryView.textView.delegate = self;
    
    _textMessageBarBaseView.textView.delegate = self;
    _textMessageBarBaseView.identicalAccessoryView = _textMessageBarAccessoryView;
    [_textMessageBarBaseView addButtonCoveringTextViewWithTarget:self action:@selector(showKeyboard)];
    
    frame.size.height = 0;
    _inputAccessoryView = [[TSObservingInputAccessoryView alloc] initWithFrame:frame];
    _inputAccessoryView.clipsToBounds = NO;
    _inputAccessoryView.backgroundColor = [UIColor clearColor];
    
    _textMessageBarAccessoryView.textView.inputAccessoryView = _inputAccessoryView;
    [_inputAccessoryView addSubview:_textMessageBarAccessoryView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(dismissViewController)];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    self.navigationController.navigationBar.topItem.title = self.title;
    
    [self showKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [_textMessageBarAccessoryView.textView resignFirstResponder];
}

- (void)dismissViewController {
    
    UINavigationController *parentNavigationController;
    if ([[self.presentingViewController.childViewControllers firstObject] isKindOfClass:[UINavigationController class]]) {
        parentNavigationController = (UINavigationController *)[self.presentingViewController.childViewControllers firstObject];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        [parentNavigationController setToolbarHidden:NO animated:YES];
        [parentNavigationController setNavigationBarHidden:NO animated:YES];
    }];
}

- (void)showKeyboard {
    
    [_textMessageBarBaseView.textView becomeFirstResponder];
}

#pragma mark - Keyboard Notifications

- (void)keyboardDidShow:(NSNotification *)notification {
    
    [_textMessageBarAccessoryView.textView becomeFirstResponder];
    _textMessageBarBaseView.identicalAccessoryViewShown = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    [self setDecoyAccessoryView];
    [_inputAccessoryView.superview.layer removeAllAnimations];
}


- (void)keyboardDidHide:(NSNotification *)notification {
    
    _textMessageBarBaseView.identicalAccessoryViewShown = NO;
}


#pragma mark - Text View Delegate

- (void)textViewDidChange:(UITextView *)textView {
    
    _textMessageBarBaseView.textView.text = textView.text;
    [_textMessageBarAccessoryView refreshBarHeightWithKeyboard:_inputAccessoryView.superview navigationBar:self.navigationController.navigationBar];
    [_textMessageBarBaseView resizeBarToReflect:_textMessageBarAccessoryView];
}


#pragma mark - Table View Delegate Methods 

- (void)setRealAccessoryView {
    CGRect frame = _inputAccessoryView.frame;
    frame.size.height = _textMessageBarAccessoryView.frame.size.height;
    _inputAccessoryView.frame = frame;
    _textMessageBarAccessoryView.frame = frame;
}

- (void)setDecoyAccessoryView {
    
    CGRect frame = _inputAccessoryView.frame;
    frame.size.height = 0.0f;
    frame.origin.y = 0.0f;
    _inputAccessoryView.frame = frame;
    
    frame = _textMessageBarAccessoryView.frame;
    frame.origin.y = -_textMessageBarAccessoryView.frame.size.height;
    _textMessageBarAccessoryView.frame = frame;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //[self setRealAccessoryView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    //[self setDecoyAccessoryView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    NSLog(@"%f", scrollView.frame.size.height);
    
}

@end
