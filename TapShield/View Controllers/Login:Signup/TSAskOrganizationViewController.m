//
//  TSEmailOrganizationViewController.m
//  TapShield
//
//  Created by Adam Share on 2/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAskOrganizationViewController.h"
#import "TSOrganizationSearchViewController.h"

@interface TSAskOrganizationViewController ()

@end

@implementation TSAskOrganizationViewController

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
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)noOrganization:(id)sender {
    TSRegistrationNavigationController *navigationController = [[TSRegistrationNavigationController alloc] initWithoutOrganizationViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)yesOrganization:(id)sender {
    TSRegistrationNavigationController *navigationController = [[TSRegistrationNavigationController alloc] initWithOrganizationViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
