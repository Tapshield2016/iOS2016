//
//  TSIntroPageViewController.m
//  TapShield
//
//  Created by Adam Share on 3/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSIntroPageViewController.h"

@interface TSIntroPageViewController ()

@end

@implementation TSIntroPageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _isFirstTimeViewed = YES;
    
    
    [self setTranslucentBackground:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil];
    
    _logInOrSignUpViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([TSLoginOrSignUpViewController class])];
//    _socialAuthorizationViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([TSSocialAuthorizationViewController class])];
    _loginViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([TSLoginViewController class])];
    
    _pageViewControllers = @[_logInOrSignUpViewController];
    
    [self setViewControllers:@[_logInOrSignUpViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    //self.delegate = self;
    //self.dataSource = self;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Page View Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    NSUInteger index = [_pageViewControllers indexOfObject:[previousViewControllers lastObject]];
    
    switch (index) {
        case 0:
            
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
    
    NSUInteger index = [_pageViewControllers indexOfObject:viewController];
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    
    return _pageViewControllers[index - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [_pageViewControllers indexOfObject:viewController];
    if (index == _pageViewControllers.count - 1 || index == NSNotFound) {
        return nil;
    }
    
    return _pageViewControllers[index + 1];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    
    return 0;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    
    return 0;
}


@end
