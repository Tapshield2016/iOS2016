//
//  TSAlertDetailsTableViewController.h
//  TapShield
//
//  Created by Adam Share on 4/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"

@interface TSAlertDetailsTableViewController : TSNavigationViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) MKMapView *mapView;

- (IBAction)dismissViewController:(id)sender;

@end
