//
//  TSVirtualEntourageViewController.h
//  TapShield
//
//  Created by Ben Boyd on 2/14/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMapView.h"

@interface TSVirtualEntourageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) TSMapView *mapView;

- (IBAction)dismiss:(id)sender;

@end
