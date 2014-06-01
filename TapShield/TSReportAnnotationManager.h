//
//  TSReportAnnotationManager.h
//  TapShield
//
//  Created by Adam Share on 5/31/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSMapView.h"

@interface TSReportAnnotationManager : NSObject

@property (weak, nonatomic) TSMapView *mapView;

@property (strong, nonatomic) NSArray *spotCrimes;
@property (strong, nonatomic) NSMutableArray *socialReports;

- (instancetype)initWithMapView:(TSMapView *)mapView;

- (void)loadSpotCrimeAndSocialAnnotations:(CLLocation *)location;

- (void)addSocialReports:(NSArray *)socialReports;

- (void)showSpotCrimes;

- (void)hideSpotCrimes;

@end
