//
//  TSMedicalTableViewController.h
//  TapShield
//
//  Created by Adam Share on 4/22/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseTableViewController.h"

@interface TSMedicalTableViewController : TSBaseTableViewController
@property (weak, nonatomic) IBOutlet UITextView *allergiesTextView;
@property (weak, nonatomic) IBOutlet UITextView *medicationsTextView;

@end
