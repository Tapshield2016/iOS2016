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
#import "TSLocationController.h"

@interface TSOrganizationSearchViewController : TSBaseViewController <UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *emailAddress;
@property (nonatomic, strong) NSString *statusString;
@property (nonatomic, strong) NSMutableArray *filteredOrganizationMutableArray;
@property (nonatomic, strong) NSArray *allOrganizationsArray;
@property (nonatomic, strong) NSArray *nearbyOrganizationArray;

@property (strong, nonatomic) UISearchDisplayController *searchDisplay;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *skipCancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButton;


- (IBAction)dismissRegistration:(id)sender;

@end
