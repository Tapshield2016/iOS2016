//
//  TSOrganizationSearchViewController.h
//  TapShield
//
//  Created by Adam Share on 2/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TSOrganizationCell.h"
#import "TSRegisterViewController.h"
#import "TSLocationController.h"

@interface TSOrganizationSearchViewController : TSNavigationViewController <UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSString *emailAddress;
@property (strong, nonatomic) NSString *statusString;
@property (strong, nonatomic) NSMutableArray *filteredOrganizationMutableArray;
@property (strong, nonatomic) NSArray *allOrganizationsArray;
@property (strong, nonatomic) NSArray *nearbyOrganizationArray;
@property (strong, nonatomic) UISearchDisplayController *searchDisplay;
@property (strong, nonatomic) TSJavelinAPIUser *user;
@property (strong, nonatomic) TSJavelinAPIAgency *previousAgencySelected;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *skipCancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButton;


- (IBAction)dismissRegistration:(id)sender;

@end
