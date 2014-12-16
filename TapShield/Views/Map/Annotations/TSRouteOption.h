//
//  TSRouteOption.h
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSRouteTimeAnnotation.h"

@interface TSRouteOption : NSObject

@property (nonatomic, strong) MKRoute *route;
@property (nonatomic, strong) TSRouteTimeAnnotation *routeTimeAnnotation;

@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) NSTimeInterval expectedTravelTime;
@property (assign, nonatomic) CLLocationDistance distance;
@property (strong, nonatomic) MKPolyline *polyline;
@property (assign, nonatomic) MKDirectionsTransportType transportType;

- (id)initWithRoute:(MKRoute *)route;

- (void)findUniqueMapPointComparingRoutes:(NSArray *)routeArray completion:(void (^)(MKMapPoint uniquePointFromSet))completion;

@end
