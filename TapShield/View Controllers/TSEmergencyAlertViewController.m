//
//  TSEmergencyAlertViewViewController.m
//  TapShield
//
//  Created by Adam Share on 3/6/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEmergencyAlertViewController.h"
#import "TSPageViewController.h"
#import "TSVoipViewController.h"

@interface TSEmergencyAlertViewController ()

@property (strong, nonatomic) TSVoipViewController *voipController;
@property (strong, nonatomic) TSTransitionDelegate *transitionDelegate;
@property (strong, nonatomic) TSPageViewController *pageViewController;

@end

@implementation TSEmergencyAlertViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    self.showLargeLogo = YES;
    
    [self.view addSubview:_voipController.view];
    
    if ([[TSAlertManager sharedManager].status isEqualToString:kAlertOutsideGeofence]) {
        [_detailsButtonView setHidden:YES];
        [_chatButtonView setHidden:YES];
    }
    
    if (![[TSAlertManager sharedManager].status isEqualToString:kAlertSend]) {
        [((TSPageViewController *)_pageViewController).homeViewController.mapView selectAnnotation:((TSPageViewController *)_pageViewController).homeViewController.mapView.userLocationAnnotation animated:YES];
    }
    
    _alertInfoLabel = [[TSBaseLabel alloc] initWithFrame:CGRectMake(0.0, 64, 320, 44)];
    _alertInfoLabel.textColor = [UIColor whiteColor];
    _alertInfoLabel.font = [TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f];
    _alertInfoLabel.textAlignment = NSTextAlignmentCenter;
    _alertInfoLabel.text = [TSAlertManager sharedManager].status;
    [_alertInfoLabel setAdjustsFontSizeToFitWidth:YES];
    
    [self.view addSubview: _alertInfoLabel];
    
    if ([[TSLocationController sharedLocationController] geofence].currentAgency) {
        _phoneNumberLabel.text = [TSUtilities formatPhoneNumber:[[TSLocationController sharedLocationController] geofence].currentAgency.dispatcherPhoneNumber];
        _dispatcherNameLabel.text = [NSString stringWithFormat:@"%@ Dispatcher", [[TSLocationController sharedLocationController] geofence].currentAgency.name];
    }
    else {
        _phoneNumberLabel.text = [TSUtilities formatPhoneNumber:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.dispatcherPhoneNumber];
        _dispatcherNameLabel.text = [NSString stringWithFormat:@"%@ Dispatcher", [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.name];
    }
    
    [TSAlertManager sharedManager].alertDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self revealBottomButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSuperviewViewController:(UIViewController *)superviewViewController {
    
    _superviewViewController = superviewViewController;
    
    if ([superviewViewController isKindOfClass:[TSPageViewController class]]) {
        _pageViewController = (TSPageViewController *)superviewViewController;
    }
}

- (void)revealBottomButtons {
    
    if (self.toolbar.frame.size.height != self.view.frame.size.height) {
        return;
    }
    
    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.toolbar.frame = CGRectMake(0.0, self.toolbar.frame.origin.y, self.view.frame.size.width*2, self.navigationController.navigationBar.frame.size.height);
    } completion:nil];
}

- (void)showCallTimer {
    
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _callTimerView.alpha = 1.0f;
    } completion:nil];
}

- (void)hideCallTimer {
    
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _callTimerView.alpha = 0.0f;
        _callTimeLabel.text = @"00:00";
    } completion:nil];
}

- (void)endCall {
    
    [[TSAlertManager sharedManager] endTwilioCall];
}

#pragma mark - Alert Methods


- (void)alertStatusChanged:(NSString *)status {
    
    [self updateAlertInfoLabel:status];
    
    AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([status isEqualToString:kAlertSending]) {
            [(TSPageViewController *)_pageViewController showAlertViewController];
        }
        
        if ([status isEqualToString:kAlertSent]) {
            [_pageViewController.homeViewController mapAlertModeToggle];
        }
        
        if ([status isEqualToString:kAlertOutsideGeofence]) {
            [_detailsButtonView setHidden:YES];
            [_chatButtonView setHidden:YES];
        }
        
        [((TSPageViewController *)_pageViewController).homeViewController.mapView selectAnnotation:((TSPageViewController *)_pageViewController).homeViewController.mapView.userLocationAnnotation animated:YES];
        [((TSPageViewController *)_pageViewController).disarmPadViewController.emergencyButton setTitle:@"Alert" forState:UIControlStateNormal];
        
    });
}

- (void)updateAlertInfoLabel:(NSString *)string {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view bringSubviewToFront:_alertInfoLabel];
        [_alertInfoLabel setText:string withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
    });
}


#pragma mark - Button Actions

- (IBAction)showChatViewController:(id)sender {
    
    UIViewController *viewController = _pageViewController.chatViewController;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    if (!_transitionDelegate) {
        _transitionDelegate = [[TSTransitionDelegate alloc] init];
    }
    navigationController.transitioningDelegate = _transitionDelegate;
    navigationController.modalPresentationStyle = UIModalPresentationCustom;
    
    [_pageViewController.navigationController presentViewController:navigationController animated:YES completion:nil];
}


- (IBAction)addAlertDetails:(id)sender {
    
    TSAlertDetailsTableViewController *viewController = (TSAlertDetailsTableViewController *)[[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSAlertDetailsTableViewController class])];
    viewController.mapView = _pageViewController.homeViewController.mapView;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    if (!_transitionDelegate) {
        _transitionDelegate = [[TSTransitionDelegate alloc] init];
    }
    navigationController.transitioningDelegate = _transitionDelegate;
    navigationController.modalPresentationStyle = UIModalPresentationCustom;
    
    [_pageViewController.navigationController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Phone View Transition Animations

- (IBAction)callDispatcher:(id)sender {
    
    if ([[TSAlertManager sharedManager].status isEqualToString:kAlertOutsideGeofence]) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
            NSString *rawPhoneNum = [[TSJavelinAPIClient sharedClient].authenticationManager loggedInUser].agency.dispatcherSecondaryPhoneNumber;
            if (!rawPhoneNum) {
                rawPhoneNum = kEmergencyNumber;
#warning 911
            }
            
            NSString *phoneNumber = [@"tel://" stringByAppendingString:rawPhoneNum];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        }
        else {
            UIAlertView *phoneServiceUnavailableAlert = [[UIAlertView alloc] initWithTitle:nil
                                                                                   message:@"This device is not setup to make phone calls"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [phoneServiceUnavailableAlert show];
            });
        }
        return;
    }
    
    _pageViewController.isPhoneView = YES;
    
    if (!_voipController) {
        _voipController = [[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSVoipViewController class])];
        _voipController.emergencyView = self;
        [self.view addSubview:_voipController.view];
    }
    
    CGRect frame = self.view.bounds;
    frame.origin.y = frame.size.height;
    _voipController.view.frame = frame;
    
    CGRect infoLabelFrame = _alertInfoLabel.frame;
    infoLabelFrame.origin.y += 88;
    
    float topBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height + _pageViewController.navigationController.navigationBar.frame.size.height;
    float minimumHeight = _pageViewController.navigationController.navigationBar.frame.size.height*3 + topBarHeight;
    CGRect toolbarFrame = _pageViewController.animatedView.frame;
    toolbarFrame.size.height = minimumHeight;

    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _alertInfoLabel.frame = infoLabelFrame;
        _voipController.view.frame = self.view.bounds;
        _pageViewController.animatedView.frame = toolbarFrame;
        
        _alertButtonView.alpha = 0.0f;
        _detailsButtonView.alpha = 0.0f;
        _chatButtonView.alpha = 0.0f;

    } completion:^(BOOL finished) {
        [self showPhoneInfoView];
    }];
    
    if (![TSAlertManager sharedManager].callInProgress) {
        [[TSAlertManager sharedManager] startTwilioCall];
    }
}

- (void)showPhoneInfoView {
    
    [UIView animateWithDuration:0.3 animations:^{
        _phoneInfoLabelsView.alpha = 1.0f;
    }];
}

- (void)dismissPhoneView {
    
    _pageViewController.isPhoneView = NO;
    
    [self returnToAlertView];
}

- (void)returnToAlertView {
    
    CGRect frame = self.view.bounds;
    frame.origin.y = frame.size.height;
    
    float topBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height + _pageViewController.navigationController.navigationBar.frame.size.height;
    
    CGRect infoLabelFrame = _alertInfoLabel.frame;
    infoLabelFrame.origin.y = topBarHeight;
    
    float minimumHeight = _pageViewController.navigationController.navigationBar.frame.size.height + topBarHeight;
    CGRect toolbarFrame = _pageViewController.animatedView.frame;
    toolbarFrame.size.height = minimumHeight;
    
    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _alertInfoLabel.frame = infoLabelFrame;
        _voipController.view.frame = frame;
        _pageViewController.animatedView.frame = toolbarFrame;
        
        _alertButtonView.alpha = 1.0f;
        _detailsButtonView.alpha = 1.0f;
        _chatButtonView.alpha = 1.0f;
        
        _phoneInfoLabelsView.alpha = 0.0f;
        
    } completion:nil];
}


#pragma mark - Scroll View offsets

- (void)parentScrollViewOffset:(float)offsetX {
    
//    NSUInteger page = (int)ceilf(offsetX/self.view.frame.size.width);
    NSUInteger halfPage = (int)roundf(offsetX/self.view.frame.size.width);
//    float ratio = offsetX/self.view.frame.size.width;
//    float ratioChange = 1 - offsetX/self.view.frame.size.width;
    
    float labelOffset = 0;
    float bottomOffset = 0;
    float voipOffsetY = 0;
    
    voipOffsetY = self.view.frame.size.width - offsetX;
    
    if (halfPage == 0) {
        labelOffset = -offsetX;
        bottomOffset = self.view.frame.size.width/2;
    }
    
    if (halfPage == 1) {
        labelOffset = -self.view.frame.size.width/2;
        labelOffset -= self.view.frame.size.width/2 - offsetX;
        bottomOffset = self.view.frame.size.width/2 - (offsetX - self.view.frame.size.width/2);
    }
    
    CGRect frame = _alertInfoLabel.frame;
    frame.origin.x = labelOffset;
    _alertInfoLabel.frame = frame;
    
    frame = _phoneInfoLabelsView.frame;
    frame.origin.x = labelOffset;
    _phoneInfoLabelsView.frame = frame;
    
    
    if (_pageViewController.isPhoneView) {
        frame = _voipController.view.frame;
        frame.origin.x = labelOffset;
        frame.origin.y = voipOffsetY;
        _voipController.view.frame = frame;
    }
    
    frame = _bottomButtonContainerView.frame;
    frame.origin.x = bottomOffset;
    _bottomButtonContainerView.frame = frame;
}

@end
