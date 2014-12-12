//
//  MKRouteStepPolyline+EncodeDecode.h
//  TapShield
//
//  Created by Adam Share on 12/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKPolyline (EncodeDecode)

- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

@end
