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

#define kSocialRadius 2
#define kSpotCrimeRadius .25

@interface TSReportAnnotationManager ()

@property (strong, nonatomic) NSTimer *socialGetTimer;
@property (strong, nonatomic) NSTimer *spotCrimeGetTimer;
@property (assign, nonatomic) BOOL shouldAddAnnotations;
@property (assign, nonatomic) NSUInteger maxHours;

@end

@implementation TSReportAnnotationManager

- (instancetype)initWithMapView:(TSMapView *)mapView
{
    self = [super init];
    if (self) {
        _mapView = mapView;
        _shouldAddAnnotations = YES;
        _maxHours = 24;
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

- (void)loadSpotCrimeAndSocialAnnotations:(CLLocation *)location {
    
    [self getSpotCrimeAnnotations:location];
    [self getSocialAnnotations:location];
    
    [self startSocialTimer];
    [self startSpotCrimeTimer];
}

- (void)getSpotCrimeAnnotations:(CLLocation *)location {
    
    if (![location isKindOfClass:[CLLocation class]]) {
        location = [TSLocationController sharedLocationController].location;
    }
    
    [[TSSpotCrimeAPIClient sharedClient] getSpotCrimeAtLocation:location radiusMiles:kSpotCrimeRadius since:[NSDate dateWithHoursBeforeNow:_maxHours] maxReturned:500 sortBy:sortByDistance order:orderAscending type:0 completion:^(NSArray *crimes) {
        [self addSpotCrimes:crimes];
    }];
}

- (void)getSocialAnnotations:(CLLocation *)location  {
    
    if (![location isKindOfClass:[CLLocation class]]) {
        location = [TSLocationController sharedLocationController].location;
    }
    
    [[TSJavelinAPIClient sharedClient] getSocialCrimeReports:location radius:kSocialRadius completion:^(NSArray *reports) {
        [self addSocialReports:reports];
    }];
}

#pragma mark - Spot Crime

- (void)addSpotCrimes:(NSArray *)spotCrimes {
    
    if (!spotCrimes) {
        return;
    }
    
    spotCrimes = [self createSpotCrimeAnnotations:spotCrimes];
    
    if (!_spotCrimes) {
        _spotCrimes = [[NSMutableArray alloc] initWithArray:spotCrimes];
        [self addAnnotations:_spotCrimes];
        
        return;
    }
    
    //Remove old crimes keeping thos still relevant
    [self removeOldSpotCrimes:spotCrimes];
    
    //Add new crimes if available
    [self addNewSpotCrimes:spotCrimes];
}

- (void)removeOldSpotCrimes:(NSArray *)spotCrimes {
    
    NSIndexSet *removeIndexSet = [[_spotCrimes copy] indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        TSSpotCrimeAnnotation *oldAnnotation = (TSSpotCrimeAnnotation *)obj;
        
//        for (TSSpotCrimeAnnotation *newAnnotation in spotCrimes) {
//            if (oldAnnotation.spotCrime.cdid == newAnnotation.spotCrime.cdid) {
//                return NO;
//            }
//        }
//        return YES;
        
        if ([oldAnnotation.spotCrime.date hoursBeforeDate:[NSDate date]] > _maxHours) {
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
    }
}

- (NSArray *)createSpotCrimeAnnotations:(NSArray *)spotCrimes {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:spotCrimes.count];
    for (TSSpotCrimeLocation *location in spotCrimes) {
        TSSpotCrimeAnnotation *annotation = [[TSSpotCrimeAnnotation alloc] initWithSpotCrime:location];
        
        if ([location.date hoursBeforeDate:[NSDate date]] > _maxHours) {
            continue;
        }
        
        if (![location.type isEqualToString:[TSSpotCrimeAPIClient spotCrimeTypesToString:other]]) {
            [mutableArray addObject:annotation];
        }
    }
    
    return mutableArray;
}


#pragma mark - Social Reports


- (void)addUserSocialReport:(TSJavelinAPISocialCrimeReport *)report {
    
    TSSpotCrimeAnnotation *annotation = [[TSSpotCrimeAnnotation alloc] initWithSpocialReport:report];
    
    [_mapView addAnnotation:annotation];
    [_socialReports addObject:annotation];
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

- (void)removeOldSocialReports:(NSArray *)socialReports {
    
    NSIndexSet *removeIndexSet = [[_socialReports copy] indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        TSSpotCrimeAnnotation *oldAnnotation = (TSSpotCrimeAnnotation *)obj;
        
        //        for (TSSpotCrimeAnnotation *newAnnotation in socialReports) {
        //            if (oldAnnotation.socialReport.identifier == newAnnotation.socialReport.identifier) {
        //                return NO;
        //            }
        //        }
        //        return YES;
        
        if ([oldAnnotation.socialReport.creationDate hoursBeforeDate:[NSDate date]] > _maxHours) {
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
        
        if ([report.creationDate hoursBeforeDate:[NSDate date]] > _maxHours) {
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
    [_mapView addAnnotations:annotations];
    [_mapView.userLocationAnnotationView.superview bringSubviewToFront:_mapView.userLocationAnnotationView];
}

- (void)hideSpotCrimes {
    
    _shouldAddAnnotations = NO;
    
    [self stopSocialTimer];
    [self stopSpotCrimeTimer];
    
    [_mapView removeAnnotations:_spotCrimes];
    [_mapView removeAnnotations:_socialReports];
}

- (void)showSpotCrimes {
    
    [self hideSpotCrimes];
    
    _shouldAddAnnotations = YES;
    [_mapView addAnnotations:_spotCrimes];
    [_mapView addAnnotations:_socialReports];
    [_mapView.userLocationAnnotationView.superview bringSubviewToFront:_mapView.userLocationAnnotationView];
    
    [self startSocialTimer];
    [self startSpotCrimeTimer];
}



@end
