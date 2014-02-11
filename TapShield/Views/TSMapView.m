//
//  TSMapView.m
//  TapShield
//
//  Created by Adam Share on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSMapView.h"

@implementation TSMapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.showsBuildings = YES;
        self.showsPointsOfInterest = YES;
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.showsBuildings = YES;
        self.showsPointsOfInterest = YES;
        //[self setShowsUserLocation:YES];
    }
    return self;
}

- (void)setGeofenceArray:(NSArray *)geofenceArray {
    _geofenceArray = geofenceArray;
    
    for (NSArray *coordinateArray in geofenceArray) {
        
        CLLocationCoordinate2D *boundaries = calloc(coordinateArray.count, sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < coordinateArray.count; i++) {
            
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(((CLLocation *)coordinateArray[i]).coordinate.latitude, ((CLLocation *)coordinateArray[i]).coordinate.longitude);
                boundaries[i] = coordinate;
        }
        
        MKPolygon *geofencePolygon = [MKPolygon polygonWithCoordinates:boundaries count:coordinateArray.count];
        [self addOverlay:geofencePolygon level:MKOverlayLevelAboveRoads];
    }
}

- (void)setInitialLocation:(CLLocation *)initialLocation {
    _initialLocation = initialLocation;
    [self setRegionAtAppearance];
}


- (void)setRegionAtAppearance {
    //will not work if view has not appeared
    MKCoordinateRegion region;
    region.center = _initialLocation.coordinate;
    region.span = MKCoordinateSpanMake(0.006, 0.006);
    region = [self regionThatFits:region];
    [self setRegion:region animated:YES];
}

+ (MKOverlayRenderer *)mapViewPolygonOverlay:(id<MKOverlay>)overlay {
    
    MKPolygonRenderer *renderer = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *)overlay];
    renderer.lineWidth = 2.0;
    renderer.strokeColor = [UIColor colorWithRed:49.0f/255.0f green:59.0f/255.0f blue:92.0f/255.0f alpha:0.75f];
    renderer.fillColor = [UIColor colorWithRed:49.0f/255.0f green:59.0f/255.0f blue:92.0f/255.0f alpha:0.35f];
    
    return renderer;
}

+ (MKOverlayRenderer *)mapViewCircleOverlay:(id<MKOverlay>)overlay {
    
    MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
    circleRenderer.lineWidth = 1.0;
    circleRenderer.strokeColor = [UIColor colorWithRed:82.0f/255.0f green:183.0f/255.0f blue:232.0f/255.0f alpha:0.35f];
    circleRenderer.fillColor = [UIColor colorWithRed:82.0f/255.0f green:183.0f/255.0f blue:232.0f/255.0f alpha:0.35f];
    
    return circleRenderer;
}

- (void)updateAccuracyCircleWithLocation:(CLLocation *)location {
    
    MKCircle *previousCircle = _accuracyCircle;
    _accuracyCircle = [MKCircle circleWithCenterCoordinate:location.coordinate radius:location.horizontalAccuracy];
    [self addOverlay:_accuracyCircle level:MKOverlayLevelAboveRoads];
    
    [self removeOverlay:previousCircle];
}

@end
