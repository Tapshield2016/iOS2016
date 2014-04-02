//
//  TSVirtualEntourageViewController.h
//  TapShield
//
//  Created by Ben Boyd on 2/14/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSNavigationViewController.h"
#import "TSHomeViewController.h"
#import <AddressBookUI/AddressBookUI.h>

@interface TSDestinationSearchViewController : TSNavigationViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, ABPeoplePickerNavigationControllerDelegate>


@property (nonatomic, strong) TSHomeViewController *homeViewController;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *dismissalView;

- (IBAction)dismissViewController:(id)sender;
- (IBAction)searchContacts:(id)sender;

@end
