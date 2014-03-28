//
//  TSSettingsViewController.h
//  TapShield
//
//  Created by Ben Boyd on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSNavigationViewController.h"

@class MSDynamicsDrawerViewController;

@interface TSSettingsViewController : TSNavigationViewController
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;


- (IBAction)logOutUser:(id)sender;

@end
