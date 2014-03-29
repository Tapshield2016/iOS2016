//
//  TSSettingsViewController.h
//  TapShield
//
//  Created by Ben Boyd on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSNavigationViewController.h"
#import "TSSocialAccounts.h"

@interface TSSettingsViewController : TSNavigationViewController

@property (strong, nonatomic) TSSocialAccounts *socialAccounts;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;

- (IBAction)logOutUser:(id)sender;

@end
