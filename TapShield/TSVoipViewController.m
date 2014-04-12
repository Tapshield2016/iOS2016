//
//  TSVoipViewController.m
//  TapShield
//
//  Created by Adam Share on 4/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSVoipViewController.h"
#import "TSEmergencyAlertViewController.h"
#import "TSPageViewController.h"

@interface TSVoipViewController ()

@end

@implementation TSVoipViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    self.translucentBackground = YES;
    CGRect frame = self.view.frame;
    frame.origin.y = 350;
    frame.size.width += frame.size.width;
    self.toolbar.frame = frame;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showChatViewController:(id)sender {
    
    TSEmergencyAlertViewController *emergencyView = (TSEmergencyAlertViewController *)_emergencyView;
    
    [emergencyView performSelectorOnMainThread:@selector(showChatViewController:) withObject:self waitUntilDone:YES];
}

- (IBAction)addAlertDetails:(id)sender {
    
}


@end
