//
//  TSRouteOption.m
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRouteOption.h"

@implementation TSRouteOption

- (id)initWithRoute:(MKRoute *)route {
    
    self = [super init];
    
    if (self) {
        self.route = route;
    }
    
    return self;
}


- (MKMapPoint)findUniqueMapPointComparingRoutes:(NSArray *)routeArray {
    
    if (!_route) {
        return MKMapPointMake(0, 0);
    }
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:routeArray];
    [mutableArray removeObjectsInArray:@[_route]];
    routeArray = mutableArray;
    
    if (routeArray.count == 0 || !routeArray) {
        return _route.polyline.points[_route.polyline.pointCount*2/3];
    }
    
    MKMapPoint uniquePoint = _route.polyline.points[_route.polyline.pointCount/2];
    NSArray *result;
    
    NSMutableSet *initialSet = [[NSMutableSet alloc] initWithCapacity:_route.polyline.pointCount];
    for (int n = 0; n < _route.polyline.pointCount; n++) {
        
        MKMapPoint point = _route.polyline.points[n];
        [initialSet addObject:[NSValue valueWithCGPoint:CGPointMake(point.x, point.y)]];
    }
    NSMutableSet *filteredSet = [[NSMutableSet alloc] initWithCapacity:_route.polyline.pointCount];
    
    for (MKRoute *route in routeArray) {
        
        NSMutableSet *set1 = initialSet;
        NSMutableSet *set2 = [[NSMutableSet alloc] initWithCapacity:route.polyline.pointCount];;
        for (int n = 0; n < route.polyline.pointCount; n++) {
            
            MKMapPoint point = route.polyline.points[n];
            [set2 addObject:[NSValue valueWithCGPoint:CGPointMake(point.x, point.y)]];
        }
        
        [set1 minusSet:set2]; //this will give you only the obejcts that are in both sets
        
        if (filteredSet.count != 0) {
            [set1 intersectSet:filteredSet];
        }
        result = [set1 allObjects];
        filteredSet = set1;
    }
    
    if (result.count != 0) {
        uniquePoint = MKMapPointMake([[result firstObject] CGPointValue].x, [[result firstObject] CGPointValue].y);
    }
    
    return uniquePoint;
}

@end
