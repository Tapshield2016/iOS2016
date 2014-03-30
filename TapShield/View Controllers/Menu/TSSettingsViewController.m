//
//  TSSettingsViewController.m
//  TapShield
//
//  Created by Ben Boyd on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSSettingsViewController.h"
#import "TSIntroPageViewController.h"
#import "TSHomeViewController.h"

@interface TSSettingsViewController ()

@end

@implementation TSSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _socialAccounts = [[TSSocialAccountsManager alloc] init];
    [_socialAccounts addSocialViewsTo:self.view];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [_socialAccounts initializeFacebookView];
    [_socialAccounts addSocialViewsTo:self.view];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [_socialAccounts deallocFacebookView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logOutUser:(id)sender {

    [_socialAccounts logoutAllUserTypesCompletion:^(BOOL loggedOut) {
        if (loggedOut) {
            [self presentViewControllerWithClass:[TSIntroPageViewController class] transitionDelegate:nil animated:YES];
        }
    }];
}
@end
