//
//  TSEntourageMemberSettingsViewController.h
//  TapShield
//
//  Created by Adam Share on 11/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TSSettingsSwitch.h"
#import <MessageUI/MessageUI.h>

@interface TSEntourageMemberSettingsViewController : UITableViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet TSSettingsSwitch *alwaysVisibleSwitch;

@property (weak, nonatomic) IBOutlet TSSettingsSwitch *trackSessionSwitch;

@property (weak, nonatomic) IBOutlet TSSettingsSwitch *alert911Switch;
@property (weak, nonatomic) IBOutlet TSSettingsSwitch *alertArrivalSwitch;
@property (weak, nonatomic) IBOutlet TSSettingsSwitch *alertNonArrivalSwitch;
@property (weak, nonatomic) IBOutlet TSSettingsSwitch *alertYankSwitch;

@property (strong, nonatomic) TSJavelinAPIEntourageMember *member;

- (IBAction)done:(id)sender;
- (IBAction)visibleSwitched:(UISwitch *)sender;

@end
