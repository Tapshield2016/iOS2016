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
#import "TSJavelinMassNotificationManager.h"

#define FONT_SIZE 17
#define DETAILS_FONT_SIZE 12
#define CELL_INSET 25

@interface TSMassNotificationsViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) TSJavelinMassNotificationManager *massNotificationManager;

@end

@implementation TSMassNotificationsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _tableView.backgroundColor = [TSColorPalette listBackgroundColor];
    
    _massNotificationManager = [[TSJavelinMassNotificationManager alloc] init];
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

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_massNotificationManager.notifications.count == 0) {
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_massNotificationManager.notifications.count == 0) {
        return 1;
    }
    return _massNotificationManager.notifications.count - 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = NSStringFromClass([TSMassNotificationTableViewCell class]);
    
    TSMassNotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    cell.textView.text = nil;
    cell.textView.editable = YES;
    cell.textView.editable = NO;
    
    cell.backgroundColor = [TSColorPalette cellBackgroundColor];
    
    cell.textView.font = [TSRalewayFont customFontFromStandardFont:cell.textView.font];
    cell.textView.textColor = [TSColorPalette listCellTextColor];
    cell.textView.delegate = self;
    cell.textView.text = ((TSJavelinAPIMassAlert *)_massNotificationManager.notifications[indexPath.row]).message;
    
    cell.timestampLabel.textColor = [TSColorPalette listCellDetailsTextColor];
    cell.timestampLabel.text = [TSUtilities formattedViewableDate:((TSJavelinAPIMassAlert *)_massNotificationManager.notifications[indexPath.row]).timeStamp];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *bodyTxt = ((TSJavelinAPIMassAlert *)_massNotificationManager.notifications[indexPath.row]).message;
    
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
    
    
    [_massNotificationManager getNewMassAlerts:^(NSArray *massAlerts) {
        [_tableView reloadData];
        [_activityIndicator stopAnimating];
        [_activityIndicator setHidden:YES];
    }];
}

#pragma mark - Text View Delegate 

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    
    
    
    return YES;
}


@end
