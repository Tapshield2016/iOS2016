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

- (void)presentViewControllerWithClass:(Class)viewControllerClass transitionDelegate:(id <UIViewControllerTransitioningDelegate>)delegate {
    
    UIViewController *chatViewController = [[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([viewControllerClass class])];
    
    UINavigationController *navigationViewController = [[UINavigationController alloc] initWithRootViewController:chatViewController];
    [navigationViewController setNavigationBarHidden:YES];
    navigationViewController.navigationBar.tintColor = [TSColorPalette tapshieldBlue];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    [navigationViewController setTransitioningDelegate:delegate];
    navigationViewController.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:navigationViewController animated:YES completion:^{
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }];
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

@end
