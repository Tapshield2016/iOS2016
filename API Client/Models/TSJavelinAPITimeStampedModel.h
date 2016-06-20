//
//  TSJavelinAPITimesStampedModel.h
//  TapShield
//
//  Created by Adam Share on 11/24/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"

@interface TSJavelinAPITimeStampedModel : TSJavelinAPIBaseModel

@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic) NSDate *lastModified;

@end
