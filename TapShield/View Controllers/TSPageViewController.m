//
//  TSPageViewController.m
//  TapShield
//
//  Created by Adam Share on 3/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSPageViewController.h"
#import "TSDisarmPadViewController.h"
#import "TSEmergencyAlertViewController.h"
#import "TSChatViewController.h"

@interface TSPageViewController ()

@end

@implementation TSPageViewController

+ (void)presentFromViewController:(UIViewController *)presentingController transitionDelegate:(id <UIViewControllerTransitioningDelegate>)delegate {
    
    TSPageViewController *alertPageView = [[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"TSPageViewController"];
    UINavigationController *navigationViewController = [[UINavigationController alloc] initWithRootViewController:alertPageView];
    [navigationViewController setNavigationBarHidden:YES];
    
    [presentingController.navigationController setNavigationBarHidden:YES animated:YES];
    [presentingController.navigationController setToolbarHidden:YES animated:YES];
    
    [navigationViewController setTransitioningDelegate:delegate];
    navigationViewController.modalPresentationStyle = UIModalPresentationCustom;
    [presentingController presentViewController:navigationViewController animated:YES completion:^{
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    _toolbar = [[UIToolbar alloc] initWithFrame:self.view.bounds];
    _toolbar.barStyle = UIBarStyleBlack;
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:_toolbar atIndex:0];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil];
    TSDisarmPadViewController *TSDisarmPadViewController = [storyboard instantiateViewControllerWithIdentifier:@"TSDisarmPadViewController"];
    TSEmergencyAlertViewController *TSEmergencyAlertViewController = [storyboard instantiateViewControllerWithIdentifier:@"TSEmergencyAlertViewController"];
    TSChatViewController *TSChatViewController = [storyboard instantiateViewControllerWithIdentifier:@"TSChatViewController"];
    
    _alertViewControllers = @[TSDisarmPadViewController, TSEmergencyAlertViewController, TSChatViewController];
    
    [self setViewControllers:@[TSDisarmPadViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.delegate = self;
    self.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Page View Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    NSUInteger index = [_alertViewControllers indexOfObject:[previousViewControllers lastObject]];
    
    if (!completed) {
        if (index >= 1) {
            if (self.navigationController.navigationBarHidden) {
                [self.navigationController setNavigationBarHidden:NO animated:YES];
            }
        }
    }
    else {
        if (index == 0) {
            if (self.navigationController.navigationBarHidden) {
                [self.navigationController setNavigationBarHidden:NO animated:YES];
            }
        }
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
    NSLog(@"willTransitionToViewControllers, %@", pendingViewControllers);
    
    NSUInteger index = [_alertViewControllers indexOfObject:[pendingViewControllers lastObject]];
    if (index == 0) {
        if (!self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        }
    }
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
