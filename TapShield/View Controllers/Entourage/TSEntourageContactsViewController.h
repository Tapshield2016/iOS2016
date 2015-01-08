//
//  TSEntourageContactsViewController.h
//  TapShield
//
//  Created by Adam Share on 10/24/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TSEntourageContactsTableViewController.h"
#import "TSRoundRectButton.h"

@interface TSEntourageContactsViewController : TSBaseViewController

@property (weak, nonatomic) IBOutlet TSRoundRectButton *permissionsButton;
@property (strong, nonatomic) TSEntourageContactsTableViewController *tableViewController;
@property (weak, nonatomic) IBOutlet UIView *permissionsView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

- (IBAction)getPermission:(id)sender;

@end
