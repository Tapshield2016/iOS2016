//
//  TSOrganizationSearchViewController.h
//  TapShield
//
//  Created by Adam Share on 2/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"
#import "TSOrganizationCell.h"
#import "TSRegisterViewController.h"

@interface TSOrganizationSearchViewController : TSBaseViewController <UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (nonatomic, strong) NSString *emailAddress;
@property (nonatomic, strong) NSString *statusString;
@property (nonatomic, strong) NSMutableArray *filteredOrganizationMutableArray;
@property (nonatomic, strong) NSArray *allOrganizationsArray;
@property (nonatomic, strong) NSArray *nearbyOrganizationArray;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *skipCancelButton;

@end
