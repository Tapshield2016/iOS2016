//
//  TSJavelinAPIRegion.h
//  TapShield
//
//  Created by Adam Share on 6/16/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"
#import "TSJavelinAPIDispatchCenter.h"

@interface TSJavelinAPIRegion : TSJavelinAPIBaseModel

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

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *boundaries;
@property (assign, nonatomic) NSUInteger primaryDispatchCenter;
@property (assign, nonatomic) NSUInteger secondaryDispatchCenter;
@property (assign, nonatomic) NSUInteger fallbackDispatchCenter;
@property (readonly) CLLocationCoordinate2D centerPoint;

- (TSJavelinAPIDispatchCenter *)openCenterToReceive:(NSArray *)openCenters;

@end
