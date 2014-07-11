//
//  TSReportAnnotationManager.m
//  TapShield
//
//  Created by Adam Share on 5/31/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSReportAnnotationManager.h"
#import "NSDate+Utilities.h"
#import "TSLocationController.h"
#import "TSHeatMapOverlay.h"

#define kSocialRadius 2
#define kSpotCrimeRadius .1

@interface TSReportAnnotationManager ()

@property (strong, nonatomic) NSTimer *socialGetTimer;
@property (strong, nonatomic) NSTimer *spotCrimeGetTimer;
@property (assign, nonatomic) BOOL shouldAddAnnotations;
@property (assign, nonatomic) NSUInteger maxSocialHours;
@property (assign, nonatomic) NSUInteger maxSpotCrimeHours;
@property (assign, nonatomic) BOOL shouldAddHeatMap;

@end

@implementation TSReportAnnotationManager

- (instancetype)initWithMapView:(TSMapView *)mapView
{
    self = [super init];
    if (self) {
        _mapView = mapView;
        _shouldAddAnnotations = YES;
        _maxSocialHours = MAX_HOURS;
        _maxSpotCrimeHours = MAX_HOURS;
    }
    return self;
}

#pragma mark - Timers 

- (void)startSocialTimer {
    
    [self stopSocialTimer];
    
    _socialGetTimer = [NSTimer scheduledTimerWithTimeInterval:20
                                                       target:self
                                                     selector:@selector(getSocialAnnotations:)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)stopSocialTimer {
    
    [_socialGetTimer invalidate];
    _socialGetTimer = nil;
}

- (void)startSpotCrimeTimer {
    
    [self stopSpotCrimeTimer];
    
    _spotCrimeGetTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                       target:self
                                                     selector:@selector(getSpotCrimeAnnotations:)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)stopSpotCrimeTimer {
    
    [_spotCrimeGetTimer invalidate];
    _spotCrimeGetTimer = nil;
}

- (void)getReportsForMapCenter:(CLLocation *)location {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self performSelector:@selector(loadSpotCrimeAndSocialAnnotations:) withObject:location afterDelay:1];
}

- (void)loadSpotCrimeAndSocialAnnotations:(CLLocation *)location {
    
    [self getSpotCrimeAnnotations:location];
    [self getSocialAnnotations:location];
    
    [self startSocialTimer];
    [self startSpotCrimeTimer];
}

- (void)getSpotCrimeAnnotations:(CLLocation *)location {
    
    if (![location isKindOfClass:[CLLocation class]]) {
        location = [[CLLocation alloc] initWithLatitude:_mapView.region.center.latitude
                                              longitude:_mapView.region.center.longitude];
    }
    
    float radius = kSpotCrimeRadius;
    
    if (_mapView.region.span.longitudeDelta > .5) {
        radius = .25;
    }
    
    
    [[TSSpotCrimeAPIClient sharedClient] getSpotCrimeAtLocation:location radiusMiles:radius since:[NSDate dateWithHoursBeforeNow:_maxSpotCrimeHours] maxReturned:500 sortBy:sortByDate order:orderDescending type:0 completion:^(NSArray *crimes) {
        
        [self addSpotCrimes:crimes];
        
        if (crimes.count < 10) {
            [[TSSpotCrimeAPIClient sharedClient] getSpotCrimeAtLocation:location radiusMiles:radius since:[NSDate dateWithDaysBeforeNow:7] maxReturned:50 sortBy:sortByDate order:orderDescending type:0 completion:^(NSArray *crimes) {
                [self addSpotCrimes:crimes];
            }];
        }
    }];
}

- (void)getSocialAnnotations:(CLLocation *)location  {
    
    MKMapRect mRect = _mapView.visibleMapRect;
    MKMapPoint point1 = MKMapPointMake(MKMapRectGetMidX(mRect), MKMapRectGetMaxY(mRect));
    MKMapPoint point2 = MKMapPointMake(MKMapRectGetMidX(mRect), MKMapRectGetMinY(mRect));
    float distanceInMiles = lroundf(MKMetersBetweenMapPoints(point1, point2) * 0.000621371);
    
    if (![location isKindOfClass:[CLLocation class]]) {
        location = [[CLLocation alloc] initWithLatitude:_mapView.region.center.latitude
                                              longitude:_mapView.region.center.longitude];
    }
    
    [[TSJavelinAPIClient sharedClient] getSocialCrimeReports:location radius:distanceInMiles since:[NSDate dateWithHoursBeforeNow:_maxSocialHours] completion:^(NSArray *reports) {
        [self addSocialReports:reports];
    }];
}

#pragma mark - Spot Crime

- (void)addSpotCrimes:(NSArray *)spotCrimes {
    
    if (!spotCrimes) {
        return;
    }
    
    if (!_spotCrimes) {
        _spotCrimes = [[NSMutableArray alloc] initWithCapacity:spotCrimes.count];
    }
    
    spotCrimes = [self createSpotCrimeAnnotations:spotCrimes];
    spotCrimes = [self filterOutOther:spotCrimes];
    
    [self addNewSpotCrimes:spotCrimes];
}

- (void)removeOldSpotCrimes:(NSArray *)spotCrimes {
    
    NSIndexSet *removeIndexSet = [[_spotCrimes copy] indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        TSSpotCrimeAnnotation *oldAnnotation = (TSSpotCrimeAnnotation *)obj;
        
        if ([oldAnnotation.spotCrime.date hoursBeforeDate:[NSDate date]] > _maxSocialHours) {
                return YES;
        }
        
        return NO;
    }];
    
    if (removeIndexSet.count != 0) {
        [_mapView removeAnnotations:[_spotCrimes objectsAtIndexes:removeIndexSet]];
        [_spotCrimes removeObjectsAtIndexes:removeIndexSet];
    }
    
}

- (void)addNewSpotCrimes:(NSArray *)spotCrimes {
    
    NSIndexSet *addIndexSet = [spotCrimes indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        TSSpotCrimeAnnotation *newAnnotation = (TSSpotCrimeAnnotation *)obj;
        
        for (TSSpotCrimeAnnotation *oldAnnotation in [_spotCrimes copy]) {
            if (newAnnotation.spotCrime.cdid == oldAnnotation.spotCrime.cdid) {
                return NO;
            }
        }
        return YES;
    }];
    
    if (addIndexSet.count != 0) {
        NSArray *newSpotCrimes = [spotCrimes objectsAtIndexes:addIndexSet];
        [self addAnnotations:newSpotCrimes];
        [_spotCrimes addObjectsFromArray:newSpotCrimes];
        [self addHeatMapOverlays:newSpotCrimes];
    }
}

- (void)addHeatMapOverlays:(NSArray *)spotCrimes {
    
    if (!_shouldAddHeatMap) {
        return;
    }
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:spotCrimes.count];
    
    for (TSSpotCrimeAnnotation *annotation in spotCrimes) {
        MKCircle *heatMarker = [MKCircle circleWithCenterCoordinate:annotation.coordinate radius:50];
        heatMarker.title = @"heat_marker";
        [mutableArray addObject:heatMarker];
    }
    
    [_mapView addOverlays:mutableArray level:MKOverlayLevelAboveRoads];
    
    if (!_heatMarkers) {
        _heatMarkers = mutableArray;
    }
    else {
        [_heatMarkers addObjectsFromArray:mutableArray];
    }
    
}


- (NSArray *)createSpotCrimeAnnotations:(NSArray *)spotCrimes {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:spotCrimes.count];
    NSMutableArray *oldMutableArray = [[NSMutableArray alloc] initWithCapacity:spotCrimes.count];
    for (TSSpotCrimeLocation *location in spotCrimes) {
        TSSpotCrimeAnnotation *annotation = [[TSSpotCrimeAnnotation alloc] initWithSpotCrime:location];
        
        if ([location.date hoursBeforeDate:[NSDate date]] > _maxSocialHours) {
            [oldMutableArray addObject:annotation];
            continue;
        }
        
//        if (![location.type isEqualToString:[TSSpotCrimeAPIClient spotCrimeTypesToString:other]]) {
            [mutableArray addObject:annotation];
//        }
    }
    
    if (mutableArray.count < 10) {
        [mutableArray addObjectsFromArray:oldMutableArray];
    }
    
    return mutableArray;
}


#pragma mark - Social Reports


- (void)addUserSocialReport:(TSJavelinAPISocialCrimeReport *)report {
    
    TSSpotCrimeAnnotation *annotation = [[TSSpotCrimeAnnotation alloc] initWithSpocialReport:report];
    
    [self addNewSocialReports:@[annotation]];
}

- (void)addSocialReports:(NSArray *)socialReports {
    
    if (!socialReports) {
        return;
    }
    
    socialReports = [self createSocialAnnotations:socialReports];
    
    if (!_socialReports) {
        _socialReports = [[NSMutableArray alloc] initWithArray:socialReports];
        [self addAnnotations:_socialReports];
        
        return;
    }
    
    //Remove old crimes keeping thos still relevant
    [self removeOldSocialReports:socialReports];
    
    //Add new crimes if available
    [self addNewSocialReports:socialReports];
}

- (void)removeUserSocialReport:(TSSpotCrimeAnnotation *)annotation {
    
    [_socialReports removeObject:annotation];
    [_mapView removeAnnotation:annotation];
}

- (void)removeOldSocialReports:(NSArray *)socialReports {
    
    NSIndexSet *removeIndexSet = [[_socialReports copy] indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        TSSpotCrimeAnnotation *oldAnnotation = (TSSpotCrimeAnnotation *)obj;
        
        if ([oldAnnotation.socialReport.creationDate hoursBeforeDate:[NSDate date]] > _maxSocialHours) {
            return YES;
        }
        
        return NO;
    }];
    
    if (removeIndexSet.count != 0) {
        [_mapView removeAnnotations:[_socialReports objectsAtIndexes:removeIndexSet]];
        [_socialReports removeObjectsAtIndexes:removeIndexSet];
    }
}

- (void)addNewSocialReports:(NSArray *)socialReports {
    
    NSIndexSet *addIndexSet = [socialReports indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        TSSpotCrimeAnnotation *newAnnotation = (TSSpotCrimeAnnotation *)obj;
        
        for (TSSpotCrimeAnnotation *oldAnnotation in [_socialReports copy]) {
            if (oldAnnotation.socialReport.identifier == newAnnotation.socialReport.identifier) {
                return NO;
            }
        }
        return YES;
    }];
    
    if (addIndexSet.count != 0) {
        NSArray *newSpotCrimes = [socialReports objectsAtIndexes:addIndexSet];
        [self addAnnotations:newSpotCrimes];
        [_socialReports addObjectsFromArray:newSpotCrimes];
    }
}

- (NSArray *)createSocialAnnotations:(NSArray *)socialReports {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:socialReports.count];
    for (TSJavelinAPISocialCrimeReport *report in socialReports) {
        
        if ([report.creationDate hoursBeforeDate:[NSDate date]] > _maxSocialHours) {
            continue;
        }
        
        TSSpotCrimeAnnotation *annotation = [[TSSpotCrimeAnnotation alloc] initWithSpocialReport:report];
        [mutableArray addObject:annotation];
    }
    
    return mutableArray;
}


#pragma mark - Map Methods

- (void)addAnnotations:(NSArray *)annotations {
    
    if (!_shouldAddAnnotations) {
        return;
    }
    
    [_mapView addClusteredAnnotations:annotations];
    [_mapView.userLocationAnnotationView.superview bringSubviewToFront:_mapView.userLocationAnnotationView];
}

- (void)hideSpotCrimes {
    
    _shouldAddAnnotations = NO;
    
    [self stopSocialTimer];
    [self stopSpotCrimeTimer];
    
    NSMutableArray * array = [[NSMutableArray alloc] initWithArray:_spotCrimes];
    [array addObjectsFromArray:_socialReports];
    [_mapView removeAnnotations:array];
}

- (void)showSpotCrimes {
    
    [self hideSpotCrimes];
    
    _shouldAddAnnotations = YES;
    
    NSMutableArray * array = [[NSMutableArray alloc] initWithArray:_spotCrimes];
    [array addObjectsFromArray:_socialReports];
    [_mapView addClusteredAnnotations:array];
    
    [_mapView.userLocationAnnotationView.superview bringSubviewToFront:_mapView.userLocationAnnotationView];
    
    [self startSocialTimer];
    [self startSpotCrimeTimer];
}

#pragma mark - Handle Other SpotCrime type

- (NSArray *)filterOutOther:(NSArray *)spotCrimes {
    
    NSMutableArray *minusOthers = [[NSMutableArray alloc] initWithArray:spotCrimes];
    
    NSIndexSet *addIndexSet = [spotCrimes indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        TSSpotCrimeAnnotation *newAnnotation = (TSSpotCrimeAnnotation *)obj;
        if ([newAnnotation.spotCrime.type isEqualToString:[TSSpotCrimeAPIClient spotCrimeTypesToString:other]]) {
            for (TSSpotCrimeAnnotation *oldAnnotation in [_spotCrimes copy]) {
                if (newAnnotation.spotCrime.cdid == oldAnnotation.spotCrime.cdid) {
                    return NO;
                }
            }
            return YES;
        }
        
        return NO;
    }];
    
    NSArray *others;
    if (addIndexSet.count != 0) {
        others = [spotCrimes objectsAtIndexes:addIndexSet];
        [minusOthers removeObjectsAtIndexes:addIndexSet];
    }
    
    if (others) {
        [self filterOtherTypesByDescription:others];
    }
    
    return minusOthers;
}

- (void)filterOtherTypesByDescription:(NSArray *)array {
    
    for (TSSpotCrimeAnnotation *annotation in array) {
        [[TSSpotCrimeAPIClient sharedClient] getSpotCrimeDescription:annotation.spotCrime completion:^(TSSpotCrimeLocation *location) {
            annotation.spotCrime = location;
            [annotation.spotCrime setTypeFromDescription];
            annotation.type = annotation.spotCrime.type;
            annotation.title = annotation.type;
            [self addNewSpotCrimes:@[annotation]];
        }];
    }
}


@end
