//
//  TSBaseViewController.m
//  TapShield
//
//  Created by Ben Boyd on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"

@interface TSBaseViewController ()

@end

@implementation TSBaseViewController

- (void)presentViewControllerWithClass:(Class)viewControllerClass transitionDelegate:(id <UIViewControllerTransitioningDelegate>)delegate animated:(BOOL)animated {
    
    UIViewController *viewController = [[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([viewControllerClass class])];
    
    UINavigationController *navigationViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navigationViewController setNavigationBarHidden:animated];
    navigationViewController.navigationBar.tintColor = [TSColorPalette tapshieldBlue];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
    
    if (delegate) {
        [navigationViewController setTransitioningDelegate:delegate];
        navigationViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
    [self presentViewController:navigationViewController animated:animated completion:^{
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }];
}

- (void)pushViewControllerWithClass:(Class)viewControllerClass transitionDelegate:(id <UIViewControllerTransitioningDelegate>)transitionDelegate navigationDelegate:(id <UINavigationControllerDelegate>)navigationDelegate animated:(BOOL)animated {
    
    UIViewController *viewController = [[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([viewControllerClass class])];
    
    if (transitionDelegate && navigationDelegate) {
        viewController.transitioningDelegate = transitionDelegate;
        self.navigationController.delegate = navigationDelegate;
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTranslucentBackground:(BOOL)translucentBackground {
    
    _translucentBackground = translucentBackground;
    
    if (translucentBackground) {
        _toolbar = [[UIToolbar alloc] initWithFrame:self.view.bounds];
        _toolbar.barStyle = UIBarStyleBlack;
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:_toolbar atIndex:0];
    }
}

@end
