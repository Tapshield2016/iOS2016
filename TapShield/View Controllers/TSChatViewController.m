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
    
    _toolbar = [[UIToolbar alloc] initWithFrame:self.view.bounds];
    _toolbar.barStyle = UIBarStyleBlack;
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:_toolbar atIndex:0];
    
    CGRect frame = _textMessageBarBaseView.frame;
    frame.origin.y = -frame.size.height;
    
    _textMessageBarAccessoryView = [[TSTextMessageBarView alloc] initWithFrame:frame];
    _textMessageBarAccessoryView.messageBoxTextView.delegate = self;
    _textMessageBarBaseView.messageBoxTextView.delegate = self;
    
    frame.size.height = 0;
    _inputAccessoryView = [[UIView alloc] initWithFrame:frame];
    _inputAccessoryView.clipsToBounds = NO;
    _inputAccessoryView.backgroundColor = [UIColor clearColor];
    
    _textMessageBarAccessoryView.messageBoxTextView.inputAccessoryView = _inputAccessoryView;
    [_inputAccessoryView addSubview:_textMessageBarAccessoryView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
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
    
    [_textMessageBarBaseView.messageBoxTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [_textMessageBarAccessoryView.messageBoxTextView resignFirstResponder];
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


#pragma mark - Keyboard Notifications

- (void)keyboardDidShow:(NSNotification *)notification {
    
    [_textMessageBarAccessoryView.messageBoxTextView becomeFirstResponder];
}


#pragma mark - Text View Delegate

- (void)textViewDidChange:(UITextView *)textView {
    
    _textMessageBarBaseView.messageBoxTextView.text = textView.text;
}


#pragma mark - Table View Delegate Methods 


@end
