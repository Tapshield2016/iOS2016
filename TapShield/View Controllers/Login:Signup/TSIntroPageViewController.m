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
    
    [self.navigationController setNavigationBarHidden:YES];
    
    _isFirstTimeViewed = YES;
    
    _backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background568"]];
    _backgroundImage.frame = self.view.frame;
    [self.view insertSubview:_backgroundImage atIndex:0];
    
    _logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splash_logo_small"]];
    [_logoImage setHidden:YES];
    [self.view insertSubview:_logoImage atIndex:1];
    
    _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    _skipButton.titleLabel.font = [TSRalewayFont customFontFromStandardFont:[UIFont systemFontOfSize:18]];
    _skipButton.frame = CGRectMake(self.view.frame.size.width/10 * 8, self.view.frame.size.height/14 * 13, self.view.frame.size.width/10 * 2, self.view.frame.size.height/14);
    [self.view addSubview:_skipButton];
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil];
    
    _welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([TSWelcomeViewController class])];
    
    _logInOrSignUpViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([TSLoginOrSignUpViewController class])];
    
    _pageViewControllers = @[_welcomeViewController, _logInOrSignUpViewController];
    
    NSLog(@"%@", _welcomeViewController.smallLogoImageView);
    
    [self setViewControllers:@[_welcomeViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.delegate = self;
    self.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
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
    
    if (completed) {
        if ([[previousViewControllers lastObject] isEqual:_pageViewControllers[_pageViewControllers.count - 2]]) {
            [_skipButton setHidden:YES];
        }
        else {
            [_skipButton setHidden:NO];
        }
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
    
    return _pageViewControllers.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    
    [self setupPageControlAppearance];
    
    return 0;
}


- (void)setupPageControlAppearance {
    
//    UIPageControl * pageControl = [[self.view.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(class = %@)", [UIPageControl class]]] lastObject];
    
}

@end
