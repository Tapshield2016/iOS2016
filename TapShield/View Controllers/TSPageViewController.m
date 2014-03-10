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
    CGRect frame = _countdownTintView.frame;
    frame.origin.y = self.view.frame.size.height - 10.0f;
    _countdownTintView.frame = frame;
    _countdownTintView.backgroundColor = [[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.6];
    [self.view insertSubview:_countdownTintView atIndex:0];
    
    _toolbar = [[UIToolbar alloc] initWithFrame:self.view.bounds];
    _toolbar.barStyle = UIBarStyleBlack;
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:_toolbar atIndex:0];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil];
    _disarmPadViewController = [storyboard instantiateViewControllerWithIdentifier:@"TSDisarmPadViewController"];
    _emergencyAlertViewController = [storyboard instantiateViewControllerWithIdentifier:@"TSEmergencyAlertViewController"];
    _chatViewController = [storyboard instantiateViewControllerWithIdentifier:@"TSChatViewController"];
    
    _alertViewControllers = @[_disarmPadViewController, _emergencyAlertViewController];
    
    [self setViewControllers:@[_disarmPadViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.delegate = self;
    self.dataSource = self;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:10.0f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        _countdownTintView.frame = self.view.frame;
        _countdownTintView.backgroundColor = [TSColorPalette colorWithRed:255/255 green:153/255 blue:153/255 alpha:0.2f];
    } completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showChatViewController {
    
    [self setViewControllers:@[_chatViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

#pragma mark - Background Animation

- (void)stopTintViewAmination {
    
    [_countdownTintView.layer removeAllAnimations];
    
    
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        _countdownTintView.frame = self.view.frame;
        _countdownTintView.backgroundColor = [TSColorPalette colorWithRed:255/255 green:153/255 blue:153/255 alpha:0.2f];
        
    } completion:nil];
}


#pragma mark - Page View Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    NSUInteger index = [_alertViewControllers indexOfObject:[previousViewControllers lastObject]];
    
    switch (index) {
        case 0:
            if (completed) {
                
                if (_isFirstTimeViewed) {
                    if (!_disarmPadViewController.isSendingAlert) {
                        [_disarmPadViewController sendEmergency:nil];
                        [self stopTintViewAmination];
                    }
                    _isFirstTimeViewed = NO;
                }
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
    
    NSUInteger index = [_alertViewControllers indexOfObject:viewController];
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    
    return _alertViewControllers[index - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [_alertViewControllers indexOfObject:viewController];
    if (index == _alertViewControllers.count - 1 || index == NSNotFound) {
        return nil;
    }
    
    return _alertViewControllers[index + 1];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    
    return 0;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    
    return 0;
}

@end
