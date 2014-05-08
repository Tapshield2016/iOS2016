//
//  TSMassNotificationsViewController.m
//  TapShield
//
//  Created by Ben Boyd on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSMassNotificationsViewController.h"
#import "TSJavelinPushNotificationManager.h"
#import "TSJavelinAPIMassAlert.h"

#define FONT_SIZE 17
#define DETAILS_FONT_SIZE 12
#define CELL_INSET 25

static NSString * const TSMassNotificationsViewControllerSavedNotifications = @"TSTSMassNotificationsViewControllerSavedNotifications";

@interface TSMassNotificationsViewController ()

@property (strong, nonatomic) NSMutableArray *notifications;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation TSMassNotificationsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    _notifications = [[NSMutableArray alloc] initWithArray:[self unarchiveNotifications]];
    [_tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageReceived:)
                                                 name:TSJavelinPushNotificationManagerDidReceiveNotificationOfNewMassAlertNotification
                                               object:nil];
    [self loadMassAlerts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)messageReceived:(NSNotification *)notif
{
    [self loadMassAlerts];
}

- (void)archiveNotifications {
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_notifications];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:TSMassNotificationsViewControllerSavedNotifications];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)unarchiveNotifications {
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:TSMassNotificationsViewControllerSavedNotifications];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_notifications.count == 0) {
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_notifications.count == 0) {
        return 1;
    }
    return _notifications.count - 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [TSRalewayFont fontWithName:kFontRalewayRegular size:FONT_SIZE];
        cell.textLabel.textColor = [TSColorPalette listCellTextColor];
        
        cell.detailTextLabel.font = [TSRalewayFont fontWithName:kFontRalewayRegular size:DETAILS_FONT_SIZE];
        cell.detailTextLabel.textColor = [TSColorPalette listCellDetailsTextColor];
        cell.backgroundColor = [TSColorPalette cellBackgroundColor];
    }
    
    cell.textLabel.text = ((TSJavelinAPIMassAlert *)_notifications[indexPath.row]).message;
    cell.detailTextLabel.text = [TSUtilities formattedViewableDate:((TSJavelinAPIMassAlert *)_notifications[indexPath.row]).timeStamp];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *bodyTxt = ((TSJavelinAPIMassAlert *)_notifications[indexPath.row]).message;
    
    CGSize size = [TSUtilities text:bodyTxt sizeWithFont:[TSRalewayFont fontWithName:kFontRalewayRegular size:FONT_SIZE]  constrainedToSize:CGSizeMake(self.view.frame.size.width - [self tableView:_tableView cellForRowAtIndexPath:indexPath].textLabel.frame.origin.x, INFINITY)];
    
    NSString *stmpTxt = @"14 Jul 12:39:45 PM";
    CGSize stmpSize = [TSUtilities text:stmpTxt sizeWithFont:[TSRalewayFont fontWithName:kFontRalewayRegular size:DETAILS_FONT_SIZE]  constrainedToSize:CGSizeMake(self.view.frame.size.width - [self tableView:_tableView cellForRowAtIndexPath:indexPath].textLabel.frame.origin.x, INFINITY)];
    
    return size.height + stmpSize.height + CELL_INSET;
}

- (IBAction)backBtnTUI:(id)sender
{
    [self.navigationController  popViewControllerAnimated:YES];
}

- (void)loadMassAlerts {
    // start loader
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicator.center = self.view.center;
        [self.view addSubview:_activityIndicator];
        
    }
    
    [_activityIndicator startAnimating];
    [_activityIndicator setHidden:NO];
    [self.view bringSubviewToFront:_activityIndicator];
    
    
    [[TSJavelinAPIClient sharedClient] getMassAlerts:^(NSArray *massAlerts) {
        if (massAlerts) {
            _notifications = [[NSMutableArray alloc] initWithArray:massAlerts];
            
            [_tableView reloadData];
            [self archiveNotifications];
        }
        [_activityIndicator stopAnimating];
        [_activityIndicator setHidden:YES];
    }];
}


@end
