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
#import "TSClusterOperation.h"

@interface ADClusterMapView () {
@private
    id <ADClusterMapViewDelegate>  _secondaryDelegate;
    ADMapCluster *                 _rootMapCluster;
    BOOL                           _isAnimatingClusters;
    BOOL                           _shouldComputeClusters;
    BOOL                           _isSettingAnnotations;
}

@property (nonatomic, strong) NSMutableSet *singleAnnotationsPool;
@property (nonatomic, strong) NSMutableSet *clusterAnnotationsPool;
@property (nonatomic, strong) NSMutableSet *clusterableAnnotationsAdded;
@property (nonatomic, strong) NSSet *annotationsToBeSet;
@property (nonatomic, strong) NSSet *originalAnnotations;
@property (nonatomic, strong) id<MKAnnotation> previouslySelectedAnnotation;
@property (nonatomic) BOOL shouldReselectAnnotation;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) TSClusterOperation *clusterOperation;

@end

@interface ADClusterMapView (Private)
- (void)_clusterInMapRect:(MKMapRect)rect;
@end

@implementation ADClusterMapView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        [self.operationQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)initAnnotationPools:(NSUInteger)numberOfAnnotationsInPool {
    
    [super removeAnnotations:_clusterAnnotations.allObjects];
    _singleAnnotationsPool = [[NSMutableSet alloc] initWithCapacity: numberOfAnnotationsInPool];
    _clusterAnnotationsPool = [[NSMutableSet alloc] initWithCapacity: numberOfAnnotationsInPool];
    for (int i = 0; i < numberOfAnnotationsInPool; i++) {
        ADClusterAnnotation * annotation = [[ADClusterAnnotation alloc] init];
        annotation.type = ADClusterAnnotationTypeLeaf;
        [_singleAnnotationsPool addObject:annotation];
        annotation = [[ADClusterAnnotation alloc] init];
        annotation.type = ADClusterAnnotationTypeCluster;
        [_clusterAnnotationsPool addObject:annotation];
    }
    [super addAnnotations:_singleAnnotationsPool.allObjects];
    [super addAnnotations:_clusterAnnotationsPool.allObjects];
    _clusterAnnotations = [_singleAnnotationsPool setByAddingObjectsFromSet:_clusterAnnotationsPool];
}

- (void)setAnnotations:(NSSet *)annotations {
    if (!_isSettingAnnotations && !_isAnimatingClusters && ! _operationQueue.operationCount) {
        _isSettingAnnotations = YES;
        NSLog(@"isSettingAnnoatations");
        _originalAnnotations = annotations;
    
        NSInteger numberOfAnnotationsInPool = 2 * [self numberOfClusters]; //We manage a pool of annotations. In case we have N splits and N joins in a single animation we have to double up the actual number of annotations that belongs to the pool.
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
            NSMutableSet * mapPointAnnotations = [[NSMutableSet alloc] initWithCapacity:annotations.count];
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
                    NSSet *annotations = _annotationsToBeSet;
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
    
    if (_clusterableAnnotationsAdded) {
        [_clusterableAnnotationsAdded addObject:annotation];
    }
    else {
        _clusterableAnnotationsAdded = [[NSMutableSet alloc] initWithObjects:annotation, nil];
    }
    
    [self setAnnotations:[NSSet setWithSet:_clusterableAnnotationsAdded]];
}

- (void)addClusteredAnnotations:(NSArray *)annotations {
    
    if (!annotations || !annotations.count) {
        return;
    }
    
    if (_clusterableAnnotationsAdded) {
        [_clusterableAnnotationsAdded addObjectsFromArray:annotations];
    }
    else {
        _clusterableAnnotationsAdded = [[NSMutableSet alloc] initWithArray:annotations];
    }
    
    [self setAnnotations:[NSSet setWithSet:_clusterableAnnotationsAdded]];
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
    
    int previousCount = _clusterableAnnotationsAdded.count;
    [_clusterableAnnotationsAdded minusSet:[NSSet setWithArray:annotations]];
    
    if (_clusterableAnnotationsAdded.count != previousCount) {;
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
    for (ADClusterAnnotation * annotation in [_singleAnnotationsPool setByAddingObjectsFromSet:_clusterAnnotationsPool]) {
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
    return [_originalAnnotations.allObjects arrayByAddingObjectsFromArray:otherAnnotations];
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
        NSSet *annotations = _annotationsToBeSet;
        _annotationsToBeSet = nil;
        _shouldComputeClusters = NO;
        [self setAnnotations:annotations];
    }
//    else if (_shouldComputeClusters) { // do one more computation if the user moved the map while animating
//        _shouldComputeClusters = NO;
//        [self _clusterInMapRect:self.visibleMapRect];
//    }
    if ([_secondaryDelegate respondsToSelector:@selector(clusterAnimationDidStopForMapView:)]) {
        [_secondaryDelegate clusterAnimationDidStopForMapView:self];
    }
    
    NSLog(@"Finished Animating");
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

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if ([_secondaryDelegate respondsToSelector:@selector(mapView:regionWillChangeAnimated:)]) {
        [_secondaryDelegate mapView:self regionWillChangeAnimated:animated];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    if (MKMapRectContainsPoint(self.visibleMapRect, MKMapPointForCoordinate(kADCoordinate2DOffscreen))) {
        return;
    }
    
//    if (_isAnimatingClusters) {
//        _shouldComputeClusters = YES;
//    } else
    if (!_isSettingAnnotations){
//        [NSObject cancelPreviousPerformRequestsWithTarget:self];
//        [self performSelector:@selector(_clusterInMapRect:) withObject:nil afterDelay:.2];
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


- (NSUInteger)numberOfClusters {
    NSUInteger numberOfClusters = 32; // default value
    if ([_secondaryDelegate respondsToSelector:@selector(numberOfClustersInMapView:)]) {
        numberOfClusters = [_secondaryDelegate numberOfClustersInMapView:self];
    }
    //multiply by 9 for the visible rect plus 8 directions of possible screen travel (up, down, up-left, down-left, etc.)
    return numberOfClusters * 9;
}

@end

@implementation ADClusterMapView (Private)


- (void)_clusterInMapRect:(MKMapRect)rect {
    
    NSLog(@"clusterInMapRect");
    
    _isAnimatingClusters = YES;
    
    [_operationQueue cancelAllOperations];
    TSClusterOperation *clusterOperation = [[TSClusterOperation alloc] initWithMapView:self
                                                                           rootCluster:_rootMapCluster
                                                                            completion:^(ADClusterMapView *mapView) {
                                                                            }];
    [_operationQueue addOperation:clusterOperation];
    [_operationQueue setSuspended:NO];
}


@end
