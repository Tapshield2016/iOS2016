//
//  TSAppearanceTableViewController.h
//  TapShield
//
//  Created by Adam Share on 4/22/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseTableViewController.h"

@interface TSAppearanceTableViewController : TSBaseTableViewController

@property (nonatomic, assign) ProfileHairColor hairColor;
@property (nonatomic, assign) ProfileRace race;

@property (weak, nonatomic) IBOutlet TSBaseTextField *heightTextField;
@property (weak, nonatomic) IBOutlet TSBaseTextField *weightTextField;
@property (weak, nonatomic) IBOutlet TSBaseTextField *hairColorTextField;
@property (weak, nonatomic) IBOutlet TSBaseTextField *ethnicityTextField;

@end
