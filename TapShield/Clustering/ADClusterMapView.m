//
//  ADClusterMapView.m
//  ADClusterMapView
//
//  Created by Patrick Nollet on 30/06/11.
//  Copyright 2011 Applidium. All rights reserved.
//

#import <QuartzCore/CoreAnimation.h>
#import "ADClusterMapView.h"
#import "ADClusterAnnotation.h"
#import "ADMapPointAnnotation.h"
#import "NSDictionary+MKMapRect.h"
#import "CLLocation+Utilities.h"

@interface ADClusterMapView () {
@private
    id <ADClusterMapViewDelegate>  _secondaryDelegate;
    ADMapCluster *                 _rootMapCluster;
    NSMutableArray *               _singleAnnotationsPool;
    NSMutableArray *               _clusterAnnotationsPool;
    BOOL                           _isAnimatingClusters;
    BOOL                           _shouldComputeClusters;
    BOOL                           _isSettingAnnotations;
    NSArray *                      _annotationsToBeSet;
    NSArray *                      _originalAnnotations;
}

@property (nonatomic, strong) NSMutableArray *clusterableAnnotationsAdded;
@property (nonatomic, strong) id<MKAnnotation> previouslySelectedAnnotation;
@property (nonatomic) BOOL shouldReselectAnnotation;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@interface ADClusterMapView (Private)
- (void)_clusterInMapRect:(MKMapRect)rect;
- (NSInteger)_numberOfClusters;
- (BOOL)_annotation:(ADClusterAnnotation *)annotation belongsToClusters:(NSArray *)clusters;
@end

@implementation ADClusterMapView

- (void)initAnnotationPools:(NSUInteger)numberOfAnnotationsInPool {
    
    [super removeAnnotations:_clusterAnnotations];
    _singleAnnotationsPool = [[NSMutableArray alloc] initWithCapacity: numberOfAnnotationsInPool];
    _clusterAnnotationsPool = [[NSMutableArray alloc] initWithCapacity: numberOfAnnotationsInPool];
    for (int i = 0; i < numberOfAnnotationsInPool; i++) {
        ADClusterAnnotation * annotation = [[ADClusterAnnotation alloc] init];
        annotation.type = ADClusterAnnotationTypeLeaf;
        [_singleAnnotationsPool addObject:annotation];
        annotation = [[ADClusterAnnotation alloc] init];
        annotation.type = ADClusterAnnotationTypeCluster;
        [_clusterAnnotationsPool addObject:annotation];
    }
    [super addAnnotations:_singleAnnotationsPool];
    [super addAnnotations:_clusterAnnotationsPool];
    _clusterAnnotations = [_singleAnnotationsPool arrayByAddingObjectsFromArray:_clusterAnnotationsPool];
}

- (void)setAnnotations:(NSArray *)annotations {
    if (!_isSettingAnnotations && !_isAnimatingClusters) {
        _isSettingAnnotations = YES;
        _originalAnnotations = annotations;
        
        NSInteger numberOfAnnotationsInPool = 2 * [self _numberOfClusters]; //We manage a pool of annotations. In case we have N splits and N joins in a single animation we have to double up the actual number of annotations that belongs to the pool.
        if (_clusterAnnotations.count != numberOfAnnotationsInPool * 2) {
            [self initAnnotationPools:numberOfAnnotationsInPool];
        }

        double gamma = 1.0; // default value
        if ([_secondaryDelegate respondsToSelector:@selector(clusterDiscriminationPowerForMapView:)]) {
            gamma = [_secondaryDelegate clusterDiscriminationPowerForMapView:self];
        }

        NSString * clusterTitle = @"%d elements";
        if ([_secondaryDelegate respondsToSelector:@selector(clusterTitleForMapView:)]) {
            clusterTitle = [_secondaryDelegate clusterTitleForMapView:self];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            // use wrapper annotations that expose a MKMapPoint property instead of a CLLocationCoordinate2D property
            NSMutableArray * mapPointAnnotations = [[NSMutableArray alloc] initWithCapacity:annotations.count];
            for (id<MKAnnotation> annotation in annotations) {
                ADMapPointAnnotation * mapPointAnnotation = [[ADMapPointAnnotation alloc] initWithAnnotation:annotation];
                [mapPointAnnotations addObject:mapPointAnnotation];
            }

            // Setting visibility of cluster annotations subtitle (defaults to YES)
            BOOL shouldShowSubtitle = YES;
            if ([_secondaryDelegate respondsToSelector:@selector(shouldShowSubtitleForClusterAnnotationsInMapView:)]) {
                shouldShowSubtitle = [_secondaryDelegate shouldShowSubtitleForClusterAnnotationsInMapView:self];
            }

            _rootMapCluster = [ADMapCluster rootClusterForAnnotations:mapPointAnnotations
                                                                gamma:gamma
                                                         clusterTitle:clusterTitle
                                                         showSubtitle:shouldShowSubtitle];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self _clusterInMapRect:self.visibleMapRect];
                if ([_secondaryDelegate respondsToSelector:@selector(mapViewDidFinishClustering:)]) {
                    [_secondaryDelegate mapViewDidFinishClustering:self];
                }
                _isSettingAnnotations = NO;
                if (_annotationsToBeSet) {
                    NSArray * annotations = _annotationsToBeSet;
                    _annotationsToBeSet = nil;
                    [self setAnnotations:annotations];
                }
            });
        });
    } else {
        // keep the annotations for setting them later
        _annotationsToBeSet = annotations;
    }
}

- (void)addClusteredAnnotation:(id<MKAnnotation>)annotation {
    
    if (!annotation) {
        return;
    }
    
    NSMutableArray *array;
    
    if (_clusterableAnnotationsAdded) {
        array = [[NSMutableArray alloc] initWithArray:_clusterableAnnotationsAdded];
        
        [array addObject:annotation];
    }
    else {
        array = [[NSMutableArray alloc] initWithObjects:annotation, nil];
    }
    
    _clusterableAnnotationsAdded = array;
    [self setAnnotations:array];
}

- (void)addClusteredAnnotations:(NSArray *)annotations {
    
    if (!annotations || !annotations.count) {
        return;
    }
    
    NSMutableArray *array;
    
    if (_clusterableAnnotationsAdded) {
        array = [[NSMutableArray alloc] initWithArray:_clusterableAnnotationsAdded];
        
        [array addObjectsFromArray:annotations];
    }
    else {
        array = [[NSMutableArray alloc] initWithArray:annotations];
    }
    
    _clusterableAnnotationsAdded = array;
    [self setAnnotations:array];
}

- (void)addAnnotation:(id<MKAnnotation>)annotation {
    [self addNonClusteredAnnotation:annotation];
}

- (void)addAnnotations:(NSArray *)annotations {
    
    [self addNonClusteredAnnotations:annotations];
}

- (void)removeAnnotation:(id<MKAnnotation>)annotation {
    
    if ([_clusterableAnnotationsAdded containsObject:annotation]) {
        [_clusterableAnnotationsAdded removeObject:annotation];
        [self setAnnotations:_clusterableAnnotationsAdded];
    }
    
    [super removeAnnotation:annotation];
}

- (void)removeAnnotations:(NSArray *)annotations {
    
    NSMutableSet *set = [NSMutableSet setWithArray:_clusterableAnnotationsAdded];
    [set minusSet:[NSSet setWithArray:annotations]];
    if (set.count != _clusterableAnnotationsAdded.count) {
        _clusterableAnnotationsAdded = [[NSMutableArray alloc] initWithArray:set.allObjects];
        [self setAnnotations:_clusterableAnnotationsAdded];
    }
    
    [super removeAnnotations:annotations];
}

- (void)selectAnnotation:(id<MKAnnotation>)annotation animated:(BOOL)animated {
    [super selectAnnotation:[self clusterAnnotationForOriginalAnnotation:annotation] animated:animated];
}

- (void)selectClusterAnnotation:(ADClusterAnnotation *)annotation animated:(BOOL)animated {
    [super selectAnnotation:annotation animated:animated];
}

- (NSArray *)displayedAnnotations {
    NSMutableArray * displayedAnnotations = [[NSMutableArray alloc] init];
    for (ADClusterAnnotation * annotation in [_singleAnnotationsPool arrayByAddingObjectsFromArray:_clusterAnnotationsPool]) {
        NSAssert([annotation isKindOfClass:[ADClusterAnnotation class]], @"Unexpected annotation!");
        if (annotation.coordinate.latitude != kADCoordinate2DOffscreen.latitude && annotation.coordinate.longitude != kADCoordinate2DOffscreen.longitude) {
            [displayedAnnotations addObject:annotation];
        }
    }
    return displayedAnnotations;
}

// careful, the implementation of the following method is slow
- (NSArray *)annotations {
    NSArray * otherAnnotations = [[super annotations] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return  ![evaluatedObject isKindOfClass: [ADClusterAnnotation class]];
    }]];
    return [_originalAnnotations arrayByAddingObjectsFromArray:otherAnnotations];
}

- (void)addNonClusteredAnnotation:(id<MKAnnotation>)annotation {
    [super addAnnotation:annotation];
}

- (void)addNonClusteredAnnotations:(NSArray *)annotations {
    [super addAnnotations:annotations];
}

- (void)removeNonClusteredAnnotation:(id<MKAnnotation>)annotation {
    [super removeAnnotation:annotation];
}

- (void)removeNonClusteredAnnotations:(NSArray *)annotations {
    [super removeAnnotations:annotations];
}

#pragma mark - Objective-C Runtime and subclassing methods
- (void)setDelegate:(id<ADClusterMapViewDelegate>)delegate {
    /*
     For an undefined reason, setDelegate is called multiple times. The first time, it is called with delegate = nil
     Therefore _secondaryDelegate may be nil when [_secondaryDelegate respondsToSelector:aSelector] is called (result : NO)
     There is some caching done in order to avoid calling respondsToSelector: too much. That's why if we don't take care the runtime will guess that we always have [_secondaryDelegate respondsToSelector:] = NO
     Therefore we clear the cache by setting the delegate to nil.
     */
    [super setDelegate:nil];
    _secondaryDelegate = delegate;
    [super setDelegate:self];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL respondsToSelector = [super respondsToSelector:aSelector] || [_secondaryDelegate respondsToSelector:aSelector];
    return respondsToSelector;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([_secondaryDelegate respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:_secondaryDelegate];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    for (ADClusterAnnotation * annotation in _clusterAnnotations) {
        if ([annotation isKindOfClass:[ADClusterAnnotation class]]) {
            if (annotation.shouldBeRemovedAfterAnimation) {
                [annotation reset];
            }
            annotation.shouldBeRemovedAfterAnimation = NO;
        }
    }
    _isAnimatingClusters = NO;
    if (_annotationsToBeSet) {
        NSArray * annotations = _annotationsToBeSet;
        _annotationsToBeSet = nil;
        _shouldComputeClusters = NO;
        [self setAnnotations:annotations];
    }
    else if (_shouldComputeClusters) { // do one more computation if the user moved the map while animating
        _shouldComputeClusters = NO;
        [self _clusterInMapRect:self.visibleMapRect];
    }
    if ([_secondaryDelegate respondsToSelector:@selector(clusterAnimationDidStopForMapView:)]) {
        [_secondaryDelegate clusterAnimationDidStopForMapView:self];
    }
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (![annotation isKindOfClass:[ADClusterAnnotation class]]) {
        if ([_secondaryDelegate respondsToSelector:@selector(mapView:viewForAnnotation:)]) {
            return [_secondaryDelegate mapView:self viewForAnnotation:annotation];
        } else {
            return nil;
        }
	}
    // only leaf clusters have annotations
    if (((ADClusterAnnotation *)annotation).type == ADClusterAnnotationTypeLeaf || ![_secondaryDelegate respondsToSelector:@selector(mapView:viewForClusterAnnotation:)]) {
        if ([_secondaryDelegate respondsToSelector:@selector(mapView:viewForAnnotation:)]) {
            return [_secondaryDelegate mapView:self viewForAnnotation:annotation];
        }
        else {
            return nil;
        }
    } else {
        return [_secondaryDelegate mapView:self viewForClusterAnnotation:annotation];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    if (MKMapRectContainsPoint(self.visibleMapRect, MKMapPointForCoordinate(kADCoordinate2DOffscreen))) {
        return;
    }
    
    if (_isAnimatingClusters) {
        _shouldComputeClusters = YES;
    } else if (!_isSettingAnnotations){
        _isAnimatingClusters = YES;
        [self _clusterInMapRect:self.visibleMapRect];
    }
    if (_previouslySelectedAnnotation) {
        _shouldReselectAnnotation = YES;
    }
    for (id<MKAnnotation> annotation in [self selectedAnnotations]) {
        [self deselectAnnotation:annotation animated:YES];
    }
    if ([_secondaryDelegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:)]) {
        [_secondaryDelegate mapView:self regionDidChangeAnimated:animated];
    }
    if (_shouldReselectAnnotation) {
        _shouldReselectAnnotation = NO;
        [self selectAnnotation:_previouslySelectedAnnotation animated:YES];
        _previouslySelectedAnnotation = nil;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if ([view.annotation isKindOfClass:[ADClusterAnnotation class]]) {
        if (((ADClusterAnnotation *)view.annotation).type == ADClusterAnnotationTypeLeaf && !_shouldReselectAnnotation) {
            _previouslySelectedAnnotation = [((ADClusterAnnotation *)view.annotation).originalAnnotations firstObject];
        }
    }
    
    
    if ([_secondaryDelegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)]) {
        [_secondaryDelegate mapView:mapView didSelectAnnotationView:view];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    if (!_shouldReselectAnnotation) {
        _previouslySelectedAnnotation = nil;
    }
    
    if ([_secondaryDelegate respondsToSelector:@selector(mapView:didDeselectAnnotationView:)]) {
        [_secondaryDelegate mapView:mapView didDeselectAnnotationView:view];
    }
}

- (ADClusterAnnotation *)clusterAnnotationForOriginalAnnotation:(id<MKAnnotation>)annotation {
    NSAssert(![annotation isKindOfClass:[ADClusterAnnotation class]], @"Unexpected annotation!");
    for (ADClusterAnnotation * clusterAnnotation in self.displayedAnnotations) {
        if ([clusterAnnotation.cluster isRootClusterForAnnotation:annotation]) {
            return clusterAnnotation;
        }
    }
    return nil;
}
@end

@implementation ADClusterMapView (Private)

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

- (void)_clusterInMapRect:(MKMapRect)rect {
    
    NSLog(@"Begin Clustering");
    
    //Create buffer room for map drag outside visible rect before next regionDidChange
    rect = [self visibleMapRectWithBuffer];
    
    int numberOnScreen;
    
    if (self.region.span.longitudeDelta > .005) {
        //create grid to estimate number of clusters needed based on the spread of annotations across map rect
        NSArray *mapRects = [self mapRectsFromNumberOfClustersAcross:5*3 mapRect:rect];
        
        //number of map rects that contain at least one annotation
        numberOnScreen = [_rootMapCluster numberOfMapRectsContainingChildren:mapRects];
        numberOnScreen = numberOnScreen * [self _numberOfClusters]/mapRects.count;
        
        if (self.region.span.longitudeDelta < .1) {
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
    for (ADClusterAnnotation * annotation in [_singleAnnotationsPool arrayByAddingObjectsFromArray:_clusterAnnotationsPool]) {
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


@end
