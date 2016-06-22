//
//  TSContactDataTableViewController.h
//  TapShield
//
//  Created by Adam Share on 4/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseTableViewController.h"

@interface TSContactDataTableViewController : TSBaseTableViewController

@property (weak, nonatomic) IBOutlet TSBaseTextField *streetTextField;
@property (weak, nonatomic) IBOutlet TSBaseTextField *cityTextField;
@property (weak, nonatomic) IBOutlet TSBaseTextField *stateTextField;
@property (weak, nonatomic) IBOutlet TSBaseTextField *zipTextField;

- (NSDictionary *)fullAddressDictionary;

@end
