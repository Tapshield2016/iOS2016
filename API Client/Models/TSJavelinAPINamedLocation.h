//
//  TSJavelinAPINamedLocation.h
//  TapShield
//
//  Created by Adam Share on 11/19/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"
#import <MapKit/MapKit.h>

@interface TSJavelinAPINamedLocation : TSJavelinAPIBaseModel

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDictionary *addressDictionary;
@property (strong, nonatomic) NSString *formattedAddress;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) MKMapItem *mapItem;

- (NSDictionary *)parametersFromLocation;

- (id)initWithMapItem:(MKMapItem *)item;

@end
