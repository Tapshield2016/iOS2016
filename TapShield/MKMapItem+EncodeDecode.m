//
//  MKMapItem+EncodeDecode.m
//  TapShield
//
//  Created by Adam Share on 4/6/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "MKMapItem+EncodeDecode.h"

@implementation MKMapItem (EncodeDecode)

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:self.placemark forKey:@"placemark"];
    [coder encodeBool:self.isCurrentLocation forKey:@"isCurrentLocation"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
    [coder encodeObject:self.url forKey:@"url"];
}

- (id)initWithCoder:(NSCoder *)coder {
    
    MKPlacemark *placemark = [coder decodeObjectForKey:@"placemark"];
    self = [self initWithPlacemark:placemark];
    if (self) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.phoneNumber = [coder decodeObjectForKey:@"phoneNumber"];
        self.url = [coder decodeObjectForKey:@"url"];
    }
    return self;
}
@end
