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


- (void)findUniqueMapPointComparingRoutes:(NSArray *)routeArray completion:(void (^)(MKMapPoint uniquePointFromSet))completion {
    
    if (self.route.polyline.pointCount > 8000) {
        [self findUniqueMapPointQuickComparingRoutes:routeArray completion:completion];
    }
    else {
        [self findUniqueMapPointAccurateComparingRoutes:routeArray completion:completion];
    }
}

- (void)findUniqueMapPointQuickComparingRoutes:(NSArray *)routeArray completion:(void (^)(MKMapPoint uniquePointFromSet))completion {
    
    if (!_route) {
        if (completion) {
            completion(MKMapPointMake(0, 0));
            return;
        }
    }
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:routeArray];
    [mutableArray removeObjectsInArray:@[_route]];
    routeArray = mutableArray;
    
    if (routeArray.count == 0 || !routeArray) {
        if (completion) {
            completion(_route.polyline.points[_route.polyline.pointCount*2/3]);
        }
        return;
    }
    
    MKMapPoint uniquePointFromSet = _route.polyline.points[_route.polyline.pointCount/2];
    NSArray *result;
    
    NSLog(@"%lu", (unsigned long)_route.polyline.pointCount);
    NSLog(@"Begin Filter");
    
    //    }
    //    else {
    ///////////Using NSSet
    
    NSMutableSet *initialSet = [[NSMutableSet alloc] initWithCapacity:_route.polyline.pointCount];
    
    for (int n = 0; n < _route.polyline.pointCount; n++) {
        
        MKMapPoint point = _route.polyline.points[n];
        [initialSet addObject:[NSValue valueWithCGPoint:CGPointMake(point.x, point.y)]];
    }
    NSMutableSet *filteredSet = [[NSMutableSet alloc] initWithCapacity:_route.polyline.pointCount];
    
    for (MKRoute *route in routeArray) {
        
        NSMutableSet *set1 = initialSet;
        NSMutableSet *set2 = [[NSMutableSet alloc] initWithCapacity:route.polyline.pointCount];
        for (int n = 0; n < route.polyline.pointCount; n++) {
            
            MKMapPoint point = route.polyline.points[n];
            [set2 addObject:[NSValue valueWithCGPoint:CGPointMake(point.x, point.y)]];
        }
        
        [set1 minusSet:set2];
        
        if (filteredSet.count != 0) {
            [set1 intersectSet:filteredSet]; //this will give you only the objects that are in both sets
        }
        result = [set1 allObjects];
        filteredSet = set1;
        
    }
    
    //////////////
    //    }
    
    if (result.count != 0) {
        uniquePointFromSet = MKMapPointMake([result[result.count/2] CGPointValue].x, [result[result.count/2] CGPointValue].y);
    }
    
    NSLog(@"End Filter");
    
    if (completion) {
        completion(uniquePointFromSet);
    }
}

- (void)findUniqueMapPointAccurateComparingRoutes:(NSArray *)routeArray completion:(void (^)(MKMapPoint uniquePointFromArray))completion {
    
    if (!_route) {
        if (completion) {
            completion(MKMapPointMake(0, 0));
            return;
        }
    }
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:routeArray];
    [mutableArray removeObjectsInArray:@[_route]];
    routeArray = mutableArray;
    
    if (routeArray.count == 0 || !routeArray) {
        if (completion) {
            completion(_route.polyline.points[_route.polyline.pointCount*2/3]);
        }
        return;
    }
    
    MKMapPoint uniquePointFromArray = _route.polyline.points[_route.polyline.pointCount/2];
    NSArray *result;
    
    NSLog(@"%lu", (unsigned long)_route.polyline.pointCount);
    NSLog(@"Begin Filter");
    
    NSMutableArray *initialArray = [[NSMutableArray alloc] initWithCapacity:_route.polyline.pointCount];
    
    for (int n = 0; n < _route.polyline.pointCount; n++) {
        
        MKMapPoint point = _route.polyline.points[n];
        [initialArray addObject:[NSValue valueWithCGPoint:CGPointMake(point.x, point.y)]];
    }
    NSMutableArray *filteredArray = [[NSMutableArray alloc] initWithCapacity:_route.polyline.pointCount];
    
    for (MKRoute *route in routeArray) {
        
        NSMutableArray *array1 = [[NSMutableArray alloc] initWithArray:initialArray];
        NSMutableArray *array2 = [[NSMutableArray alloc] initWithCapacity:route.polyline.pointCount];
        for (int n = 0; n < route.polyline.pointCount; n++) {
            
            MKMapPoint point = route.polyline.points[n];
            [array2 addObject:[NSValue valueWithCGPoint:CGPointMake(point.x, point.y)]];
        }
        
        [array1 removeObjectsInArray:array2];
        
        if (filteredArray.count != 0) {
            
            NSPredicate *intersectPredicate = [NSPredicate predicateWithFormat:@"SELF IN %@", filteredArray];
            array1 = [[NSMutableArray alloc]initWithArray:[array1 filteredArrayUsingPredicate:intersectPredicate]];
        }
        result = array1;
        filteredArray = array1;
        
    }
    
    
    if (result.count != 0) {
        uniquePointFromArray = MKMapPointMake([result[result.count/2] CGPointValue].x, [result[result.count/2] CGPointValue].y);
    }
    
    NSLog(@"End Filter");
    
    if (completion) {
        completion(uniquePointFromArray);
    }
}



@end
