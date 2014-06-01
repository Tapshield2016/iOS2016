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

@interface TSReportAnnotationManager ()

@property (strong, nonatomic) NSTimer *socialGetTimer;
@property (strong, nonatomic) NSTimer *spotCrimeGetTimer;
@property (assign, nonatomic) BOOL shouldAddAnnotations;

@end

@implementation TSReportAnnotationManager

- (instancetype)initWithMapView:(TSMapView *)mapView
{
    self = [super init];
    if (self) {
        _mapView = mapView;
        _shouldAddAnnotations = YES;
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
    
    [[TSSpotCrimeAPIClient sharedClient] getSpotCrimeAtLocation:location radiusMiles:.25 since:[NSDate dateWithHoursBeforeNow:24] maxReturned:500 sortBy:sortByDistance order:orderAscending type:0 completion:^(NSArray *crimes) {
        self.spotCrimes = crimes;
    }];
}

- (void)getSocialAnnotations:(CLLocation *)location  {
    
    if (![location isKindOfClass:[CLLocation class]]) {
        location = [TSLocationController sharedLocationController].location;
    }
    
    [[TSJavelinAPIClient sharedClient] getSocialCrimeReports:location radius:.25 completion:^(NSArray *reports) {
        self.socialReports = [[NSMutableArray alloc] initWithArray:reports];
    }];
}

#pragma mark - Map Annotation

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

- (void)setSpotCrimes:(NSArray *)spotCrimes {
    
    [_mapView removeAnnotations:_spotCrimes];
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:spotCrimes.count];
    for (TSSpotCrimeLocation *location in spotCrimes) {
        TSSpotCrimeAnnotation *annotation = [[TSSpotCrimeAnnotation alloc] initWithSpotCrime:location];
        if (![location.type isEqualToString:[TSSpotCrimeAPIClient spotCrimeTypesToString:other]]) {
            [mutableArray addObject:annotation];
        }
    }
    
    _spotCrimes = mutableArray;
    
    if (!_shouldAddAnnotations) {
        return;
    }
    [_mapView addAnnotations:mutableArray];
    [_mapView.userLocationAnnotationView.superview bringSubviewToFront:_mapView.userLocationAnnotationView];
}

- (void)setSocialReports:(NSArray *)socialReports {
    
    [_mapView removeAnnotations:_socialReports];
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:socialReports.count];
    for (TSJavelinAPISocialCrimeReport *report in socialReports) {
        
        if ([report.creationDate timeIntervalSinceDate:[NSDate dateWithHoursBeforeNow:24]] < 0) {
            continue;
        }
        
        TSSpotCrimeAnnotation *annotation = [[TSSpotCrimeAnnotation alloc] initWithSpocialReport:report];
        [mutableArray addObject:annotation];
    }
    
    _socialReports = mutableArray;
    
    if (!_shouldAddAnnotations) {
        return;
    }
    
    [_mapView addAnnotations:mutableArray];
    [_mapView.userLocationAnnotationView.superview bringSubviewToFront:_mapView.userLocationAnnotationView];
}

- (void)addSocialReports:(NSArray *)socialReports {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:socialReports.count];
    for (TSJavelinAPISocialCrimeReport *report in socialReports) {
        TSSpotCrimeAnnotation *annotation = [[TSSpotCrimeAnnotation alloc] initWithSpocialReport:report];
        [mutableArray addObject:annotation];
    }
    
    [_socialReports addObjectsFromArray:mutableArray];
    
    [_mapView addAnnotations:mutableArray];
    [_mapView.userLocationAnnotationView.superview bringSubviewToFront:_mapView.userLocationAnnotationView];
}




@end
