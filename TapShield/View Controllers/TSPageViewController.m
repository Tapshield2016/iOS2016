//
//  TSPageViewController.m
//  TapShield
//
//  Created by Adam Share on 3/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSPageViewController.h"


@interface TSPageViewController ()

@end

@implementation TSPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _isFirstTimeViewed = YES;
    
//    [self createSplitTranslucentBackground];
    [self createCountdownView];
    [self initPages];
    
    self.delegate = self;
    self.dataSource = self;
    
    //Delegate for ScrollView
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            NSLog(@"%@", view.subviews);
            ((UIScrollView *)view).delegate = self;
            self.scrollView = (UIScrollView *)view;
            break;
        }
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.showLargeLogo = YES;
    
    [self sendBarButton];
    [self setRemoveNavigationShadow:YES];
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
    barButton.tintColor = [UIColor whiteColor];
    [self.navigationItem setRightBarButtonItem:barButton];
}

- (void)alertBarButton {
    
    if (self.navigationItem.rightBarButtonItem) {
        return;
    }
    
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Alert" style:UIBarButtonItemStyleBordered target:self action:@selector(showAlertViewController)];
    barButton.tintColor = [UIColor whiteColor];
    [self.navigationItem setRightBarButtonItem:barButton animated:YES];
}

- (void)disarmBarButton {
    
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    if (self.navigationItem.leftBarButtonItem) {
        return;
    }
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Disarm" style:UIBarButtonItemStyleBordered target:self action:@selector(showDisarmViewController)];
    barButton.tintColor = [UIColor whiteColor];
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
    [self.view insertSubview:_countdownTintView atIndex:0];
    
}

- (void)initPages {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil];
    _disarmPadViewController = [storyboard instantiateViewControllerWithIdentifier:@"TSDisarmPadViewController"];
    _disarmPadViewController.pageViewController = self;
    _emergencyAlertViewController = [storyboard instantiateViewControllerWithIdentifier:@"TSEmergencyAlertViewController"];
    _emergencyAlertViewController.pageViewController = self;
    
    _chatViewController = [storyboard instantiateViewControllerWithIdentifier:@"TSChatViewController"];
    
    _pageViewControllers = @[_disarmPadViewController, _emergencyAlertViewController];
    
    [self setViewControllers:@[_disarmPadViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    _currentViewController = _disarmPadViewController;
}

#pragma mark - Background Animation


- (void)startTintViewAnimation {
    
    if (_isFirstTimeViewed) {
        
        [_emergencyAlertViewController scheduleSendEmergencyTimer];
        
        [UIView animateWithDuration:10.0f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            _countdownTintView.frame = self.view.frame;
            _countdownTintView.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.5f];
        } completion:nil];
    }
}

- (void)stopTintViewAnimation {
    
    [_countdownTintView.layer removeAllAnimations];
    
    //|UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionTransitionCrossDissolve  animations:^{
        _countdownTintView.frame = self.view.frame;
        _countdownTintView.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.2f];
        
    } completion:nil];
}


#pragma mark - Change Pages

- (void)showChatViewController {
    
    _transitioningViewController = nil;
    __weak TSPageViewController *weakSelf = self;
    [self setViewControllers:@[_chatViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        weakSelf.currentViewController = weakSelf.chatViewController;
    }];
}

- (void)showDisarmViewController {
    
    [self alertBarButton];
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    
    _transitioningViewController = nil;
    __weak TSPageViewController *weakSelf = self;
    [self setViewControllers:@[_disarmPadViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
        weakSelf.currentViewController = weakSelf.disarmPadViewController;
    }];
}

- (void)showAlertViewController {
    
    [self disarmBarButton];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    _transitioningViewController = nil;
    __weak TSPageViewController *weakSelf = self;
    [self setViewControllers:@[_emergencyAlertViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        
        TSPageViewController *viewController = weakSelf;
        viewController.currentViewController = viewController.emergencyAlertViewController;
        [viewController showingAlertView];
    }];
}


- (void)showingAlertView {
    
    if (_isFirstTimeViewed) {
        [_emergencyAlertViewController sendEmergency];
        [self stopTintViewAnimation];
        _isFirstTimeViewed = NO;
    }
    
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    [self disarmBarButton];
}


#pragma mark - Page View Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    NSUInteger index = [self.pageViewControllers indexOfObject:[previousViewControllers lastObject]];
    
    if (completed) {
        if (_transitioningViewController) {
            _currentViewController = _transitioningViewController;
        }
    }
    
    switch (index) {
        case 0:
            if (completed) {
                [self showingAlertView];
            }
            
            break;
            
        case 1:
            
            if (!completed) {
                [self showingAlertView];
            }
            else {
                [self alertBarButton];
            }
            
            break;
            
        case 2:
            
            break;
            
        default:
            
            break;
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
    _transitioningViewController = [pendingViewControllers firstObject];
    
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    
    return UIPageViewControllerSpineLocationNone;
}

- (NSUInteger)pageViewControllerSupportedInterfaceOrientations:(UIPageViewController *)pageViewController {
    
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)pageViewControllerPreferredInterfaceOrientationForPresentation:(UIPageViewController *)pageViewController {
    
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Page View DataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self.pageViewControllers indexOfObject:viewController];
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    
    return self.pageViewControllers[index - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self.pageViewControllers indexOfObject:viewController];
    if (index == self.pageViewControllers.count - 1 || index == NSNotFound) {
        return nil;
    }
    
    return self.pageViewControllers[index + 1];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    
    return 0;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    
    return 0;
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    /*
    float correctedOffset = fabsf(scrollView.contentOffset.x - 320);
    float transformOffset = correctedOffset/320;
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
    
    if (transformOffset >= 1) {
        transformOffset = 1;
    }
    
    if (_currentViewController == _transitioningViewController) {
        _transitioningViewController = nil;
    }
    
    _currentViewController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.8-inverseOffset];
    _currentViewController.view.alpha = inverseOffset;
    _currentViewController.view.transform = CGAffineTransformMakeScale(inverseOffset, inverseOffset);
    
    if (transformOffset <= 0.0) {
        transformOffset = 1.0;
    }
    
    if (!_transitioningViewController) {
        return;
    }
    
    _transitioningViewController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.8-transformOffset];
    _transitioningViewController.view.transform = CGAffineTransformMakeScale(transformOffset, transformOffset);
    _transitioningViewController.view.alpha = transformOffset;
     */
}
@end
