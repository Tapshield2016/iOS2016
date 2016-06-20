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

@interface TSOrganizationSearchViewController : TSNavigationViewController <UISearchBarDelegate, UISearchControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating>

@property (strong, nonatomic) NSString *emailAddress;
@property (strong, nonatomic) NSString *statusString;
@property (strong, nonatomic) NSArray *allOrganizationsArray;
@property (strong, nonatomic) NSArray *nearbyOrganizationArray;
@property (strong, nonatomic) UISearchController *searchController;

@property (strong, nonatomic) TSJavelinAPIAgency *agency;
@property (strong, nonatomic) TSJavelinAPIAgency *previousAgencySelected;

@property (strong, nonatomic) NSString *filterString;
@property (strong, nonatomic) NSArray *visibleAllResults;
@property (strong, nonatomic) NSArray *visibleNearbyResults;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButton;


- (IBAction)dismissRegistration:(id)sender;

@end
