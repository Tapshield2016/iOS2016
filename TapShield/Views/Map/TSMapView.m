//
//  TSMapView.m
//  TapShield
//
//  Created by Adam Share on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSMapView.h"
#import "TSUserLocationAnnotation.h"
#import "TSSelectedDestinationAnnotation.h"
#import "TSLocationController.h"
#import "NSDate+Utilities.h"
#import "TSHeatMapOverlay.h"
#import "TSBoundariesOverlay.h"
#import <KVOController/FBKVOController.h>
#import "TSAlertManager.h"

@interface TSMapView ()

@property (strong, nonatomic) FBKVOController *kvoController;
@property (strong, nonatomic) NSArray *regionPolygons;

@end

@implementation TSMapView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.showsBuildings = YES;
        self.showsPointsOfInterest = YES;
        [TSGeofence registerForOpeningHourChanges:self action:@selector(refreshRegionBoundariesOverlay)];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.showsBuildings = YES;
        self.showsPointsOfInterest = YES;
        [TSGeofence registerForOpeningHourChanges:self action:@selector(refreshRegionBoundariesOverlay)];
    }
    return self;
}


#pragma mark - Region

- (void)setRegionAtAppearanceAnimated:(BOOL)animated {
    //will not work if view has not appeared
    
    [[TSLocationController sharedLocationController] latestLocation:^(CLLocation *location) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self zoomToRegionForLocation:location animated:animated];
        }];
    }];
}

- (void)zoomToRegionForLocation:(CLLocation *)location animated:(BOOL)animated {
    
    MKCoordinateRegion region;
    region.center = location.coordinate;
    region.span = MKCoordinateSpanMake(0.006, 0.006);
    region = [self regionThatFits:region];
    [self setRegion:region animated:animated];
}


#pragma mark - Overlays

+ (MKOverlayRenderer *)mapViewPolygonOverlay:(id<MKOverlay>)overlay {
    
    MKPolygon *polygon = (MKPolygon *)overlay;
    TSJavelinAPIAgency *agency = [[TSLocationController sharedLocationController].geofence nearbyAgencyWithID:polygon.title];
    TSJavelinAPIRegion *region = [[TSLocationController sharedLocationController].geofence nearbyAgencyRegionWithID:polygon.subtitle];
    
    TSBoundariesOverlay *renderer = [[TSBoundariesOverlay alloc] initWithPolygon:overlay
                                                                          agency:agency
                                                                          region:region];
    
    return renderer;
}

+ (MKOverlayRenderer *)mapViewCircleOverlay:(id<MKOverlay>)overlay {
    
    
    MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
    
    if ([overlay.title isEqualToString:@"heat_marker"]) {
        circleRenderer.lineWidth = 1.0;
        circleRenderer.strokeColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.2f];
        circleRenderer.fillColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.2f];
        
        return circleRenderer;
    }
    
    UIColor *color = [[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.1f];
    if ([TSJavelinAPIClient sharedClient].isStillActiveAlert && [TSAlertManager sharedManager].type != kAlertTypeChat) {
        color = [[TSColorPalette alertRed] colorWithAlphaComponent:0.1f];
        ((MKCircle *)overlay).title = @"red";
    }
    else {
        ((MKCircle *)overlay).title = nil;
    }
    
    circleRenderer.lineWidth = 1.0;
    circleRenderer.strokeColor = color;
    circleRenderer.fillColor = color;
    
    return circleRenderer;
}

- (void)removeAccuracyCircleOverlay {
    
    [self removeOverlay:_accuracyCircle];
    _accuracyCircle = nil;
}

- (void)updateAccuracyCircleWithLocation:(CLLocation *)location {
    
    if (!location) {
        return;
    }
    
    MKCircle *previousCircle = _accuracyCircle;
    MKCircle *newcircle = [MKCircle circleWithCenterCoordinate:location.coordinate radius:location.horizontalAccuracy];
    
    _accuracyCircle = newcircle;
    [self addOverlay:_accuracyCircle level:MKOverlayLevelAboveRoads];
    
    if (previousCircle) {
        [self removeOverlay:previousCircle];
    }
}

- (void)refreshRegionBoundariesOverlay {
    
#warning Only User Agency
//    [[TSJavelinAPIClient sharedClient] getAgencies:^(NSArray *agencies) {
    TSJavelinAPIAgency *agency = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency;
    if (!agency) {
        return;
    }
    NSArray *agencies = @[agency];
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (TSJavelinAPIAgency *agency in agencies) {
        
        if (!_kvoController) {
            _kvoController = [FBKVOController controllerWithObserver:self];
        }
        [_kvoController observe:agency.theme keyPath:@"mapOverlayLogo" options:NSKeyValueObservingOptionNew block:^(TSMapView *weakSelf, TSJavelinAPITheme *theme, NSDictionary *change) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [weakSelf refreshRegionBoundariesOverlay];
            }];
        }];
        
        NSArray *regionsArray = agency.regions;
        
        if (!regionsArray.count) {
            TSJavelinAPIRegion *region = [[TSJavelinAPIRegion alloc] init];
            region.boundaries = agency.agencyBoundaries;
            region.centerPoint = agency.agencyCenter;
            regionsArray = @[region];
        }
        
        for (TSJavelinAPIRegion *region in regionsArray) {
            MKPolygon *regionPolygon = [self polygonForBoundaries:region.boundaries];
            regionPolygon.title = [NSString stringWithFormat:@"%lu", (unsigned long)agency.identifier];
            if (region.identifier) {
                regionPolygon.subtitle = [NSString stringWithFormat:@"%lu", (unsigned long)region.identifier];
            }
            else {
                regionPolygon.subtitle = nil;
            }
            
            [mutableArray addObject:regionPolygon];
        }
    }
    
    [self removeOverlays:_regionPolygons];
    [self addOverlays:mutableArray level:MKOverlayLevelAboveRoads];
    _regionPolygons = [NSArray arrayWithArray:mutableArray];
    
//    }];
}

- (MKPolygon *)polygonForBoundaries:(NSArray *)regionBoundaries {
    
    CLLocationCoordinate2D *boundaries = calloc(regionBoundaries.count, sizeof(CLLocationCoordinate2D));
    for (int i = 0; i < regionBoundaries.count; i++) {
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(((CLLocation *)regionBoundaries[i]).coordinate.latitude, ((CLLocation *)regionBoundaries[i]).coordinate.longitude);
        boundaries[i] = coordinate;
    }
    
    MKPolygon *geofencePolygon = [MKPolygon polygonWithCoordinates:boundaries count:regionBoundaries.count];
    free(boundaries);
    
    return geofencePolygon;
}



@end
