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
@property (nonatomic, strong) TSTransitionDelegate *transitionDelegate;
@property (nonatomic, strong) MKLocalSearch *search;

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
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
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
    
    NSArray *savedArray = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:TSDestinationSearchPastResults]];
    _previousMapItemSelections = [[NSMutableArray alloc] initWithArray:savedArray];
    
    if (_searchResults.count == 0) {
        _searchResults = _previousMapItemSelections;
    }
}

- (void)archivePreviousMapItems {
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_previousMapItemSelections] forKey:TSDestinationSearchPastResults];
}

- (void)showPreviousSelections {
    _searchResults = _previousMapItemSelections;
    [_tableView reloadData];
}

- (void)addMapItemToSavedSelections:(MKMapItem *)mapItem {
    
    if (!_previousMapItemSelections) {
        _previousMapItemSelections = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    [_previousMapItemSelections removeObject:mapItem];
    [_previousMapItemSelections insertObject:mapItem atIndex:0];
    
    if (_previousMapItemSelections.count > 20) {
        [_previousMapItemSelections removeObjectsInRange:NSMakeRange(20, _previousMapItemSelections.count-20)];
    }
    
    [self archivePreviousMapItems];
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
    
    [UIView animateWithDuration:0.6 delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
        _tableView.frame = frame;
    } completion:nil];
}


#pragma mark - Button Actions

- (IBAction)dismissViewController:(id)sender {
    
    [self dismissalAnimation];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [_homeViewController viewWillAppear:NO];
        [_homeViewController viewDidAppear:NO];
        [_homeViewController clearEntourageAndResetMap];
    }];
}

- (IBAction)searchContacts:(id)sender {
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    if (error) {
        NSLog(@"error");
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return;
    }
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        
        if (error) {
            NSLog(@"error");
            self.navigationItem.rightBarButtonItem.enabled = YES;
            return;
        }
        
        if (!granted) {
            NSLog(@"Denied access");
            self.navigationItem.rightBarButtonItem.enabled = YES;
            return;
        }
        
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
        CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
        
        for( CFIndex index = 0; index < nPeople; index++ ) {
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, index );
            ABMutableMultiValueRef addressRef = ABRecordCopyValue(person, kABPersonAddressProperty);
            int addressCount = ABMultiValueGetCount(addressRef);
            
            if (!addressCount) {
                CFErrorRef error = nil;
                ABAddressBookRemoveRecord(addressBook, person, &error);
                if (error) {
                    NSLog(@"Error: %@", error);
                }
            }
            else {
                ABMultiValueRef addressMultiValue = ABRecordCopyValue(person, kABPersonAddressProperty);
                NSDictionary *address = (__bridge_transfer NSDictionary *)ABMultiValueCopyValueAtIndex(addressMultiValue, 0);
                CFRelease(addressMultiValue);
                
                if (![address objectForKey:@"Street"]) {
                    CFErrorRef error = nil;
                    ABAddressBookRemoveRecord(addressBook, person, &error);
                    if (error) {
                        NSLog(@"Error: %@", error);
                    }
                }
            }
            
            CFRelease(addressRef);
        }
        
        nPeople = ABAddressBookGetPersonCount( addressBook );
        
        CFRelease(allPeople);
        
        if (nPeople == 0) {
            NSLog(@"No contacts with street addresses");
            CFRelease(addressBook);
            return;
        }
        
        ABAddressBookSave(addressBook, &error);
        if (error) {
            NSLog(@"Error: %@", error);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
            picker.addressBook = addressBook;
            picker.topViewController.navigationItem.title = @"Contacts";
            picker.peoplePickerDelegate = self;
            picker.displayedProperties = @[@(kABPersonAddressProperty)];
            [self presentViewController:picker animated:YES completion:nil];
            
            CFRelease(addressBook);
            
            self.navigationItem.rightBarButtonItem.enabled = YES;
        });
    });
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
    
    _transitionDelegate = [[TSTransitionDelegate alloc] init];
    
    UIViewController *destinationViewController = [self pushViewControllerWithClass:[TSRoutePickerViewController class] transitionDelegate:_transitionDelegate navigationDelegate:_transitionDelegate animated:YES];
    ((TSRoutePickerViewController *)destinationViewController).homeViewController = _homeViewController;
    ((TSRoutePickerViewController *)destinationViewController).destinationMapItem = mapItem;
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


#pragma mark - ABPeoplePickerNavigationControllerDelegate methods

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {

    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {

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
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    
    

    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
