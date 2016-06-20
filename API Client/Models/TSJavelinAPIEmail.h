//
//  TSJavelinAPIEmail.h
//  TapShield
//
//  Created by Adam Share on 6/27/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"

@interface TSJavelinAPIEmail : TSJavelinAPIBaseModel

@property (strong, nonatomic) NSString *email;
@property (assign, nonatomic) BOOL isPrimary;
@property (assign, nonatomic) BOOL isActive;
@property (assign, nonatomic) BOOL isActivationSent;

@end
