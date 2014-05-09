//
//  TSPageViewController.m
//  TapShield
//
//  Created by Adam Share on 3/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSPageViewController.h"


@interface TSPageViewController ()

@property (assign, nonatomic) NSUInteger page;
@property (assign, nonatomic) NSUInteger halfPage;

@end

@implementation TSPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.translucentBackground = YES;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*2, self.view.bounds.size.height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    _isFirstTimeViewed = YES;
    
    [self initPages];
    
    _animatedView = [[UIView alloc] initWithFrame:self.view.frame];
    _animatedView.backgroundColor = [UIColor clearColor];
    _animatedView.opaque = NO;
    _animatedView.clipsToBounds = YES;
    
    CGRect frame = self.view.frame;
    frame.origin.y += self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.toolbar.frame = frame;
    [_animatedView addSubview:self.toolbar];
    [self.view insertSubview:_animatedView atIndex:0];
    [self createCountdownView];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.showLargeLogo = YES;
    
    [self sendBarButton];
    [self setRemoveNavigationShadow:YES];
    
    _isPhoneView = NO;
    
    if (![[TSAlertManager sharedManager].status isEqualToString:kAlertSend]) {
        [self showAlertViewController];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self blackNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self startTintViewAnimation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendBarButton {
    
    if (self.navigationItem.rightBarButtonItem) {
        return;
    }
    
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleBordered target:self action:@selector(showAlertViewController)];
    [barButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                        NSFontAttributeName :[TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f]} forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:barButton animated:YES];
}

- (void)alertBarButton {
    
    if (self.navigationItem.rightBarButtonItem) {
        return;
    }
    
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Alert" style:UIBarButtonItemStyleBordered target:self action:@selector(showAlertViewController)];
    [barButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
    NSFontAttributeName :[TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f]} forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:barButton animated:YES];
}

- (void)disarmBarButton {
    
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    if (self.navigationItem.leftBarButtonItem) {
        return;
    }
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Disarm" style:UIBarButtonItemStyleBordered target:self action:@selector(showDisarmViewController)];
    [barButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                        NSFontAttributeName :[TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f]} forState:UIControlStateNormal];
    [self.navigationItem setLeftBarButtonItem:barButton animated:YES];
}

#pragma mark - Init UI Features

- (void)createSplitTranslucentBackground {
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2);
    _topToolbar = [[UIToolbar alloc] initWithFrame:frame];
    _bottomToolbar = [[UIToolbar alloc] initWithFrame:frame];
    _topTintView = [[UIView alloc] initWithFrame:frame];
    frame.origin.y = frame.size.height;
    _bottomTintView = [[UIView alloc] initWithFrame:frame];
    
    _topTintView.backgroundColor = [UIColor clearColor];
    _bottomTintView.backgroundColor = [UIColor clearColor];
    
    _topToolbar.barStyle = UIBarStyleBlack;
    _bottomToolbar.barStyle = UIBarStyleBlack;
    
    [_topTintView addSubview:_topToolbar];
    [_bottomTintView addSubview:_bottomToolbar];
    [self.view insertSubview:_topTintView atIndex:0];
    [self.view insertSubview:_bottomTintView atIndex:0];
}

- (void)createCountdownView {
    
    _countdownTintView = [[UIView alloc] initWithFrame:self.view.bounds];
    _countdownTintView.opaque = NO;
    _countdownTintView.userInteractionEnabled = NO;
    CGRect frame = _countdownTintView.frame;
    frame.origin.y = self.view.frame.size.height - 10.0f;
    _countdownTintView.frame = frame;
    _countdownTintView.backgroundColor = [[TSColorPalette tapshieldBlue] colorWithAlphaComponent:1.0];
    [_animatedView insertSubview:_countdownTintView atIndex:0];
    
}

- (void)initPages {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil];
    
    if ([UIScreen mainScreen].bounds.size.height < 500) {
        _disarmPadViewController = [storyboard instantiateViewControllerWithIdentifier:@"TSDisarmPadViewController3.5"];
    }
    else {
        _disarmPadViewController = [storyboard instantiateViewControllerWithIdentifier:@"TSDisarmPadViewController"];
    }
    
    _disarmPadViewController.superviewViewController = self;
    _emergencyAlertViewController = [storyboard instantiateViewControllerWithIdentifier:@"TSEmergencyAlertViewController"];
    _emergencyAlertViewController.superviewViewController = self;

    _chatViewController = [storyboard instantiateViewControllerWithIdentifier:@"TSChatViewController"];
    
    CGRect frame = _emergencyAlertViewController.view.frame;
    frame.origin.x += frame.size.width;
    _emergencyAlertViewController.view.frame = frame;
    [_scrollView addSubview:_emergencyAlertViewController.view];
    [_scrollView addSubview:_disarmPadViewController.view];
}

#pragma mark - Background Animation


- (void)startTintViewAnimation {
    
    NSDate *endDate = [TSAlertManager sharedManager].endDate;
    if (!endDate) {
        [self stopTintViewAnimation];
        return;
    }
    if ([endDate timeIntervalSinceNow] > 0) {
        [UIView animateWithDuration:[endDate timeIntervalSinceNow] delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            _countdownTintView.frame = self.view.frame;
            _countdownTintView.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.5f];
        } completion:nil];
    }
}

- (void)stopTintViewAnimation {
    
    [_countdownTintView.layer removeAllAnimations];
    
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionTransitionCrossDissolve  animations:^{
        _countdownTintView.frame = self.view.frame;
        _countdownTintView.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.2f];
        
    } completion:nil];
}


#pragma mark - Change Pages

- (void)showDisarmViewController {

    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
 
    [_scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
}

- (void)showAlertViewController {
    
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0.0) animated:YES];
}


- (void)showingAlertView {
    
    if ([[TSAlertManager sharedManager].status isEqualToString:kAlertSend]) {
        [[TSAlertManager sharedManager] sendAlert:nil];
        [self stopTintViewAnimation];
        _isFirstTimeViewed = NO;
    }
    
    [self disarmBarButton];
}


#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
    _page = (int)ceilf(scrollView.contentOffset.x/scrollView.frame.size.width);
    _halfPage = (int)roundf(scrollView.contentOffset.x/scrollView.frame.size.width);
    
    float transformOffset = scrollView.contentOffset.x/320;
    float inverseOffset = 1 - transformOffset;
    
    if (transformOffset > 0) {
        transformOffset += .5;
        
        if (inverseOffset < .5) {
            inverseOffset = .5;
        }
    }
    
    if (transformOffset >= 1.5) {
        inverseOffset = 1.0;
    }
    
    _disarmPadViewController.view.alpha = inverseOffset;
    _disarmPadViewController.view.transform = CGAffineTransformMakeScale(inverseOffset, inverseOffset);
    
    float topBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    float minimumHeight = self.navigationController.navigationBar.frame.size.height + topBarHeight;
    if (_isPhoneView) {
        minimumHeight = self.navigationController.navigationBar.frame.size.height*3 + topBarHeight;
    }
    float animationHeight = self.view.frame.size.height;
    float toolbarFrameHeight = minimumHeight;
    float disarmOffset = 0;
    
    float ratio = scrollView.contentOffset.x/self.view.frame.size.width;
    float ratioChange = 1 - scrollView.contentOffset.x/self.view.frame.size.width;
    
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [[UIColor whiteColor] colorWithAlphaComponent:ratioChange],
                                                                     NSFontAttributeName :[TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f]}
                                                          forState:UIControlStateNormal];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [[UIColor whiteColor] colorWithAlphaComponent:ratio],
                                                                     NSFontAttributeName :[TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f]}
                                                          forState:UIControlStateNormal];
    
    switch (_page) {
        case 1:
            toolbarFrameHeight += animationHeight * ratioChange;
            disarmOffset -= scrollView.contentOffset.x/2;
            break;
            
        case 2:
            toolbarFrameHeight = minimumHeight;
            break;
            
        default:
            toolbarFrameHeight = self.view.frame.size.height;
            break;
    }
    
    CGRect frame = _animatedView.frame;
    frame.size.height = toolbarFrameHeight;
    _animatedView.frame = frame;
    
    frame = _disarmPadViewController.view.frame;
    frame.origin.x = disarmOffset;
    _disarmPadViewController.view.frame = frame;
    
    [_emergencyAlertViewController parentScrollViewOffset:scrollView.contentOffset.x];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    [self checkPage];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self checkPage];
}


- (void)checkPage {
    
    if (_halfPage == 1) {
        [self showingAlertView];
    }
    else if (_halfPage == 0) {
        [self alertBarButton];
    }
}

@end
