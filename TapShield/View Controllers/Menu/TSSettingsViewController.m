//
//  TSSettingsViewController.m
//  TapShield
//
//  Created by Ben Boyd on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSSettingsViewController.h"
#import "TSYankManager.h"
#import "TSIntroPageViewController.h"

NSString * const TSSettingsNotificationsEnabled = @"TSSettingsNotificationsEnabled";
NSString * const TSSettingsICloudSyncEnabled = @"TSSettingsICloudSyncEnabled";

NSString * const TSSettingsViewControllerDidLogOut = @"TSSettingsViewControllerDidLogOut";

@interface TSSettingsViewController ()

@end

@implementation TSSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[TSSocialAccountsManager sharedSocialAccountsManager] addSocialViewsTo:self.view];
    
    _autoYankSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:TSYankManagerSettingAutoEnableYank];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)iCloudToggle:(id)sender {
    UISwitch *toggle = (UISwitch *)sender;
    [[NSUserDefaults standardUserDefaults] setBool:toggle.on forKey:TSSettingsICloudSyncEnabled];
}

- (IBAction)notificationsToggle:(id)sender {
    UISwitch *toggle = (UISwitch *)sender;
    [[NSUserDefaults standardUserDefaults] setBool:toggle.on forKey:TSSettingsNotificationsEnabled];
}

- (IBAction)autoYankToggle:(id)sender {
    
    UISwitch *toggle = (UISwitch *)sender;
    [[NSUserDefaults standardUserDefaults] setBool:toggle.on forKey:TSYankManagerSettingAutoEnableYank];
}

- (IBAction)logOutUser:(id)sender {

    [[TSSocialAccountsManager sharedSocialAccountsManager] logoutAllUserTypesCompletion:^(BOOL loggedOut) {
        if (loggedOut) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TSSettingsViewControllerDidLogOut object:nil];
        }
    }];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.backgroundColor = [TSColorPalette listBackgroundColor];
    tableView.separatorColor = [TSColorPalette tapshieldBlue];
    tableView.separatorInset = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 4) {
        return self.view.frame.size.height - 64*5;
    }
    
    return 64;
}

@end
