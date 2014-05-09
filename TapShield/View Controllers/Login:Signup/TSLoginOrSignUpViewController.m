//
//  TSLoginOrSignUpViewController.m
//  TapShield
//
//  Created by Ben Boyd on 2/3/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSLoginOrSignUpViewController.h"
#import "TSSocialAuthorizationViewController.h"
#import "TSLoginViewController.h"
#import "TSAskOrganizationViewController.h"

@interface TSLoginOrSignUpViewController ()

@end

@implementation TSLoginOrSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showLoginView:(id)sender {
    
//    [self socialLogInView:YES];
    
    TSLoginViewController *viewController = (TSLoginViewController *)[[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSLoginViewController class])];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navigationController setNavigationBarHidden:YES];
    
    [self presentViewController:navigationController animated:NO completion:nil];
}

- (IBAction)showSignUpView:(id)sender {
    
//    [self socialLogInView:NO];
    
    TSAskOrganizationViewController *viewController = (TSAskOrganizationViewController *)[[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSAskOrganizationViewController class])];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navigationController setNavigationBarHidden:YES];
    
    [self presentViewController:navigationController animated:NO completion:nil];
    
//    Class class;
//    
//    if (_logIn) {
//        class = [TSLoginViewController class];
//    }
//    else {
//        class = [TSAskOrganizationViewController class];
//    }
//    
//    _transitionDelegate = [[TSTransitionDelegate alloc] init];
//    
//    [self pushViewControllerWithClass:class transitionDelegate:_transitionDelegate navigationDelegate:_transitionDelegate animated:YES];
}

- (IBAction)requestDemo:(id)sender {
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://tapshield.com/demo-landing-page/"]] ;
//    [_webView loadRequest: request];
//    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://tapshield.com/demo-landing-page/"]];
}

- (void)socialLogInView:(BOOL)login {
    
    TSSocialAuthorizationViewController *viewController = [[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSSocialAuthorizationViewController class])];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navigationController setNavigationBarHidden:YES];
    
    viewController.logIn = login;
    
    [self presentViewController:navigationController animated:NO completion:nil];
}

@end
