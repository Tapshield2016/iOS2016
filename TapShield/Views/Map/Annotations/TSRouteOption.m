//
//  TSRouteOption.m
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRouteOption.h"
#import "TSUtilities.h"
#import "TSLocationController.h"
#import "MKPolyline+EncodeDecode.h"

@implementation TSRouteOption

- (id)initWithRoute:(MKRoute *)route {
    
    self = [super init];
    
    if (self) {
        self.route = route;
        
        _name = route.name;
        _expectedTravelTime = route.expectedTravelTime;
        _polyline = route.polyline;
        _distance = route.distance;
        _transportType = route.transportType;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        
        _name = [coder decodeObjectForKey:@"routeName"];
        _expectedTravelTime = [coder decodeIntegerForKey:@"routeExpectedTravelTime"];
        _polyline = [coder decodeObjectForKey:@"routePolyline"];
        _distance = [coder decodeDoubleForKey:@"distance"];
        _transportType = [coder decodeIntForKey:@"transportType"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    
    [encoder encodeObject:_name forKey:@"routeName"];
    [encoder encodeInteger:_expectedTravelTime forKey:@"routeExpectedTravelTime"];
    [encoder encodeObject:_polyline forKey:@"routePolyline"];
    [encoder encodeDouble:_distance forKey:@"distance"];
    [encoder encodeInt:_transportType forKey:@"transportType"];
}

- (void)findUniqueMapPointComparingRoutes:(NSArray *)routeArray completion:(void (^)(MKMapPoint uniquePointFromSet))completion {
    
    if (!_route) {
        if (completion) {
            completion(MKMapPointMake(0, 0));
        }
        return;
    }
    
    //Make sure route isn't comparing against itself
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:routeArray];
    [mutableArray removeObjectsInArray:@[_route]];
    routeArray = mutableArray;
    
    if (routeArray.count == 0 || !routeArray) {
        //No other routes, return close to median point
        MKMapPoint middle = [self middleMapPointLineStart:_route.polyline.points[0] end:_route.polyline.points[_route.polyline.pointCount- 1]];
        MKMapPoint uniquePointFromSearch = [TSUtilities closestPoint:middle toPoly:_route.polyline];
        if (completion) {
            completion(uniquePointFromSearch);
        }
        return;
    }
    
    MKMapPoint uniquePointFromSet;
    NSMutableSet *filteredSet = [[NSMutableSet alloc] initWithCapacity:_route.polyline.pointCount];
    
    //Convert point structs to values
    NSMutableSet *initialSet = [[NSMutableSet alloc] initWithCapacity:_route.polyline.pointCount];
    for (int n = 0; n < _route.polyline.pointCount; n++) {
        MKMapPoint point = _route.polyline.points[n];
        [initialSet addObject:[NSValue valueWithCGPoint:CGPointMake(point.x, point.y)]];
    }
    
    for (MKRoute *route in routeArray) {
        
        NSMutableSet *set1 = initialSet;
        NSMutableSet *set2 = [[NSMutableSet alloc] initWithCapacity:route.polyline.pointCount];
        
        //Convert point structs to values to compare
        for (int n = 0; n < route.polyline.pointCount; n++) {
            MKMapPoint point = route.polyline.points[n];
            [set2 addObject:[NSValue valueWithCGPoint:CGPointMake(point.x, point.y)]];
        }
        
        //Remove values that match
        [set1 minusSet:set2];
        
        if (filteredSet.count != 0) {
            //Compare previously collected set, return values that are in both sets
            [set1 intersectSet:filteredSet];
        }
        filteredSet = set1;
    }
    
    if (filteredSet.count == 0) {
        //No unique points, return close to median point
        MKMapPoint middle = [self middleMapPointLineStart:_route.polyline.points[0] end:_route.polyline.points[_route.polyline.pointCount- 1]];
        MKMapPoint uniquePointFromSearch = [TSUtilities closestPoint:middle toPoly:_route.polyline];
        if (completion) {
            completion(uniquePointFromSearch);
        }
        return;
    }
    
    NSSortDescriptor *sortX = [NSSortDescriptor sortDescriptorWithKey:nil
                                                            ascending:YES
                                                           comparator:^NSComparisonResult(id obj1, id obj2) {
                                                               CGPoint pt1 = [obj1 CGPointValue];
                                                               CGPoint pt2 = [obj2 CGPointValue];
                                                            
                                                               if (pt1.x > pt2.x)
                                                                   return NSOrderedDescending;
                                                               else if (pt1.x < pt2.x)
                                                                   return NSOrderedAscending;
                                                               else
                                                                   return NSOrderedSame;
                                                           }];
    
    NSSortDescriptor *sortY = [NSSortDescriptor sortDescriptorWithKey:nil
                                                            ascending:YES
                                                           comparator:^NSComparisonResult(id obj1, id obj2) {
                                                               CGPoint pt1 = [obj1 CGPointValue];
                                                               CGPoint pt2 = [obj2 CGPointValue];
                                                               
                                                               if (pt1.y > pt2.y)
                                                                   return NSOrderedDescending;
                                                               else if (pt1.y < pt2.y)
                                                                   return NSOrderedAscending;
                                                               else
                                                                   return NSOrderedSame;
                                                           }];
    
    NSArray *xSort = [filteredSet sortedArrayUsingDescriptors:@[sortX]];
    NSArray *ySort = [filteredSet sortedArrayUsingDescriptors:@[sortY]];
    
    CGPoint middle;
    
    if ([[xSort lastObject]CGPointValue].x - [[xSort firstObject ]CGPointValue].x >
        [[ySort lastObject]CGPointValue].y - [[ySort firstObject ]CGPointValue].y) {
        middle = [self middleCGPointLineStart:[[xSort firstObject ]CGPointValue] end:[[xSort lastObject ]CGPointValue]];
    }
    else {
        middle = [self middleCGPointLineStart:[[ySort firstObject ]CGPointValue] end:[[ySort lastObject ]CGPointValue]];
    }
    
    MKMapPoint middleMapPoint = MKMapPointMake(middle.x, middle.y);
    uniquePointFromSet = [TSUtilities closestPoint:middleMapPoint toPoly:_route.polyline];
    
    if (completion) {
        completion(uniquePointFromSet);
    }
}

- (CGPoint)middleCGPointLineStart:(CGPoint)point1 end:(CGPoint)point2 {
    float x = (point2.x - point1.x)/2 + point1.x;
    float y = (point2.y - point1.y)/2 + point1.y;
                
    return CGPointMake(x,y);
}

- (MKMapPoint)middleMapPointLineStart:(MKMapPoint)point1 end:(MKMapPoint)point2 {
    float x = (point2.x - point1.x)/2 + point1.x;
    float y = (point2.y - point1.y)/2 + point1.y;
    
    return MKMapPointMake(x,y);
}


- (CLLocationDistance)distanceRemaining {
    
   return [self distanceRemainingFromLocation:[TSLocationController sharedLocationController].location];
}


- (CLLocationDistance)distanceRemainingFromLocation:(CLLocation *)location {
    
    return [self.route.polyline distanceToEndFromPoint:MKMapPointForCoordinate(location.coordinate)];
}

- (MKRouteStep *)currentStep {
    
    MKRouteStep *currentStep;
    CLLocationDistance distance = MAXFLOAT;
    
    NSUInteger distanceIncreasing = 0;
    
    for (MKRouteStep *step in _route.steps) {
        
        CLLocationDistance stepDistance = [step.polyline distanceOfPoint:MKMapPointForCoordinate([TSLocationController sharedLocationController].location.coordinate)];
        
        if (stepDistance < distance) {
            distance = stepDistance;
            currentStep = step;
            distanceIncreasing = 0;
        }
        else {
            distanceIncreasing++;
        }
        
        //probably already found the right step no need to continue
        if (distanceIncreasing > 5) {
            break;
        }
    }
    
    return currentStep;
}

@end
