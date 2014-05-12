//
//  TSChatViewController.m
//  TapShield
//
//  Created by Adam Share on 3/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSChatViewController.h"
#import "TSJavelinChatManager.h"
#import "TSChatMessageCell.h"
#import "TSAlertManager.h"
#import "TSPageViewController.h"
#import "TSLocationController.h"

@interface TSChatViewController ()

@property (assign) NSUInteger previousCount;

@end

@implementation TSChatViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftAgencyBoundaries) name:TSGeofenceUserDidLeaveAgency object:nil];
    
    [self.navigationItem setHidesBackButton:_hideBackButton];
    
    CGRect frame = _textMessageBarBaseView.frame;
    frame.origin.y = -frame.size.height;
    
    _textMessageBarAccessoryView = [[TSTextMessageBarView alloc] initWithFrame:frame];
    _textMessageBarAccessoryView.textView.delegate = self;
    _textMessageBarAccessoryView.adjustedTableView = _tableView;
    
    _textMessageBarBaseView.textView.delegate = self;
    _textMessageBarBaseView.identicalAccessoryView = _textMessageBarAccessoryView;
    [_textMessageBarBaseView addButtonCoveringTextViewWithTarget:self action:@selector(showKeyboard)];
    
    frame.size.height = 0;
    _inputAccessoryView = [[TSObservingInputAccessoryView alloc] initWithFrame:frame];
    _inputAccessoryView.clipsToBounds = NO;
    _inputAccessoryView.backgroundColor = [UIColor clearColor];
    
    _textMessageBarAccessoryView.textView.inputAccessoryView = _inputAccessoryView;
    [_inputAccessoryView addSubview:_textMessageBarAccessoryView];
    
    [_textMessageBarAccessoryView setSendButtonTarget:self action:@selector(sendMessage)];
    [_textMessageBarBaseView setSendButtonTarget:self action:@selector(sendMessage)];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTableViewCells)
                                                 name:TSJavelinChatManagerDidReceiveNewChatMessageNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _tableView.backgroundColor = [UIColor clearColor];
    [_tableView setContentInset:UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height, 0.0f, _textMessageBarBaseView.frame.size.height, 0.0f)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self updateTableViewCells];
    
    [[TSJavelinAPIClient sharedClient] chatManager].quickGetTimerInterval = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self whiteNavigationBar];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
        
    if (self.navigationController.isBeingPresented) {
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
    
    [[TSJavelinAPIClient sharedClient] chatManager].quickGetTimerInterval = NO;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [_textMessageBarAccessoryView.textView resignFirstResponder];
}

- (void)leftAgencyBoundaries {
    
    if ([[TSAlertManager sharedManager].status isEqualToString:kAlertSend]) {
        [self dismissViewController];
        [[TSLocationController sharedLocationController].geofence showOutsideBoundariesWindow];
    }
}

- (void)dismissViewController {
    
    UINavigationController *parentNavigationController;
    if ([[self.presentingViewController.childViewControllers firstObject] isKindOfClass:[UINavigationController class]]) {
        parentNavigationController = (UINavigationController *)[self.presentingViewController.childViewControllers firstObject];
    }
    else if ([self.presentingViewController isKindOfClass:[UINavigationController class]]) {
        parentNavigationController = (UINavigationController *)self.presentingViewController;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [parentNavigationController.topViewController viewWillAppear:NO];
        [parentNavigationController.topViewController viewDidAppear:NO];
    }];
}

- (void)showKeyboard {
    
    [_textMessageBarBaseView.textView becomeFirstResponder];
}

- (void)updateTableViewCells {
    
    BOOL shouldScroll = YES;
    if (_previousCount == [[TSJavelinAPIClient sharedClient] chatManager].chatMessages.allMessages.count) {
        shouldScroll = NO;
    }
    _previousCount = [[TSJavelinAPIClient sharedClient] chatManager].chatMessages.allMessages.count;
    
    
    [UIView animateWithDuration:0.3 animations:^{
        [_tableView reloadData];
        if ([[TSJavelinAPIClient sharedClient] chatManager].chatMessages.allMessages.count > 1 && shouldScroll) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[TSJavelinAPIClient sharedClient] chatManager].chatMessages.allMessages.count - 1 inSection:0];
            [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    } completion:nil];
}

#pragma mark - Chat Manager Methods

- (void)sendMessage {
    
    if (_textMessageBarBaseView.textView.text.length < 1) {
        return;
    }
    
    [[[TSJavelinAPIClient sharedClient] chatManager] sendChatMessage:_textMessageBarBaseView.textView.text];
    [self updateTableViewCells];
    
    [self resetMessageBars];
    
    if ([[TSAlertManager sharedManager].status isEqualToString:kAlertSend]) {
        [self.navigationController popViewControllerAnimated:YES];
        [TSAlertManager sharedManager].type = @"C";
        [(TSPageViewController *)[self.navigationController.viewControllers firstObject] showAlertViewController];
    }
}

- (void)resetMessageBars {
    _textMessageBarAccessoryView.textView.text = @"";
    _textMessageBarBaseView.textView.text = @"";
    [_textMessageBarAccessoryView resetBarHeightWithKeyboard:_inputAccessoryView.superview navigationBar:self.navigationController.navigationBar];
    [_textMessageBarBaseView resizeBarToReflect:_textMessageBarAccessoryView];
}

#pragma mark - Keyboard Notifications

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
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height, 0.0f, _textMessageBarBaseView.frame.size.height + keyboardBounds.size.height, 0.0f);
    _tableView.contentInset = contentInsets;
    _tableView.scrollIndicatorInsets = contentInsets;
    
    if ([[TSJavelinAPIClient sharedClient] chatManager].chatMessages.allMessages.count > 1) {
        [_tableView reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[TSJavelinAPIClient sharedClient] chatManager].chatMessages.allMessages.count - 1 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    
    [UIView commitAnimations];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    
    [_textMessageBarAccessoryView.textView becomeFirstResponder];
    _textMessageBarBaseView.identicalAccessoryViewShown = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
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


#pragma mark - Table View Data Source Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = TSChatMessageCellIdentifierDispatcher;
    TSJavelinAPIChatMessage *chatMessage = [[TSJavelinAPIClient sharedClient] chatManager].chatMessages.allMessages[indexPath.row];
    if (chatMessage.senderID == [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].identifier) {
        identifier = TSChatMessageCellIdentifierUser;
    }
    
    TSChatMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[TSChatMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.chatMessage = chatMessage;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[TSJavelinAPIClient sharedClient] chatManager].chatMessages.allMessages.count;
}

#pragma mark - Table View Delegate 

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TSChatMessageCell heightForChatCellAtIndexPath:indexPath];
}

#pragma mark - Scroll View Delegate



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [self setRealAccessoryView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    [self performSelectorOnMainThread:@selector(setDecoyAccessoryView) withObject:nil waitUntilDone:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    
}


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

@end
