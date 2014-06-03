//
//  TSAlertDetailsTableViewController.h
//  TapShield
//
//  Created by Adam Share on 4/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TSReportAnnotationManager.h"
#import "TSReportTypeTableViewCell.h"

@interface TSAlertDetailsTableViewController : TSNavigationViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) TSReportAnnotationManager *reportManager;

- (IBAction)dismissViewController:(id)sender;

@end
