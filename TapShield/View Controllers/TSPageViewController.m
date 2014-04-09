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
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    _countdownTintView = [[UIView alloc] initWithFrame:self.view.bounds];
    _countdownTintView.opaque = NO;
    _countdownTintView.userInteractionEnabled = NO;
    CGRect frame = _countdownTintView.frame;
    frame.origin.y = self.view.frame.size.height - 10.0f;
    _countdownTintView.frame = frame;
    _countdownTintView.backgroundColor = [[TSColorPalette tapshieldBlue] colorWithAlphaComponent:1.0];
    
    [self setTranslucentBackground:YES];
    [self.view insertSubview:_countdownTintView atIndex:0];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil];
    _disarmPadViewController = [storyboard instantiateViewControllerWithIdentifier:@"TSDisarmPadViewController"];
    _emergencyAlertViewController = [storyboard instantiateViewControllerWithIdentifier:@"TSEmergencyAlertViewController"];
    _chatViewController = [storyboard instantiateViewControllerWithIdentifier:@"TSChatViewController"];
    
    _pageViewControllers = @[_disarmPadViewController, _emergencyAlertViewController];
    
    [self setViewControllers:@[_disarmPadViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    _currentViewController = _disarmPadViewController;
    
    self.delegate = self;
    self.dataSource = self;
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            NSLog(@"%@", view.subviews);
            ((UIScrollView *)view).delegate = self;
            self.scrollView = (UIScrollView *)view;
            break;
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (_isFirstTimeViewed) {
        [UIView animateWithDuration:10.0f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            _countdownTintView.frame = self.view.frame;
            _countdownTintView.backgroundColor = [TSColorPalette colorWithRed:255/255 green:153/255 blue:153/255 alpha:1.0f];
        } completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showChatViewController {
    
    _transitioningViewController = nil;
    __weak TSPageViewController *weakSelf = self;
    [self setViewControllers:@[_chatViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        weakSelf.currentViewController = weakSelf.chatViewController;
    }];
}

- (void)showDisarmViewController {
    
    _transitioningViewController = nil;
    __weak TSPageViewController *weakSelf = self;
    [self setViewControllers:@[_disarmPadViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
        weakSelf.currentViewController = weakSelf.disarmPadViewController;
    }];
    
}

- (void)showAlertScreen {
    
    _transitioningViewController = nil;
    __weak TSPageViewController *weakSelf = self;
    [self setViewControllers:@[_emergencyAlertViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        weakSelf.currentViewController = weakSelf.emergencyAlertViewController;
    }];
    
    [self showingAlertView];
}


- (void)showingAlertView {
    
    if (_isFirstTimeViewed) {
        [_disarmPadViewController sendEmergency];
        [self stopTintViewAmination];
        _isFirstTimeViewed = NO;
    }
}

#pragma mark - Background Animation

- (void)stopTintViewAmination {
    
    [_countdownTintView.layer removeAllAnimations];
    
    
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        _countdownTintView.frame = self.view.frame;
        _countdownTintView.backgroundColor = [TSColorPalette colorWithRed:255/255 green:153/255 blue:153/255 alpha:0.3f];
        
    } completion:nil];
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
}
@end
