//
//  TSOrganizationSearchViewController.m
//  TapShield
//
//  Created by Adam Share on 2/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSOrganizationSearchViewController.h"

@interface TSOrganizationSearchViewController ()

@end

@implementation TSOrganizationSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _statusString = @"Locating...";
    
    [self getOrganizationsToDisplay];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [_cancelBarButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSRalewayFont fontWithName:kFontRalewayMedium size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [_skipCancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSRalewayFont fontWithName:kFontRalewayMedium size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    _searchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchDisplay.delegate = self;
    _searchDisplay.searchResultsDataSource = self;
    _searchDisplay.searchResultsDelegate = self;
    
    self.navigationController.navigationBar.shadowImage = [UIImage imageFromColor:[UIColor whiteColor]];
    
    [self customizeTableView:_tableView];
    [self customizeSearchBarAppearance:_searchBar];
    
    _user = [[TSJavelinAPIUser alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if ([self.presentingViewController.restorationIdentifier isEqualToString:@"TSLoginOrSignUpNavigationController"]) {
        _skipCancelButton.title = @"Cancel";
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Bar Button Action

- (IBAction)skipOrCancel:(id)sender {
    
    [self segueSendingAgency:nil];
}

#pragma mark - Organization Methods

- (void)segueSendingAgency:(TSJavelinAPIAgency *)agency {
    
    if ([self.presentingViewController.restorationIdentifier isEqualToString:@"TSLoginOrSignUpNavigationController"]) {
        if (agency) {
            TSRegisterViewController *registerViewController = [((UINavigationController *)self.presentingViewController).viewControllers lastObject];
            registerViewController.user = _user;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    TSRegisterViewController *registerViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TSRegisterViewController"];
    if (_user) {
        registerViewController.user = _user;
    }
    
    [self.navigationController pushViewController:registerViewController animated:YES];
}

- (void)getOrganizationsToDisplay {
    [[TSJavelinAPIClient sharedClient] getAgencies:^(NSArray *agencies) {
        
        if (!agencies) {
            return;
        }
        
        _allOrganizationsArray = agencies;
        _filteredOrganizationMutableArray = [[NSMutableArray alloc] initWithCapacity:_allOrganizationsArray.count];
        
        [_tableView reloadData];
        [self getLocationAndSearchForNearbyAgencies];
    }];
}

- (void)getLocationAndSearchForNearbyAgencies {
    
    [[TSLocationController sharedLocationController] startStandardLocationUpdates:^(CLLocation *location) {
        [[TSLocationController sharedLocationController] stopLocationUpdates];
        [[TSJavelinAPIClient sharedClient] getAgenciesNearby:location radius:20.0f completion:^(NSArray *agencies) {
            if (agencies) {
                self.nearbyOrganizationArray = agencies;
            }
            else {
                self.statusString = @"None Found";
            }
            [self.tableView reloadData];
        }];
    }];
}



#pragma mark - Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
    _filteredOrganizationMutableArray = [NSMutableArray arrayWithArray:[_allOrganizationsArray filteredArrayUsingPredicate:predicate]];
}

#pragma mark - Table View Customization

- (void)customizeTableView:(UITableView *)tableView {
    
    tableView.separatorInset = UIEdgeInsetsZero;
    tableView.tintColor = [TSColorPalette tapshieldBlue];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.separatorColor = [TSColorPalette cellSeparatorColor];
    tableView.backgroundColor = [TSColorPalette listBackgroundColor];
    [tableView setSectionIndexBackgroundColor:[TSColorPalette tableViewHeaderColor]];
}

#pragma mark - Search Bar Customization

- (void)changeClearButtonStyle {
    
    if (!_clearButtonImage) {
        
        for (UIView *view in ((UITextField *)[_searchBar.subviews firstObject]).subviews) {
            
            if ([view isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
                
                for (UIButton *button in ((UITextField *)view).subviews) {
                    
                    if ([button isKindOfClass:[UIButton class]]) {
                        
                        _clearButtonImage = [button.imageView.image fillImageWithColor:[UIColor whiteColor]];
                        [button setImage:[button.imageView.image fillImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                        [button setImage:[button.imageView.image fillImageWithColor:[UIColor lightTextColor]] forState:UIControlStateHighlighted];
                        
                    }
                }
            }
        }
    }
}

- (void)customizeSearchBarAppearance:(UISearchBar *)searchBar {
    
    UITextField *textField = [((UITextField *)[searchBar.subviews firstObject]).subviews lastObject];
    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].backgroundColor = [TSColorPalette searchFieldBackgroundColor];
    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].font = [TSRalewayFont fontWithName:kFontRalewayMedium size:15.0];
    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].textColor = [UIColor whiteColor];
    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].tintColor = [UIColor whiteColor];
    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].borderStyle = UITextBorderStyleNone;
    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    
    textField.layer.cornerRadius = 3.0f;
    textField.layer.masksToBounds = YES;
    
    searchBar.tintColor = [TSColorPalette tapshieldBlue];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue], NSFontAttributeName : [UIFont fontWithName:kFontRalewayRegular size:17.0f] } forState:UIControlStateNormal];
    
    searchBar.barTintColor = [TSColorPalette listBackgroundColor];
    
    UIImage *leftViewImage = ((UIImageView *)textField.leftView).image;
    [searchBar setImage:[leftViewImage fillImageWithColor:[UIColor whiteColor]] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
}


#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    
    [self customizeTableView:tableView];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self performSelector:@selector(changeClearButtonStyle) withObject:nil afterDelay:0.01];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    _user.agency = _previousAgencySelected;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    _previousAgencySelected = _user.agency;
}

#pragma mark - TableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"OrganizationCell";
    
    TSOrganizationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[TSOrganizationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.agency = (TSJavelinAPIAgency *)[_filteredOrganizationMutableArray objectAtIndex:indexPath.row];
    } else {
        if (indexPath.section == 0) {
            if (_nearbyOrganizationArray.count == 0) {
                cell.organizationLabel.text = _statusString;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell setUserInteractionEnabled:NO];
            }
            else {
                cell.agency = (TSJavelinAPIAgency *)[_nearbyOrganizationArray objectAtIndex:indexPath.row];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                [cell setUserInteractionEnabled:YES];
            }
        }
        else {
            cell.agency = (TSJavelinAPIAgency *)[_allOrganizationsArray objectAtIndex:indexPath.row];
        }
    }
    
    UIView *selectedView = [[UIView alloc] initWithFrame:cell.frame];
    selectedView.backgroundColor = [TSColorPalette whiteColor];
    cell.selectedBackgroundView = selectedView;
    cell.backgroundColor = [TSColorPalette tableViewBackgroundColor];
    
    if ([_user.agency.name isEqualToString:cell.agency.name]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return _filteredOrganizationMutableArray.count;
    }
    
    if (section == 0) {
        if (_nearbyOrganizationArray.count == 0) {
            return 1;
        }
        return _nearbyOrganizationArray.count;
    }
    
    return _allOrganizationsArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return @"Results";
    }
    
    if (section == 0) {
        return @"Nearby";
    }
    
    return @"All";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    
    headerView.backgroundColor = [TSColorPalette tableViewHeaderColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width - 10, headerView.frame.size.height)];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [TSRalewayFont fontWithName:kFontRalewayMedium size:15.0f];
    [headerView addSubview:label];
    
    label.text = @"All";
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        label.text = @"Results";
    }
    else if (section == 0) {
        label.text = @"Organizations Nearby";
    }

    return headerView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    
    return 2;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selected) {
        cell.selected = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
        _user.agency = nil;
        return nil;
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        _user.agency = (TSJavelinAPIAgency *)[_filteredOrganizationMutableArray objectAtIndex:indexPath.row];
        [self.searchDisplayController setActive:NO animated:YES];
        [_tableView reloadData];
    }
    else {
        if (indexPath.section == 0) {
            _user.agency = (TSJavelinAPIAgency *)[_nearbyOrganizationArray objectAtIndex:indexPath.row];
        }
        else {
            _user.agency = (TSJavelinAPIAgency *)[_allOrganizationsArray objectAtIndex:indexPath.row];
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30.0f;
}


- (IBAction)dismissRegistration:(id)sender {
    
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }];
}
@end
