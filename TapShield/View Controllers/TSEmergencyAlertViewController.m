//
//  TSEmergencyAlertViewViewController.m
//  TapShield
//
//  Created by Adam Share on 3/6/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEmergencyAlertViewController.h"
#import "TSPageViewController.h"

@interface TSEmergencyAlertViewController ()

@end

@implementation TSEmergencyAlertViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (!self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    self.navigationController.navigationBar.topItem.title = self.title;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)speakerPhoneToggle:(id)sender {
}

- (IBAction)redialPhoneNumber:(id)sender {
}

- (IBAction)showChatViewController:(id)sender {
    
    UIViewController *viewController = ((TSPageViewController *)self.parentViewController).chatViewController;
    [self.navigationController pushViewController:viewController animated:YES];
}
@end
