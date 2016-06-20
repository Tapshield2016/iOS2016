//
//  TSJavelinAPIPushNotification.h
//  TapShield
//
//  Created by Adam Share on 9/24/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"

@interface TSJavelinAPIPushNotification : TSJavelinAPIBaseModel

@property (strong, nonatomic) NSString *alertType;
@property (strong, nonatomic) NSString *alertBody;
@property (assign, nonatomic) NSString *alertID;
@property (assign, nonatomic) NSString *alertUrl;

@end
