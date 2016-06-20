//
//  TSSettingsViewController.h
//  TapShield
//
//  Created by Ben Boyd on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSNavigationViewController.h"
#import "TSSocialAccountsManager.h"
#import "TSSettingsSwitch.h"

@interface TSSettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIButton *logOutButton;

@property (weak, nonatomic) IBOutlet TSBaseLabel *currentOrgLabel;
@property (weak, nonatomic) IBOutlet TSSettingsSwitch *iCloudSwitch;
@property (weak, nonatomic) IBOutlet TSSettingsSwitch *pushNotificationsSwitch;
@property (weak, nonatomic) IBOutlet TSSettingsSwitch *autoYankSwitch;

- (IBAction)iCloudToggle:(id)sender;
- (IBAction)notificationsToggle:(id)sender;
- (IBAction)autoYankToggle:(id)sender;

- (IBAction)logOutUser:(id)sender;

@end
