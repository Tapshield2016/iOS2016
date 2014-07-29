//
//  TSIntroPageViewController.m
//  TapShield
//
//  Created by Adam Share on 3/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSIntroPageViewController.h"
#import "TSIntroSlideViewController.h"

@interface TSIntroPageViewController ()

@end

@implementation TSIntroPageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    _isFirstTimeViewed = YES;
    
    _backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background568"]];
    CGRect frame = self.view.frame;
    frame.size.height = 568.0;
    _backgroundImage.frame = frame;
    [self.view insertSubview:_backgroundImage atIndex:0];
    
    _logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splash_logo_small"]];
    [_logoImage setHidden:YES];
    [self.view insertSubview:_logoImage atIndex:1];
    
    _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    [_skipButton addTarget:self action:@selector(skipSlides:) forControlEvents:UIControlEventTouchUpInside];
    _skipButton.titleLabel.font = [TSRalewayFont customFontFromStandardFont:[UIFont systemFontOfSize:18]];
    _skipButton.frame = CGRectMake(self.view.frame.size.width/10 * 8, [UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width/10 * 2, self.navigationController.navigationBar.frame.size.height);
    [self.view addSubview:_skipButton];
    
    _pageViewControllers = [self pages];
    
    [self setViewControllers:@[_welcomeViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.delegate = self;
    self.dataSource = self;
    
    [self.view setUserInteractionEnabled:NO];
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

- (NSArray *)pages {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil];
    
    _welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([TSWelcomeViewController class])];
    [mutableArray addObject:_welcomeViewController];
    
    for (int i = INTRO_PAGESTART; i <= INTRO_PAGEEND; i++) {
        TSIntroSlideViewController *viewController = (TSIntroSlideViewController *)[storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([TSIntroSlideViewController class])];
        viewController.pageNumber = i;
        [mutableArray addObject:viewController];
    }
    
    _logInOrSignUpViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([TSLoginOrSignUpViewController class])];
    [mutableArray addObject:_logInOrSignUpViewController];
    
    return mutableArray;
}

- (IBAction)skipSlides:(id)sender {
    [self setViewControllers:@[_logInOrSignUpViewController] direction:UIPageViewControllerNavigationDirectionForward invalidateCache:YES animated:YES completion:nil];
//    [self setViewControllers:@[_logInOrSignUpViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [_skipButton setHidden:YES];
}

- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction {
    
    if (direction == UIAccessibilityScrollDirectionLeft) {
        [self changePage:UIPageViewControllerNavigationDirectionForward];
    }
    else if (direction == UIAccessibilityScrollDirectionRight) {
        [self changePage:UIPageViewControllerNavigationDirectionReverse];
    }
    
    return YES;
}

- (BOOL)changePage:(UIPageViewControllerNavigationDirection)direction {
    NSUInteger pageIndex = [_pageViewControllers indexOfObject:[self.viewControllers objectAtIndex:0]];
    
    
    if (direction == UIPageViewControllerNavigationDirectionForward) {
        pageIndex++;
    }
    else {
        pageIndex--;
    }
    
    if (pageIndex>=_pageViewControllers.count) {
        return NO;
    }
    
    UIViewController *viewController = [_pageViewControllers objectAtIndex:pageIndex];
    
    if (viewController == nil) {
        return NO;
    }
    
    [self setViewControllers:@[viewController]
                   direction:direction
                    animated:YES
                  completion:nil];
    return YES;
}


#pragma mark - Page View Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    if (completed) {
        [_skipButton setHidden:YES];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
    [_logoImage setHidden:NO];
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
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
                                                animated:YES];
    
    int index = [_pageViewControllers indexOfObject:self.viewControllers[0]];
    
    if (index < _pageViewControllers.count - 1) {
        [_skipButton setHidden:NO];
    }
    
    return index;
}

- (void)setViewControllers:(NSArray *)viewControllers direction:(UIPageViewControllerNavigationDirection)direction invalidateCache:(BOOL)invalidateCache animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    NSArray *vcs = viewControllers;
    __weak UIPageViewController *mySelf = self;
    
    if (invalidateCache && self.transitionStyle == UIPageViewControllerTransitionStyleScroll) {
        UIViewController *neighborViewController = (direction == UIPageViewControllerNavigationDirectionForward
                                                    ? [self.dataSource pageViewController:self viewControllerBeforeViewController:viewControllers[0]]
                                                    : [self.dataSource pageViewController:self viewControllerAfterViewController:viewControllers[0]]);
        [self setViewControllers:@[neighborViewController] direction:direction animated:NO completion:^(BOOL finished) {
            [mySelf setViewControllers:vcs direction:direction animated:animated completion:completion];
        }];
    }
    else {
        [mySelf setViewControllers:vcs direction:direction animated:animated completion:completion];
    }
}

@end
