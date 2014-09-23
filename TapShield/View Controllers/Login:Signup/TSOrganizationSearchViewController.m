//
//  TSOrganizationSearchViewController.m
//  TapShield
//
//  Created by Adam Share on 2/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSOrganizationSearchViewController.h"
#import "TSUserSessionManager.h"

@interface TSOrganizationSearchViewController ()

@end

@implementation TSOrganizationSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _tableView.backgroundColor = [TSColorPalette listBackgroundColor];
    
    _statusString = @"Locating...";
    
    if (![(TSAppDelegate *)[UIApplication sharedApplication].delegate isConnected]) {
        _statusString = @"No network connection";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newPicture)
                                                 name:TSJavelinAPIAgencyDidFinishSmallLogoDownload
                                               object:nil];
    
    [self getOrganizationsToDisplay];
    
    // Create the search controller, but we'll make sure that this AAPLSearchShowResultsInSourceViewController
    // performs the results updating.
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    // Make sure the that the search bar is visible within the navigation bar.
    [self.searchController.searchBar sizeToFit];
    
    // Include the search controller's search bar within the table's header view.
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;
    
    self.navigationController.navigationBar.shadowImage = [UIImage imageFromColor:[UIColor whiteColor]];
    
    [self customizeTableView:_tableView];
    [self customizeSearchBarAppearance:self.searchController.searchBar];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)newPicture {
    [_tableView reloadData];
}

#pragma mark - Bar Button Action

- (IBAction)next:(id)sender {
    
    if (!_agency) {
        return;
    }
    
    [TSUserSessionManager showAddSecondaryWithAgency:_agency];
}

#pragma mark - Organization Methods

- (void)getOrganizationsToDisplay {
    [[TSJavelinAPIClient sharedClient] getAgencies:^(NSArray *agencies) {
        
        if (!agencies) {
            return;
        }
        
        self.allOrganizationsArray = agencies;
        
        [_tableView reloadData];
        [self getLocationAndSearchForNearbyAgencies];
    }];
}

- (void)getLocationAndSearchForNearbyAgencies {
    
    [[TSLocationController sharedLocationController] startStandardLocationUpdates:^(CLLocation *location) {
        [[TSJavelinAPIClient sharedClient] getAgenciesNearby:location radius:20.0f completion:^(NSArray *agencies) {
            if (agencies.count) {
                self.nearbyOrganizationArray = agencies;
            }
            else {
                self.statusString = @"None found";
            }
            [self.tableView reloadData];
        }];
    }];
}


#pragma mark - TableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"OrganizationCell";
    
    TSOrganizationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[TSOrganizationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell.logoImageView setHidden:NO];
    if (indexPath.section == 0) {
        if (_nearbyOrganizationArray.count == 0) {
            cell.organizationLabel.text = _statusString;
            [cell.logoImageView setHidden:YES];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setUserInteractionEnabled:NO];
        }
        else {
            if (self.visibleNearbyResults.count == 0) {
                cell.organizationLabel.text = @"No results";
                [cell.logoImageView setHidden:YES];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell setUserInteractionEnabled:NO];
            }
            else {
                cell.agency = (TSJavelinAPIAgency *)[self.visibleNearbyResults objectAtIndex:indexPath.row];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                [cell setUserInteractionEnabled:YES];
            }
        }
    }
    else {
        
        if (self.visibleAllResults.count == 0) {
            cell.organizationLabel.text = @"No results";
            [cell.logoImageView setHidden:YES];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setUserInteractionEnabled:NO];
        }
        else {
            cell.agency = (TSJavelinAPIAgency *)[self.visibleAllResults objectAtIndex:indexPath.row];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            [cell setUserInteractionEnabled:YES];
        }
    }
    
    
    UIView *selectedView = [[UIView alloc] initWithFrame:cell.frame];
    selectedView.backgroundColor = [TSColorPalette whiteColor];
    cell.selectedBackgroundView = selectedView;
    cell.backgroundColor = [TSColorPalette cellBackgroundColor];
    
    if ([_agency.name isEqualToString:cell.agency.name]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        if (!cell.selected) {
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (cell.selected) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        if (_nearbyOrganizationArray.count == 0 || self.visibleNearbyResults.count == 0) {
            return 1;
        }
        return self.visibleNearbyResults.count;
    }
    
    if (self.visibleAllResults.count == 0) {
        return 1;
    }
    
    return self.visibleAllResults.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
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
    
    if (section == 0) {
        label.text = @"Organizations Nearby";
    }

    return headerView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selected) {
        cell.selected = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
        _agency = nil;
        
        [tableView reloadData];
        return nil;
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    if (indexPath.section == 0) {
        _agency = (TSJavelinAPIAgency *)[self.visibleNearbyResults objectAtIndex:indexPath.row];
    }
    else {
        _agency = (TSJavelinAPIAgency *)[self.visibleAllResults objectAtIndex:indexPath.row];
    }
    
    [_tableView reloadData];
    
    _nextButton.enabled = YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _nextButton.enabled = NO;
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30.0f;
}


- (IBAction)dismissRegistration:(id)sender {
    
    [[TSUserSessionManager sharedManager] dismissWindow:nil];
}


#pragma mark - Search Controller 

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // -updateSearchResultsForSearchController: is called when the controller is being dismissed to allow those who are using the controller they are search as the results controller a chance to reset their state. No need to update anything if we're being dismissed.
    if (!searchController.active) {
        return;
    }
    
    self.filterString = searchController.searchBar.text;
}

- (void)setAllOrganizationsArray:(NSArray *)allOrganizationsArray {
    
    _allOrganizationsArray = allOrganizationsArray;
    self.visibleAllResults = _allOrganizationsArray;
    
    if (_filterString) {
        [self setFilterString:_filterString];
    }
}

- (void)setNearbyOrganizationArray:(NSArray *)nearbyOrganizationArray {
    
    _nearbyOrganizationArray = nearbyOrganizationArray;
    self.visibleNearbyResults = _nearbyOrganizationArray;
    
    if (_filterString) {
        [self setFilterString:_filterString];
    }
}

- (void)setFilterString:(NSString *)filterString {
    _filterString = filterString;
    
    if (!filterString || filterString.length <= 0) {
        self.visibleAllResults = _allOrganizationsArray;
        self.visibleNearbyResults = _nearbyOrganizationArray;
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@", filterString];
        self.visibleAllResults = [_allOrganizationsArray filteredArrayUsingPredicate:predicate];
        self.visibleNearbyResults = [_nearbyOrganizationArray filteredArrayUsingPredicate:predicate];
    }
    
    [_tableView reloadData];
}

@end
