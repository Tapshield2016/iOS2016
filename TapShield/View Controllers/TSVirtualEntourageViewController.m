//
//  TSVirtualEntourageViewController.m
//  TapShield
//
//  Created by Ben Boyd on 2/14/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSVirtualEntourageViewController.h"
#include <MapKit/MapKit.h>

@interface TSVirtualEntourageViewController ()

@property (nonatomic, strong) NSArray *searchResults;

@end

@implementation TSVirtualEntourageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchForLocation:(NSString *)searchString {
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchString;
    request.region = _mapView.region;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if ([response.mapItems count] > 0) {
            _searchResults = response.mapItems;
            [_tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"VirtualEntourageSearchResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    MKMapItem *mapItem = (MKMapItem *)_searchResults[indexPath.row];
    cell.textLabel.text = mapItem.name;
    cell.detailTextLabel.text = mapItem.placemark.addressDictionary[@"Street"];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _searchResults.count;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MKMapItem *mapItem = (MKMapItem *)_searchResults[indexPath.row];
    [_mapView userSelectedDestination:mapItem];
    [self dismiss:nil];
}

#pragma mark - UISearchBarDelegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text && [searchBar.text length] > 0) {
        [self searchForLocation:searchBar.text];
        [searchBar resignFirstResponder];
    }
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    picker.displayedProperties = @[@(kABPersonAddressProperty)];
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate methods

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {

    return YES;
}

- (NSString *)getTitleForABRecordRef:(ABRecordRef)record {
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonLastNameProperty);
    NSString *organization = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonOrganizationProperty);
    NSString *title = @"";

    if (firstName && !lastName) {
        title = firstName;
    }
    else if (!firstName && lastName) {
        title = lastName;
    }
    else if (firstName && lastName) {
        title = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
    else if (!firstName && !lastName) {
        if (organization) {
            title = organization;
        }
    }
    return title;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {

    ABMultiValueRef addressRef = ABRecordCopyValue(person, kABPersonAddressProperty);
    NSDictionary *addressDict = (__bridge NSDictionary *)ABMultiValueCopyValueAtIndex(addressRef, 0);
    NSString *placeName = [self getTitleForABRecordRef:person];

    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressDictionary:addressDict completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0) {
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:placemarks[0]];
            MKMapItem *contactMapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            contactMapItem.name = placeName;
            [_mapView userSelectedDestination:contactMapItem];
        }
        [self dismissViewControllerAnimated:NO completion:^{
            [self dismiss:nil];
        }];
    }];

    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
