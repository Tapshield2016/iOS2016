//
//  TSBasicInfoTableViewController.h
//  TapShield
//
//  Created by Adam Share on 4/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseTableViewController.h"

@interface TSBasicInfoTableViewController : TSBaseTableViewController

@property (weak, nonatomic) IBOutlet TSBaseTextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet TSBaseTextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet TSBaseTextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet TSBaseTextField *genderTextField;


@end
