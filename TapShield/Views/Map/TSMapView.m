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

@interface TSMapView ()

@end

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

#pragma mark - Destination methods

- (void)userSelectedDestination:(MKMapItem *)mapItem forTransportType:(MKDirectionsTransportType)transportType {
    _destinationMapItem = mapItem;
    _destinationTransportType = transportType;
    if (_destinationAnnotation) {
        [self removeAnnotation:_destinationAnnotation];
    }
    
    _destinationAnnotation = [[TSSelectedDestinationAnnotation alloc] initWithCoordinates:_destinationMapItem.placemark.location.coordinate
                                                                                placeName:_destinationMapItem.name
                                                                              description:_destinationMapItem.placemark.addressDictionary[@"Street"]];
    _destinationAnnotation.title = _destinationMapItem.name;

    // Ensure we have a title so callout will always come up
    if (!_destinationAnnotation.title || [_destinationAnnotation.title isEqualToString:@""]) {
        _destinationAnnotation.title = _destinationMapItem.placemark.addressDictionary[@"Street"];
    }
    else {
        _destinationAnnotation.subtitle = _destinationMapItem.placemark.addressDictionary[@"Street"];
    }
    [self addAnnotation:_destinationAnnotation];
}

- (void)centerMapOnSelectedDestination {
    [self showAnnotations:@[_destinationAnnotation] animated:NO];
}

- (void)selectDestinationAnnotation {
    [self selectAnnotation:_destinationAnnotation animated:YES];
}

#pragma mark - Region

- (void)setRegionAtAppearanceAnimated:(BOOL)animated {
    //will not work if view has not appeared
    MKCoordinateRegion region;
    region.center = [TSLocationController sharedLocationController].location.coordinate;
    region.span = MKCoordinateSpanMake(0.006, 0.006);
    region = [self regionThatFits:region];
    [self setRegion:region animated:animated];
    [self getAllGeofenceBoundaries];
}

#pragma mark - Annotation

- (void)adjustAnnotationAlphaForPan {
    
    float fullAlpha = 0.4f;
    float newAlpha = 0.0f;
    
    if (self.region.span.latitudeDelta <= 0.04f) {
        newAlpha = roundf((0.0f + self.region.span.latitudeDelta * 10) * 100)/100;
    }
    else {
        newAlpha = fullAlpha;
        if (self.region.span.latitudeDelta >= 0.05f) {
            newAlpha = roundf((fullAlpha - self.region.span.latitudeDelta * 2) * 100)/100;
        }
    }
    
    if (newAlpha < 0) {
        newAlpha = 0.0f;
    }
    
    TSAgencyAnnotation *annotation;
    if ([[self.annotations lastObject] isKindOfClass:[TSAgencyAnnotation class]]) {
        annotation = [self.annotations lastObject];
    }
    else {
        annotation = [self.annotations firstObject];
    }
    
    if ([self viewForAnnotation:annotation].alpha != newAlpha) {
        for (TSAgencyAnnotation *agency in self.annotations) {
            if ([agency isKindOfClass:[TSAgencyAnnotation class]]) {
                [self viewForAnnotation:agency].alpha = newAlpha;
            }
        }
    }
}


#pragma mark - Overlays

+ (MKOverlayRenderer *)mapViewPolygonOverlay:(id<MKOverlay>)overlay {
    
    MKPolygonRenderer *renderer = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *)overlay];
    renderer.lineWidth = 2.0;
    
    UIColor *color = [TSColorPalette randomColor];
    renderer.strokeColor = [TSColorPalette colorByAdjustingColor:color Alpha:0.75f];
    renderer.fillColor = [TSColorPalette colorByAdjustingColor:color Alpha:0.15f];
    
    return renderer;
}

+ (MKOverlayRenderer *)mapViewCircleOverlay:(id<MKOverlay>)overlay {
    
    MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
    circleRenderer.lineWidth = 1.0;
    circleRenderer.strokeColor = [UIColor colorWithRed:82.0f/255.0f green:183.0f/255.0f blue:232.0f/255.0f alpha:0.1f];
    circleRenderer.fillColor = [UIColor colorWithRed:82.0f/255.0f green:183.0f/255.0f blue:232.0f/255.0f alpha:0.1f];
    
    return circleRenderer;
}


- (void)updateAccuracyCircleWithLocation:(CLLocation *)location {
    
    MKCircle *previousCircle = _accuracyCircle;
    _accuracyCircle = [MKCircle circleWithCenterCoordinate:location.coordinate radius:location.horizontalAccuracy];
    [self addOverlay:_accuracyCircle level:MKOverlayLevelAboveRoads];
    
    [self removeOverlay:previousCircle];
}

- (void)getAllGeofenceBoundaries {
    
    [[TSJavelinAPIClient sharedClient] getAgencies:^(NSArray *agencies) {
        NSMutableArray *mutableGeofenceArray = [[NSMutableArray alloc] init];
        for (TSJavelinAPIAgency *agency in agencies) {
            if (agency.agencyBoundaries) {
                [mutableGeofenceArray addObject:agency.agencyBoundaries];
                
                TSAgencyAnnotation *agencyAnnotation = [[TSAgencyAnnotation alloc] initWithCoordinates:agency.agencyCenter
                                                                                             placeName:agency.name
                                                                                           description:[NSString stringWithFormat:@"%i", agency.identifier]];
                [self addAnnotation:agencyAnnotation];
            }
        }
        self.geofenceArray = mutableGeofenceArray;
    }];
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

#pragma mark Animated Overlay

- (void)addAnimatedOverlayToAnnotation:(id<MKAnnotation>)annotation {
    //get a frame around the annotation
    CLLocation *location = [TSLocationController sharedLocationController].location;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, location.horizontalAccuracy*2, location.horizontalAccuracy*2);
    CGRect rect = [self  convertRegion:region toRectToView:self];
    //set up the animated overlay
    if(!_animatedOverlay){
        _animatedOverlay = [[TSMapOverlayCircle alloc] initWithFrame:rect];
    }
    else{
        [_animatedOverlay setFrame:rect];
    }
    //add to the map and start the animation
    [self addSubview:_animatedOverlay];
    [_animatedOverlay startAnimatingWithColor:[UIColor colorWithRed:82.0f/255.0f green:183.0f/255.0f blue:232.0f/255.0f alpha:0.35f]
                                    andFrame:rect];
    [_animatedOverlay setUserInteractionEnabled:NO];
}

- (void)removeAnimatedOverlay {
    if(_animatedOverlay){
        [_animatedOverlay stopAnimating];
        [_animatedOverlay removeFromSuperview];
    }
}

- (void)resetAnimatedOverlayAt:(CLLocation *)location {
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, location.horizontalAccuracy*2, location.horizontalAccuracy*2);
    CGRect rect = [self  convertRegion:region toRectToView:self];
    //set up the animated overlay
    if(_animatedOverlay){
        [_animatedOverlay setFrame:rect];
    }
    [_animatedOverlay stopAnimating];
    [_animatedOverlay startAnimatingWithColor:[UIColor colorWithRed:82.0f/255.0f green:183.0f/255.0f blue:232.0f/255.0f alpha:0.35f]
                                    andFrame:rect];
}

@end
