//
//  TSReportAnnotationManager.h
//  TapShield
//
//  Created by Adam Share on 5/31/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSMapView.h"
#define MAX_HOURS 24

@interface TSReportAnnotationManager : NSObject

@property (weak, nonatomic) TSMapView *mapView;

@property (strong, nonatomic) NSMutableArray *spotCrimes;
@property (strong, nonatomic) NSMutableArray *socialReports;
@property (strong, nonatomic) NSMutableArray *heatMarkers;

+ (instancetype)sharedManager;

- (void)loadSpotCrimeAndSocialAnnotations:(CLLocation *)location;

- (void)getReportsForMapCenter:(CLLocation *)location;

- (void)addUserSocialReport:(TSJavelinAPISocialCrimeReport *)report;

- (void)removeUserSocialReport:(TSSpotCrimeAnnotation *)annotation;

- (void)showSpotCrimes;

- (void)hideSpotCrimes;

- (void)removeOldSpotCrimes;

@end
