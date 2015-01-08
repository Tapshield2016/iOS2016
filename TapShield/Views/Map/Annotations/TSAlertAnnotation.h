//
//  TSAlertAnnotation.h
//  TapShield
//
//  Created by Adam Share on 11/26/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSBaseMapAnnotation.h"
#import "TSJavelinAPIAlert.h"

@interface TSAlertAnnotation : TSBaseMapAnnotation

@property (strong, nonatomic) TSJavelinAPIAlert *alert;

@end
