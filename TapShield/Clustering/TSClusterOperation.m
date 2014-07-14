//
//  TSClusterOperation.m
//  TapShield
//
//  Created by Adam Share on 7/14/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSClusterOperation.h"
#import <MapKit/MapKit.h>
#import "ADMapCluster.h"
#import "ADClusterAnnotation.h"
#import "ADMapPointAnnotation.h"
#import "NSDictionary+MKMapRect.h"
#import "CLLocation+Utilities.h"
#import "ADClusterMapView.h"

@interface TSClusterOperation ()

@property (weak, nonatomic) ADClusterMapView *mapView;
@property (strong, nonatomic) ADMapCluster *rootMapCluster;

@end

@implementation TSClusterOperation

- (instancetype)initWithMapView:(ADClusterMapView *)mapView rootCluster:(ADMapCluster *)rootCluster
{
    self = [super init];
    if (self) {
        self.mapView = mapView;
        self.rootMapCluster = rootCluster;
    }
    return self;
}

- (void)main {
    // a lengthy operation
    @autoreleasepool {
        
        
    }
}

- (void)_clusterInMapRect {
    
    NSLog(@"Begin Clustering");
    
    //Create buffer room for map drag outside visible rect before next regionDidChange
    MKMapRect rect = [self visibleMapRectWithBuffer];
    
    int numberOnScreen;
    
    if (_mapView.region.span.longitudeDelta > .005) {
        //create grid to estimate number of clusters needed based on the spread of annotations across map rect
        NSArray *mapRects = [self mapRectsFromNumberOfClustersAcross:5*3 mapRect:rect];
        
        //number of map rects that contain at least one annotation
        numberOnScreen = [_rootMapCluster numberOfMapRectsContainingChildren:mapRects];
        numberOnScreen = numberOnScreen * [self _numberOfClusters]/mapRects.count;
        
        if (_mapView.region.span.longitudeDelta < .1) {
            //if we are at a small enough span lets take into account and not over cluster
            if (numberOnScreen < [self _numberOfClusters]/9) {
                numberOnScreen = [self _numberOfClusters]/9;
            }
        }
    }
    else {
        //Really close lets just show as many single annotations as we can
        numberOnScreen = [self _numberOfClusters];
    }
    
    
    NSArray * clustersToShowOnMap = [_rootMapCluster find:numberOnScreen childrenInMapRect:rect];//[_rootMapCluster find:[self _numberOfClusters] childrenInMapRect:rect];
    
    // Build an array with available annotations (eg. not moving or not staying at the same place on the map)
    NSMutableArray * availableSingleAnnotations = [[NSMutableArray alloc] init];
    NSMutableArray * availableClusterAnnotations = [[NSMutableArray alloc] init];
    NSMutableArray * selfDividingSingleAnnotations = [[NSMutableArray alloc] init];
    NSMutableArray * selfDividingClusterAnnotations = [[NSMutableArray alloc] init];
    for (ADClusterAnnotation * annotation in _mapView.) {
        BOOL isAncestor = NO;
        if (annotation.cluster) { // if there is a cluster associated to the current annotation
            for (ADMapCluster * cluster in clustersToShowOnMap) { // is the current annotation cluster an ancestor of one of the clustersToShowOnMap?
                if ([annotation.cluster isAncestorOf:cluster]) {
                    if (cluster.annotation) {
                        [selfDividingSingleAnnotations addObject:annotation];
                    } else {
                        [selfDividingClusterAnnotations addObject:annotation];
                    }
                    isAncestor = YES;
                    break;
                }
            }
        }
        if (!isAncestor) { // if not an ancestor
            if (![self _annotation:annotation belongsToClusters:clustersToShowOnMap]) { // check if this annotation will be used later. If not, it is flagged as "available".
                if (annotation.type == ADClusterAnnotationTypeLeaf) {
                    [availableSingleAnnotations addObject:annotation];
                } else {
                    [availableClusterAnnotations addObject:annotation];
                }
            }
        }
    }
    
    // Let ancestor annotations divide themselves
    for (ADClusterAnnotation * annotation in [selfDividingSingleAnnotations arrayByAddingObjectsFromArray:selfDividingClusterAnnotations]) {
        BOOL willNeedAnAvailableAnnotation = NO;
        CLLocationCoordinate2D originalAnnotationCoordinate = annotation.coordinate;
        ADMapCluster * originalAnnotationCluster = annotation.cluster;
        for (ADMapCluster * cluster in clustersToShowOnMap) {
            if ([originalAnnotationCluster isAncestorOf:cluster]) {
                if (!willNeedAnAvailableAnnotation) {
                    willNeedAnAvailableAnnotation = YES;
                    annotation.cluster = cluster;
                    if (cluster.annotation) { // replace this annotation by a leaf one
                        NSAssert(annotation.type != ADClusterAnnotationTypeLeaf, @"Inconsistent annotation type!");
                        ADClusterAnnotation * singleAnnotation = [availableSingleAnnotations lastObject];
                        [availableSingleAnnotations removeLastObject];
                        singleAnnotation.cluster = annotation.cluster;
                        singleAnnotation.coordinate = originalAnnotationCoordinate;
                        [availableClusterAnnotations addObject:annotation];
                    }
                } else {
                    ADClusterAnnotation * availableAnnotation = nil;
                    if (cluster.annotation) {
                        availableAnnotation = [availableSingleAnnotations lastObject];
                        [availableSingleAnnotations removeLastObject];
                    } else {
                        availableAnnotation = [availableClusterAnnotations lastObject];
                        [availableClusterAnnotations removeLastObject];
                    }
                    availableAnnotation.cluster = cluster;
                    availableAnnotation.coordinate = originalAnnotationCoordinate;
                }
            }
        }
    }
    
    // Converge annotations to ancestor clusters
    for (ADMapCluster * cluster in clustersToShowOnMap) {
        BOOL didAlreadyFindAChild = NO;
        for (__strong ADClusterAnnotation * annotation in _clusterAnnotations) {
            if (![annotation isKindOfClass:[MKUserLocation class]]) {
                if (annotation.cluster && ![annotation isKindOfClass:[MKUserLocation class]]) {
                    if ([cluster isAncestorOf:annotation.cluster]) {
                        if (annotation.type == ADClusterAnnotationTypeLeaf) { // replace this annotation by a cluster one
                            ADClusterAnnotation * clusterAnnotation = [availableClusterAnnotations lastObject];
                            [availableClusterAnnotations removeLastObject];
                            clusterAnnotation.cluster = cluster;
                            // Setting the coordinate makes us call viewForAnnotation: right away, so make sure the cluster is set
                            clusterAnnotation.coordinate = annotation.coordinate;
                            [availableSingleAnnotations addObject:annotation];
                            annotation = clusterAnnotation;
                        } else {
                            annotation.cluster = cluster;
                        }
                        if (didAlreadyFindAChild) {
                            annotation.shouldBeRemovedAfterAnimation = YES;
                        }
                        if (ADClusterCoordinate2DIsOffscreen(annotation.coordinate)) {
                            annotation.coordinate = annotation.cluster.clusterCoordinate;
                        }
                        didAlreadyFindAChild = YES;
                    }
                }
            }
        }
    }
    for (ADClusterAnnotation * annotation in availableSingleAnnotations) {
        NSAssert(annotation.type == ADClusterAnnotationTypeLeaf, @"Inconsistent annotation type!");
        if (annotation.cluster) { // This is here for performance reason (annotation reset causes the refresh of the annotation because of KVO)
            [annotation reset];
        }
    }
    for (ADClusterAnnotation * annotation in availableClusterAnnotations) {
        NSAssert(annotation.type == ADClusterAnnotationTypeCluster, @"Inconsistent annotation type!");
        if (annotation.cluster) {
            [annotation reset];
        }
    }
    
    for (ADClusterAnnotation * annotation in _clusterAnnotations) {
        if (![annotation isKindOfClass:[MKUserLocation class]] && annotation.cluster) {
            [annotation.annotationView refreshView];
        }
    }
    
    [ADClusterMapView mutateCoordinatesOfClashingAnnotations:_clusterAnnotations];
    
    NSLog(@"Animating");
    [UIView beginAnimations:@"ADClusterMapViewAnimation" context:NULL];
    [UIView setAnimationBeginsFromCurrentState:NO];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5f];
    for (ADClusterAnnotation * annotation in _clusterAnnotations) {
        if (![annotation isKindOfClass:[MKUserLocation class]] && annotation.cluster) {
            NSAssert(!ADClusterCoordinate2DIsOffscreen(annotation.coordinate), @"annotation.coordinate not valid! Can't animate from an invalid coordinate (inconsistent result)!");
            annotation.coordinate = annotation.cluster.clusterCoordinate;
        }
    }
    [UIView commitAnimations];
    
    // Add not-yet-annotated clusters
    for (ADMapCluster * cluster in clustersToShowOnMap) {
        BOOL isAlreadyAnnotated = NO;
        for (ADClusterAnnotation * annotation in _clusterAnnotations) {
            if (![annotation isKindOfClass:[MKUserLocation class]]) {
                if ([cluster isEqual:annotation.cluster]) {
                    isAlreadyAnnotated = YES;
                    break;
                }
            }
        }
        if (!isAlreadyAnnotated) {
            if (cluster.annotation) {
                ((ADClusterAnnotation *)[availableSingleAnnotations lastObject]).cluster = cluster; // the order here is important: because of KVO, the cluster property must be set before the coordinate property (change of coordinate -> refresh of the view -> refresh of the title -> the cluster can't be nil)
                ((ADClusterAnnotation *)[availableSingleAnnotations lastObject]).coordinate = cluster.clusterCoordinate;
                [((ADClusterAnnotation *)[availableSingleAnnotations lastObject]).annotationView refreshView];
                [availableSingleAnnotations removeLastObject]; // update the availableAnnotations
            } else {
                ((ADClusterAnnotation *)[availableClusterAnnotations lastObject]).cluster = cluster; // the order here is important: because of KVO, the cluster property must be set before the coordinate property (change of coordinate -> refresh of the view -> refresh of the title -> the cluster can't be nil)
                ((ADClusterAnnotation *)[availableClusterAnnotations lastObject]).coordinate = cluster.clusterCoordinate;
                [((ADClusterAnnotation *)[availableSingleAnnotations lastObject]).annotationView refreshView];
                [availableClusterAnnotations removeLastObject]; // update the availableAnnotations
            }
        }
    }
    for (ADClusterAnnotation * annotation in availableSingleAnnotations) {
        NSAssert(annotation.type == ADClusterAnnotationTypeLeaf, @"Inconsistent annotation type!");
        [annotation reset];
    }
    for (ADClusterAnnotation * annotation in availableClusterAnnotations) {
        NSAssert(annotation.type == ADClusterAnnotationTypeCluster, @"Inconsistent annotation type!");
        [annotation reset];
    }
    
    NSLog(@"Finished Clustering");
}

- (NSInteger)_numberOfClusters {
    NSInteger numberOfClusters = 32; // default value
    if ([_secondaryDelegate respondsToSelector:@selector(numberOfClustersInMapView:)]) {
        numberOfClusters = [_secondaryDelegate numberOfClustersInMapView:self];
    }
    //multiply by 9 for the visible rect plus 8 directions of possible screen travel (up, down, up-left, down-left, etc.)
    return numberOfClusters * 9;
}


- (BOOL)_annotation:(ADClusterAnnotation *)annotation belongsToClusters:(NSArray *)clusters {
    if (annotation.cluster) {
        for (ADMapCluster * cluster in clusters) {
            if ([cluster isAncestorOf:annotation.cluster] || [cluster isEqual:annotation.cluster]) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - Spread close annotations

+ (void)mutateCoordinatesOfClashingAnnotations:(NSArray *)annotations {
    
    NSDictionary *coordinateValuesToAnnotations = [self groupAnnotationsByLocationValue:annotations];
    
    for (NSValue *coordinateValue in coordinateValuesToAnnotations.allKeys) {
        NSMutableArray *outletsAtLocation = coordinateValuesToAnnotations[coordinateValue];
        if (outletsAtLocation.count > 1) {
            CLLocationCoordinate2D coordinate;
            [coordinateValue getValue:&coordinate];
            [self repositionAnnotations:outletsAtLocation toAvoidClashAtCoordination:coordinate];
        }
    }
}

+ (NSDictionary *)groupAnnotationsByLocationValue:(NSArray *)annotations {
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    for (ADClusterAnnotation *pin in annotations) {
        
        if ([pin isKindOfClass:[MKUserLocation class]] || !pin.cluster) {
            continue;
        }
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DRoundedLonLat(pin.cluster.clusterCoordinate, 5);
        NSValue *coordinateValue = [NSValue valueWithBytes:&coordinate objCType:@encode(CLLocationCoordinate2D)];
        
        NSMutableArray *annotationsAtLocation = result[coordinateValue];
        if (!annotationsAtLocation) {
            annotationsAtLocation = [NSMutableArray array];
            result[coordinateValue] = annotationsAtLocation;
        }
        
        [annotationsAtLocation addObject:pin];
    }
    return result;
}

+ (void)repositionAnnotations:(NSMutableArray *)annotations toAvoidClashAtCoordination:(CLLocationCoordinate2D)coordinate {
    
    double distance = 3 * annotations.count / 2.0;
    double radiansBetweenAnnotations = (M_PI * 2) / annotations.count;
    
    for (int i = 0; i < annotations.count; i++) {
        
        double heading = radiansBetweenAnnotations * i;
        CLLocationCoordinate2D newCoordinate = [self calculateCoordinateFrom:coordinate onBearing:heading atDistance:distance];
        
        ADClusterAnnotation *annotation = annotations[i];
        annotation.cluster.clusterCoordinate = newCoordinate;
    }
}

+ (CLLocationCoordinate2D)calculateCoordinateFrom:(CLLocationCoordinate2D)coordinate  onBearing:(double)bearingInRadians atDistance:(double)distanceInMetres {
    
    double coordinateLatitudeInRadians = coordinate.latitude * M_PI / 180;
    double coordinateLongitudeInRadians = coordinate.longitude * M_PI / 180;
    
    double distanceComparedToEarth = distanceInMetres / 6378100;
    
    double resultLatitudeInRadians = asin(sin(coordinateLatitudeInRadians) * cos(distanceComparedToEarth) + cos(coordinateLatitudeInRadians) * sin(distanceComparedToEarth) * cos(bearingInRadians));
    double resultLongitudeInRadians = coordinateLongitudeInRadians + atan2(sin(bearingInRadians) * sin(distanceComparedToEarth) * cos(coordinateLatitudeInRadians), cos(distanceComparedToEarth) - sin(coordinateLatitudeInRadians) * sin(resultLatitudeInRadians));
    
    CLLocationCoordinate2D result;
    result.latitude = resultLatitudeInRadians * 180 / M_PI;
    result.longitude = resultLongitudeInRadians * 180 / M_PI;
    return result;
}

- (NSArray *)mapRectsFromNumberOfClustersAcross:(int)amount mapRect:(MKMapRect)rect {
    
    if (amount == 0) {
        return @[[NSDictionary dictionaryFromMapRect:rect]];
    }
    
    double x = rect.origin.x;
    double y = rect.origin.y;
    double width = rect.size.width;
    double height = rect.size.height;
    
    //create basic cluster grid
    double clusterWidth = width/amount;
    int horizontalClusters = amount;
    int verticalClusters = round(height/clusterWidth);
    double clusterHeight = height/verticalClusters;
    
    //build array of MKMapRects
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:10];
    for (int i=0; i<horizontalClusters; i++) {
        double newX = x + clusterWidth*(i);
        for (int j=0; j<verticalClusters; j++) {
            double newY = y + clusterHeight*(j);
            MKMapRect newRect = MKMapRectMake(newX, newY, clusterWidth, clusterHeight);
            [array addObject:[NSDictionary dictionaryFromMapRect:newRect]];
        }
    }
    
    return array;
}

- (MKMapRect)visibleMapRectWithBuffer {
    
    double width = self.visibleMapRect.size.width;
    double height = self.visibleMapRect.size.height;
    MKMapRect mapRect = self.visibleMapRect;
    mapRect = MKMapRectUnion(mapRect, MKMapRectOffset(self.visibleMapRect, -width, -height));
    mapRect = MKMapRectUnion(mapRect, MKMapRectOffset(self.visibleMapRect, width, height));
    
    return mapRect;
}

@end
