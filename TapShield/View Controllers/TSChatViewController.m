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

@property (assign, nonatomic) NSUInteger previousCount;
@property (strong, nonatomic) UIView *tintView;
@property (assign, nonatomic) BOOL isDismissing;

@end

@implementation TSChatViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(leftAgencyBoundaries)
                                                 name:TSGeofenceUserDidLeaveAgency
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTableViewCells)
                                                 name:TSJavelinChatManagerDidUpdateChatMessageNotification
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
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    
    _textMessageBarAccessoryView = [[TSTextMessageBarView alloc] initWithFrame:frame];
    _textMessageBarAccessoryView.textView.delegate = self;
    _textMessageBarAccessoryView.textView.inputAccessoryView = _textMessageBarAccessoryView;
    [_textMessageBarAccessoryView setSendButtonTarget:self action:@selector(sendMessage)];
    
    _tableView.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationItem setHidesBackButton:_hideBackButton];
    
    [TSJavelinChatManager sharedManager].unreadMessages = 0;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self updateTableViewCells];
    
    [[TSJavelinAPIClient sharedClient] chatManager].quickGetTimerInterval = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self whiteNavigationBar];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
        
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(dismissViewController)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
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
    
    if (![TSAlertManager sharedManager].isAlertInProgress) {
        [self dismissViewController];
        [[TSLocationController sharedLocationController].geofence showOutsideBoundariesWindow];
    }
}

- (BOOL)canBecomeFirstResponder {
    
//    if (_isDismissing) {
//        return NO;
//    }
    
    return YES;
}

- (UIView *)inputAccessoryView {
    return _textMessageBarAccessoryView;
}

- (void)dismissViewController {
    
    _isDismissing = YES;
    [_textMessageBarAccessoryView.textView resignFirstResponder];
    [[self.view findFirstResponder] resignFirstResponder];
    
    [TSJavelinChatManager sharedManager].unreadMessages = 0;
    
    if ([TSAlertManager sharedManager].isAlertInProgress) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [[TSAlertManager sharedManager] dismissWindowWithAnimationType:kAlertWindowAnimationTypeDown completion:nil];
    }
}

- (void)showKeyboard {
    
    [_textMessageBarAccessoryView.textView becomeFirstResponder];
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
    
    [[UIDevice currentDevice] playInputClick];
    
    if (_textMessageBarAccessoryView.textView.text.length < 1) {
        return;
    }
    
    [[[TSJavelinAPIClient sharedClient] chatManager] sendChatMessage:_textMessageBarAccessoryView.textView.text];
    [self updateTableViewCells];
    
    [self resetMessageBars];
    
    if (![TSAlertManager sharedManager].isAlertInProgress) {
        [TSAlertManager sharedManager].type = @"C";
        [(TSPageViewController *)[self.navigationController.viewControllers firstObject] showAlertViewController];
        [self.navigationItem setHidesBackButton:NO animated:YES];
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        [self.navigationItem setLeftItemsSupplementBackButton:YES];
    }
}

- (void)resetMessageBars {
    _textMessageBarAccessoryView.textView.text = @"";
    [_textMessageBarAccessoryView refreshBarHeightWithKeyboard:_textMessageBarAccessoryView.superview navigationBar:self.navigationController.navigationBar];
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
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height, 0.0f, keyboardBounds.size.height + 2, 0.0f);
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
    
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
}


- (void)keyboardDidHide:(NSNotification *)notification {
    
    
}


#pragma mark - Text View Delegate

- (void)textViewDidChange:(UITextView *)textView {
    [_textMessageBarAccessoryView refreshBarHeightWithKeyboard:_textMessageBarAccessoryView.superview navigationBar:self.navigationController.navigationBar];
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


#pragma mark Prompt Messages

- (void)setNavigationItemPrompt:(NSString *)string {
    
    if (![string isEqualToString:kAlertSend] && ![string isEqualToString:kAlertNoConnection]) {
        if (!_tintView) {
            _tintView = [[UIView alloc] initWithFrame:self.view.frame];
            _tintView.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.3];
            [self.view insertSubview:_tintView belowSubview:_tableView];
        }
    }
    
    if (![string isEqualToString:kAlertSend]) {
        [self.navigationItem setPrompt:string];
    }
    else {
        [self clearPrompt];
    }
    
    UIEdgeInsets inset = _tableView.contentInset;
    inset.top = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    [_tableView setContentInset:inset];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(clearPrompt) object:nil];
    
    if (![string isEqualToString:kAlertOutsideGeofence] &&
        ![string isEqualToString:kAlertNoConnection]  &&
        ![string isEqualToString:kAlertClosedDispatchCenter]) {
        
        [self performSelector:@selector(clearPrompt) withObject:nil afterDelay:10.0];
    }
}

- (void)clearPrompt {
    
    [self.navigationItem setPrompt:nil];
    
    UIEdgeInsets inset = _tableView.contentInset;
    inset.top = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    [_tableView setContentInset:inset];
}

@end
