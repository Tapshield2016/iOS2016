//
//  TSEmergencyContactTableViewController.h
//  TapShield
//
//  Created by Adam Share on 4/22/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseTableViewController.h"

@interface TSEmergencyContactTableViewController : TSBaseTableViewController
@property (weak, nonatomic) IBOutlet TSBaseTextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet TSBaseTextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet TSBaseTextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet TSBaseTextField *relationshipTextField;

@end
