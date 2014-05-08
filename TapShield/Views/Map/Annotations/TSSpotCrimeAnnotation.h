//
//  TSSpotCrimeAnnotation.h
//  TapShield
//
//  Created by Adam Share on 5/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseMapAnnotation.h"
#import "TSSpotCrimeAPIClient.h"

@interface TSSpotCrimeAnnotation : TSBaseMapAnnotation

@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) TSSpotCrimeLocation *spotCrime;

- (instancetype)initWithSpotCrime:(TSSpotCrimeLocation *)location;

@end
