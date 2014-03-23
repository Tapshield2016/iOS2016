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


- (IBAction)skipOrCancel:(id)sender {
    
    [self segueSendingAgency:nil];
}

- (void)segueSendingAgency:(TSJavelinAPIAgency *)agency {
    
    if ([self.presentingViewController.restorationIdentifier isEqualToString:@"TSLoginOrSignUpNavigationController"]) {
        if (agency) {
            TSRegisterViewController *registerViewController = [((UINavigationController *)self.presentingViewController).viewControllers lastObject];
            registerViewController.agency = agency;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    TSRegisterViewController *registerViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TSRegisterViewController"];
    if (agency) {
        registerViewController.agency = agency;
    }
    registerViewController.emailAddress = _emailAddress;
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
                _nearbyOrganizationArray = agencies;
            }
            else {
                _statusString = @"None Found";
            }
            [_tableView reloadData];
        }];
    }];
}


#pragma mark Content Filtering

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
    _filteredOrganizationMutableArray = [NSMutableArray arrayWithArray:[_allOrganizationsArray filteredArrayUsingPredicate:predicate]];
}

#pragma mark - UISearchDisplayController Delegate Methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

#pragma mark - TableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"OrganizationCell";
    
    TSOrganizationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[TSOrganizationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *name;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        name = ((TSJavelinAPIAgency *)[_filteredOrganizationMutableArray objectAtIndex:indexPath.row]).name;
        cell.agency = (TSJavelinAPIAgency *)[_filteredOrganizationMutableArray objectAtIndex:indexPath.row];
    } else {
        if (indexPath.section == 0) {
            if (_nearbyOrganizationArray.count == 0) {
                name = _statusString;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell setUserInteractionEnabled:NO];
            }
            else {
                name = ((TSJavelinAPIAgency *)[_nearbyOrganizationArray objectAtIndex:indexPath.row]).name;
                cell.agency = (TSJavelinAPIAgency *)[_nearbyOrganizationArray objectAtIndex:indexPath.row];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                [cell setUserInteractionEnabled:YES];
            }
        }
        else {
            name = ((TSJavelinAPIAgency *)[_allOrganizationsArray objectAtIndex:indexPath.row]).name;
            cell.agency = (TSJavelinAPIAgency *)[_allOrganizationsArray objectAtIndex:indexPath.row];
        }
    }
    
    cell.textLabel.text = name;
    
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self segueSendingAgency:(TSJavelinAPIAgency *)[_filteredOrganizationMutableArray objectAtIndex:indexPath.row]];
    }
    else {
        if (indexPath.section == 0) {
            [self segueSendingAgency:(TSJavelinAPIAgency *)[_nearbyOrganizationArray objectAtIndex:indexPath.row]];
        }
        else {
            [self segueSendingAgency:(TSJavelinAPIAgency *)[_allOrganizationsArray objectAtIndex:indexPath.row]];
        }
    }
    
}


- (IBAction)dismissRegistration:(id)sender {
    
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }];
}
@end
