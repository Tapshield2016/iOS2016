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
#import "TSChangePasscodeViewController.h"
#import "TSUserSessionManager.h"

NSString * const TSSettingsNotificationsEnabled = @"TSSettingsNotificationsEnabled";
NSString * const TSSettingsICloudSyncEnabled = @"TSSettingsICloudSyncEnabled";

NSString * const TSSettingsViewControllerDidLogOut = @"TSSettingsViewControllerDidLogOut";

NSString * const TSSettingsCurrentOrg = @"Your current organization: %@";

@interface TSSettingsViewController ()

@end

@implementation TSSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tableView.backgroundColor = [TSColorPalette listBackgroundColor];
    
    _autoYankSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:TSYankManagerSettingAutoEnableYank];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [self updateCurrentOrgLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateCurrentOrgLabel {
    
    NSString *orgName;
    if ([TSJavelinAPIClient loggedInUser].agency) {
        orgName = [TSJavelinAPIClient loggedInUser].agency.name;
    }
    else {
        orgName = @"Not selected";
    }
    
    _currentOrgLabel.text = [NSString stringWithFormat:TSSettingsCurrentOrg, orgName];
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
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] logoutUser:^(BOOL success) {
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TSSettingsViewControllerDidLogOut object:nil];
        }
        
        [[TSUserSessionManager sharedManager] userStatusCheck];
    }];
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 1 || indexPath.row == 2) {
        return YES;
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 1) {
        TSChangePasscodeViewController *viewController = (TSChangePasscodeViewController *)[[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSChangePasscodeViewController class])];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if (indexPath.row == 2) {
        
        [[TSUserSessionManager sharedManager] showAgencyPicker];
    }
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.backgroundColor = [TSColorPalette listBackgroundColor];
    tableView.separatorColor = [TSColorPalette tapshieldBlue];
    tableView.separatorInset = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
    
    if (indexPath.row == 1 || indexPath.row == 2) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron_icon"]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 4) {
        return self.view.frame.size.height - 64*5;
    }
    
    return 64;
}

@end
