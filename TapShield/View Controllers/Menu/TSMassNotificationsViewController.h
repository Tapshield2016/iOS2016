//
//  TSMassNotificationsViewController.h
//  TapShield
//
//  Created by Ben Boyd on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSNavigationViewController.h"

@interface TSMassNotificationsViewController : TSNavigationViewController <UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
