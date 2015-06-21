//
//  CLLocation+Equal.h
//  TapShield
//
//  Created by Adam Share on 7/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface CLLocation (Params)

- (NSDictionary *)toLocationParameterDictionary;

@end
