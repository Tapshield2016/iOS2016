//
//  TSMedicalTableViewController.h
//  TapShield
//
//  Created by Adam Share on 4/22/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseTableViewController.h"
#import "TSBaseTextView.h"

@interface TSMedicalTableViewController : TSBaseTableViewController
@property (weak, nonatomic) IBOutlet TSBaseTextView *allergiesTextView;
@property (weak, nonatomic) IBOutlet TSBaseTextView *medicationsTextView;

@end
