//
//  MKRouteStepPolyline+EncodeDecode.m
//  TapShield
//
//  Created by Adam Share on 12/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "MKPolyline+EncodeDecode.h"

@interface MKPolyline ()


@end


@implementation MKPolyline (EncodeDecode)

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeInteger:self.pointCount forKey:@"pointCount"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.subtitle forKey:@"subtitle"];
    
    MKMapPoint *points = self.points;
    NSData *pointData = [NSData dataWithBytes:points length:self.pointCount * sizeof(MKMapPoint)];
    [coder encodeObject:pointData forKey:@"points"];
}

- (id)initWithCoder:(NSCoder *)coder {
    
    NSData *pointData = [coder decodeObjectForKey:@"points"];
    MKMapPoint *points = (MKMapPoint*)[pointData bytes];
    
    self = [MKPolyline polylineWithPoints:points count:[coder decodeIntegerForKey:@"pointCount"]];
    if (self) {
        
        self.title = [coder decodeObjectForKey:@"title"];
        self.subtitle = [coder decodeObjectForKey:@"subtitle"];
    }
    return self;
}

@end
