//
//  TSJavelinAPIRegion.m
//  TapShield
//
//  Created by Adam Share on 6/16/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIRegion.h"

static NSString *const kModelAgency = @"agency";
static NSString *const kModelName = @"name";
static NSString *const kModelPrimaryDispatchCenter = @"primary_dispatch_center";
static NSString *const kModelSecondaryDispatchCenter = @"secondary_dispatch_center";
static NSString *const kModelFallbackDispatchCenter = @"fallback_dispatch_center";
static NSString *const kModelBoundaries = @"boundaries";
static NSString *const kModelCenterPoint = @"center_point";
static NSString *const kModelCenterLatitude = @"center_latitude";
static NSString *const kModelCenterLongitude = @"center_longitude";

@implementation TSJavelinAPIRegion

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super initWithAttributes:attributes];
    if (!self) {
        return nil;
    }
    //"url": "https://dev.tapshield.com/api/v1/region/3/",
    //"agency": "https://dev.tapshield.com/api/v1/agencies/7/",
    //"name": "Glenns Campus",
    //"primary_dispatch_center": "https://dev.tapshield.com/api/v1/dispatch-center/4/",
    //"secondary_dispatch_center": "https://dev.tapshield.com/api/v1/dispatch-center/3/",
    //"fallback_dispatch_center": null,
    //"boundaries": "[\"37.5697868379799,-76.63307189941406\","37.5697868379799,-76.63307189941406\"]",
    //"center_latitude": 37.5639019784,
    //"center_longitude": -76.6318273544,
    //"center_point": "POINT (-76.6318273544000022 37.5639019783999970)"
    
    _name = [attributes nonNullObjectForKey:kModelName];
    _primaryDispatchCenter = [self filterIdentifier:[attributes nonNullObjectForKey:kModelPrimaryDispatchCenter]];
    _secondaryDispatchCenter = [self filterIdentifier:[attributes nonNullObjectForKey:kModelSecondaryDispatchCenter]];
    _fallbackDispatchCenter = [self filterIdentifier:[attributes nonNullObjectForKey:kModelFallbackDispatchCenter]];
    
    [self setRegionBoundariesFromAttributes:[attributes nonNullObjectForKey:kModelBoundaries]];
    
    double lat = [[attributes nonNullObjectForKey:kModelCenterLatitude] doubleValue];
    double lon = [[attributes nonNullObjectForKey:kModelCenterLongitude] doubleValue];
    _centerPoint = CLLocationCoordinate2DMake(lat, lon);
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _name = [coder decodeObjectForKey:kModelName];
        _primaryDispatchCenter = [[coder decodeObjectForKey:kModelPrimaryDispatchCenter] integerValue];
        _secondaryDispatchCenter = [[coder decodeObjectForKey:kModelSecondaryDispatchCenter] integerValue];
        _fallbackDispatchCenter = [[coder decodeObjectForKey:kModelFallbackDispatchCenter] integerValue];
        _boundaries = [coder decodeObjectForKey:kModelBoundaries];
        _centerPoint = CLLocationCoordinate2DMake([[coder decodeObjectForKey:kModelCenterLatitude] doubleValue], [[coder decodeObjectForKey:kModelCenterLongitude] doubleValue]);
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:_name forKey:kModelName];
    [encoder encodeObject:@(_primaryDispatchCenter) forKey:kModelPrimaryDispatchCenter];
    [encoder encodeObject:@(_secondaryDispatchCenter) forKey:kModelSecondaryDispatchCenter];
    [encoder encodeObject:@(_fallbackDispatchCenter) forKey:kModelFallbackDispatchCenter];
    [encoder encodeObject:_boundaries forKey:kModelBoundaries];
    [encoder encodeObject:[NSNumber numberWithDouble:_centerPoint.latitude] forKey:kModelCenterLatitude];
    [encoder encodeObject:[NSNumber numberWithDouble:_centerPoint.longitude] forKey:kModelCenterLongitude];
}


- (void)setRegionBoundariesFromAttributes:(NSString *)boundariesString {
    
    if ([boundariesString isKindOfClass:[NSNull class]]) {
        return;
    }
    
    if ([boundariesString rangeOfString:@","].location == NSNotFound) {
        return;
    }
    
    NSString *noWhiteSpace = [boundariesString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *noBreaks = [noWhiteSpace stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    noBreaks = [noBreaks stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSString *string = [noBreaks stringByReplacingOccurrencesOfString:@"[\"" withString:@""];
    NSArray *splitAgencyBoundaryString = [string componentsSeparatedByString:@"\",\""];
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (int i=0; i<splitAgencyBoundaryString.count; i++) {
        NSArray *coordinatesArray = [[splitAgencyBoundaryString objectAtIndex:i] componentsSeparatedByString:@","];
        if (coordinatesArray.count > 1) {
            double lat = [[coordinatesArray objectAtIndex:0] doubleValue];
            double lon = [[coordinatesArray objectAtIndex:1] doubleValue];
            CLLocation *location =  [[CLLocation alloc] initWithLatitude:lat longitude:lon];
            [mutableArray addObject:location];
        }
    }
    _boundaries = mutableArray;
}

- (TSJavelinAPIDispatchCenter *)openCenterToReceive:(NSArray *)openCenters {
    
    if (!openCenters || !openCenters.count) {
        return nil;
    }
    
    TSJavelinAPIDispatchCenter *center;
    if (_primaryDispatchCenter) {
        center = [self openCenter:openCenters matchID:_primaryDispatchCenter];
        
        if (center) {
            return center;
        }
    }
    
    if (_secondaryDispatchCenter) {
        center =  [self openCenter:openCenters matchID:_secondaryDispatchCenter];
        
        if (center) {
            return center;
        }
    }
    
    if (_fallbackDispatchCenter) {
        center =  [self openCenter:openCenters matchID:_fallbackDispatchCenter];
        
        if (center) {
            return center;
        }
    }
    
    return nil;
}

- (TSJavelinAPIDispatchCenter *)openCenter:(NSArray *)openCenters matchID:(NSUInteger)identifier {
    
    for (TSJavelinAPIDispatchCenter *center in openCenters) {
        if (identifier == center.identifier) {
            return center;
        }
    }
    
    return nil;
}

@end
