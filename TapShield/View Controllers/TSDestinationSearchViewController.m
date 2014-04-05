//
//  TSVirtualEntourageViewController.m
//  TapShield
//
//  Created by Ben Boyd on 2/14/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSDestinationSearchViewController.h"
#import <MapKit/MapKit.h>
#import "TSUtilities.h"
#import "TSRoutePickerViewController.h"

@interface TSDestinationSearchViewController ()

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) TSTransitionDelegate *transitionDelegate;
@property (nonatomic, strong) MKLocalSearch *search;

@end

@implementation TSDestinationSearchViewController

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
    
    [self customizeSearchBarAppearance:_searchBar];
    [self customizeTableView:_tableView];
    _searchBar.barTintColor = [UIColor clearColor];
    self.removeNavigationShadow = YES;
    
    CGRect frame = _tableView.frame;
    frame.origin.y = 2*self.view.bounds.size.height;
    _tableView.frame = frame;
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [_searchBar becomeFirstResponder];
    
    [self presentationAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self dismissalAnimation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Animations 

- (void)presentationAnimation {
    
    CGRect frame = _tableView.frame;
    frame.origin.y = _toolBarView.frame.origin.y + _toolBarView.frame.size.height;
    frame.size.height = self.view.bounds.size.height - frame.origin.y;
    
    [UIView animateWithDuration:0.3 delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
        _tableView.frame = frame;
    } completion:nil];
}

- (void)dismissalAnimation {
    
    CGRect frame = _tableView.frame;
    frame.origin.y = self.view.bounds.size.height*2;
    
    [UIView animateWithDuration:0.3 delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
        _tableView.frame = frame;
    } completion:nil];
}


#pragma mark - Button Actions

- (IBAction)dismissViewController:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        [_homeViewController viewWillAppear:NO];
        [_homeViewController viewDidAppear:NO];
        [_homeViewController clearEntourageAndResetMap];
    }];
}

- (IBAction)searchContacts:(id)sender {
    
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    picker.displayedProperties = @[@(kABPersonAddressProperty)];
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0f, keyboardBounds.size.height, 0.0);
    _tableView.contentInset = contentInsets;
    _tableView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    
    
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _tableView.contentInset = contentInsets;
    _tableView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
}




#pragma mark - MKLocalSearch methods

- (void)searchForLocation:(NSString *)searchString {
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchString;
    request.region = _homeViewController.mapView.region;
    if (_search.isSearching) {
        [_search cancel];
    }
    _search = [[MKLocalSearch alloc] initWithRequest:request];
    [_search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
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
    
    UIView *selectedView = [[UIView alloc] initWithFrame:cell.frame];
    selectedView.backgroundColor = [TSColorPalette whiteColor];
    cell.selectedBackgroundView = selectedView;
    cell.backgroundColor = [TSColorPalette clearColor];
    cell.textLabel.font = [TSRalewayFont fontWithName:kFontRalewayLight size:16.0f];
    cell.textLabel.textColor = [TSColorPalette listCellTextColor];
    cell.detailTextLabel.font = [TSRalewayFont fontWithName:kFontRalewayLight size:10.0f];
    cell.detailTextLabel.textColor = [TSColorPalette listCellDetailsTextColor];
    
//    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:cell.bounds];
//    toolbar.barTintColor = [TSColorPalette cellBackgroundColor];
//    [cell insertSubview:toolbar atIndex:0];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _searchResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return _tableView.bounds.size.height/10;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MKMapItem *mapItem = (MKMapItem *)_searchResults[indexPath.row];
    
    [_searchBar resignFirstResponder];
    
    _transitionDelegate = [[TSTransitionDelegate alloc] init];
    
    UIViewController *destinationViewController = [self pushViewControllerWithClass:[TSRoutePickerViewController class] transitionDelegate:_transitionDelegate navigationDelegate:_transitionDelegate animated:YES];
    ((TSRoutePickerViewController *)destinationViewController).homeViewController = _homeViewController;
    ((TSRoutePickerViewController *)destinationViewController).destinationMapItem = mapItem;
}

#pragma mark - UISearchBarDelegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text && [searchBar.text length] > 0) {
        [self searchForLocation:searchBar.text];
        [searchBar resignFirstResponder];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self performSelector:@selector(changeClearButtonStyle:) withObject:searchBar afterDelay:0.01];
    
    if (searchText && searchText > 0) {
        [self searchForLocation:searchText];
    }
}


#pragma mark - ABPeoplePickerNavigationControllerDelegate methods

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {

    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {

    ABMultiValueRef addressRef = ABRecordCopyValue(person, kABPersonAddressProperty);
    NSDictionary *addressDict = (__bridge NSDictionary *)ABMultiValueCopyValueAtIndex(addressRef, 0);
    CFRelease(addressRef);
    NSString *placeName = [TSUtilities getTitleForABRecordRef:person];

    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressDictionary:addressDict completionHandler:^(NSArray *placemarks, NSError *error) {
#warning Need to handle error here
        if ([placemarks count] > 0) {
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:placemarks[0]];
            MKMapItem *contactMapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            contactMapItem.name = placeName;
#warning destination
//            [_homeViewController.mapView userSelectedDestination:contactMapItem forTransportType:_directionsTransportType];
        }
        [self dismissViewControllerAnimated:NO completion:^{
            [self dismissViewController:nil];
        }];
    }];

    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
