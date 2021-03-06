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
#import "TSMapItemCell.h"

#define CELL_HEIGHT 50

static NSString * const TSDestinationSearchPastResults = @"TSDestinationSearchPastResults";

@interface TSDestinationSearchViewController ()

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) TSPushTransitionDelegate *transitionDelegate;
@property (nonatomic, strong) MKLocalSearch *search;
@property (nonatomic, strong) TSPopUpWindow *tutorialWindow;

@end

@implementation TSDestinationSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self unarchivePreviousMapItems];
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
    
    _tableView.backgroundColor = [TSColorPalette listBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (!self.firstAppear) {
        self.tableViewTopLayout.constant = self.view.frame.size.height*2;
        self.tableViewBottomLayout.constant = -self.view.frame.size.height*2;
        self.firstAppear = YES;
    }
    
    [_tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [_searchBar becomeFirstResponder];
    
    [self presentationAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Saved MapItems

- (void)unarchivePreviousMapItems {
    
    _previousMapItemSelections = [TSEntourageSessionManager sharedManager].previousMapItems;
    
    if (_searchResults.count == 0) {
        _searchResults = _previousMapItemSelections;
    }
}

- (void)archivePreviousMapItems {
    
    [[TSEntourageSessionManager sharedManager] archivePreviousMapItems:_previousMapItemSelections];
}

- (void)showPreviousSelections {
    _searchResults = _previousMapItemSelections;
    [_tableView reloadData];
}

- (void)addMapItemToSavedSelections:(MKMapItem *)mapItem {
    
    _previousMapItemSelections = [[TSEntourageSessionManager sharedManager] addMapItemToSavedSelections:mapItem];
}



#pragma mark - View Animations 

- (void)presentationAnimation {
    
    [UIView animateWithDuration:0.3 delay:0.0f usingSpringWithDamping:300.0 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.tableViewTopLayout.constant = 0;
        self.tableViewBottomLayout.constant = 0;
        [self.view layoutIfNeeded];
    } completion:nil];

}

- (void)dismissalAnimation {
    
    [_searchBar resignFirstResponder];
    
    [UIView animateWithDuration:0.1 delay:0.0f usingSpringWithDamping:300.0 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _tableView.alpha = 0.0;
    } completion:nil];
}


#pragma mark - Button Actions

- (IBAction)dismissViewController:(id)sender {
    
    [self dismissalAnimation];
    
    UINavigationController *nav = (UINavigationController *)self.presentingViewController;
    [[nav.viewControllers firstObject] beginAppearanceTransition:YES animated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        [[nav.viewControllers firstObject] endAppearanceTransition];
    }];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    
    ABMultiValueRef addressRef = ABRecordCopyValue(person, kABPersonAddressProperty);
    NSDictionary *addressDict = (__bridge_transfer NSDictionary *)ABMultiValueCopyValueAtIndex(addressRef, 0);
    CFRelease(addressRef);
    NSString *placeName = [TSUtilities getTitleForABRecordRef:person];
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressDictionary:addressDict completionHandler:^(NSArray *placemarks, NSError *error) {
#warning Need to handle error here
        if ([placemarks count] > 0) {
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:placemarks[0]];
            MKMapItem *contactMapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            contactMapItem.name = placeName;
            [self pushRoutePickerWithMapItem:contactMapItem];
        }
//        [peoplePicker dismissViewControllerAnimated:NO completion:nil];
    }];
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
    
    _searchResults = nil;
    [_tableView reloadData];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    _search = [[MKLocalSearch alloc] initWithRequest:request];
    [_search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (error) {
            _searchResults = @[error];
            [_tableView reloadData];
        }
        else if ([response.mapItems count] > 0) {
            _searchResults = response.mapItems;
            [_tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"VirtualEntourageSearchResultCell";
    TSMapItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[TSMapItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if ([_searchResults[indexPath.row] isKindOfClass:[NSError class]]) {
        
        [cell showDetailsForErrorMessage:(NSError *)_searchResults[indexPath.row]];
        
        return cell;
    }

    MKMapItem *mapItem = (MKMapItem *)_searchResults[indexPath.row];
    [cell showDetailsForMapItem:mapItem];
    [cell boldSearchString:(NSString *)_searchBar.text];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _searchResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return CELL_HEIGHT;
}

- (void)pushRoutePickerWithMapItem:(MKMapItem *)mapItem {
    
    [self addMapItemToSavedSelections:mapItem];
    
    [_searchBar resignFirstResponder];
    
    TSRoutePickerViewController *vc = [[(UINavigationController *)self.presentingViewController viewControllers] firstObject];
    [vc searchSelectedMapItem:mapItem];
    [self performSelector:@selector(dismissViewController:) withObject:nil];
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_searchResults[indexPath.row] isKindOfClass:[NSError class]]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    MKMapItem *mapItem = (MKMapItem *)_searchResults[indexPath.row];
    [self pushRoutePickerWithMapItem:mapItem];
}

#pragma mark - UISearchBarDelegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text && [searchBar.text length] > 0) {
        [self searchForLocation:searchBar.text];
        [searchBar resignFirstResponder];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (searchText && searchText.length > 0) {
        [self performSelector:@selector(searchForLocation:) withObject:searchText afterDelay:0.5];

    }
    else {
        [_search cancel];
        [self showPreviousSelections];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}


@end
