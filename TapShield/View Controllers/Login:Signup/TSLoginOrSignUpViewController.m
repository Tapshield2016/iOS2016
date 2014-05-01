//
//  TSLoginOrSignUpViewController.m
//  TapShield
//
//  Created by Ben Boyd on 2/3/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSLoginOrSignUpViewController.h"
#import "TSSocialAuthorizationViewController.h"

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
    
    [self socialLogInView:YES];
}

- (IBAction)showSignUpView:(id)sender {
    
    [self socialLogInView:NO];
}

- (void)socialLogInView:(BOOL)login {
    
    TSSocialAuthorizationViewController *viewController = [[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSSocialAuthorizationViewController class])];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navigationController setNavigationBarHidden:YES];
    
    viewController.logIn = login;
    
    [self presentViewController:navigationController animated:NO completion:nil];
}

@end
