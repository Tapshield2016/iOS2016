//
//  TSGeofence.m
//  TestTapShield
//
//  Created by Adam Share on 12/11/13.
//  Copyright (c) 2013 TapShield. All rights reserved.
//

#import "TSGeofence.h"
#import "TSBaseLabel.h"

NSString * const TSGeofenceUserIsInitiallyWithinBoundariesWithOverhang = @"TSGeofenceUserIsInitiallyWithinBoundariesWithOverhang";
NSString * const TSGeofenceUserIsWithinBoundariesWithOverhang = @"TSGeofenceUserIsWithinBoundariesWithOverhang";
NSString * const TSGeofenceUserIsOutsideBoundariesWithOverhang = @"TSGeofenceUserIsOutsideBoundariesWithOverhang";
NSString * const TSGeofenceUserIsInitiallyOutsideBoundariesWithOverhang = @"TSGeofenceUserIsInitiallyOutsideBoundariesWithOverhang";

NSString * const TSGeofenceUserDidEnterAgency = @"TSGeofenceUserDidEnterAgency";
NSString * const TSGeofenceUserDidLeaveAgency = @"TSGeofenceUserDidLeaveAgency";

@interface TSGeofence ()

@property (strong, nonatomic) UIWindow *window;

@end

@implementation TSGeofence

+ (BOOL)isLocation:(CLLocation *)location insideGeofence:(NSArray *)geofencePolygon {
    
    double currentLocationX = location.coordinate.latitude;
    double currentLocationY = location.coordinate.longitude;
    NSLog(@"x - %.10f, y - %.10f", currentLocationX, currentLocationY);
    
    if (geofencePolygon.count < 3) {
        return YES;
    }
    
    CGMutablePathRef geofencePath = CGPathCreateMutable();
    for (int i = 0; i < geofencePolygon.count; i++) {
        double geofenceX = ((CLLocation *)geofencePolygon[i]).coordinate.latitude;
        double geofenceY = ((CLLocation *)geofencePolygon[i]).coordinate.longitude;
        if (i == 0) {
            CGPathMoveToPoint(geofencePath, NULL, geofenceX, geofenceY);
        }
        else {
            CGPathAddLineToPoint(geofencePath, NULL, geofenceX, geofenceY);
        }
    }
    CGPathCloseSubpath(geofencePath);
    BOOL inside = CGPathContainsPoint(geofencePath, NULL, CGPointMake(currentLocationX, currentLocationY), YES);
    CGPathRelease(geofencePath);
    if (inside) {
        return YES;
    }
    return NO;
}


+ (double) distanceFromPoint:(CLLocation *)location toGeofencePolygon:(NSArray *)geofencePolygon
{
    double x3 = location.coordinate.latitude;
    double y3 = location.coordinate.longitude;
    double shortestDistanceInMeters = 0.0;
    NSLog(@"Your Location: %f,%f", x3, y3);
    if (geofencePolygon.count < 3) {
        return 99999999999;
    }
    
    for (int i = 0; i < geofencePolygon.count; i++) {
        double x1 = ((CLLocation *)geofencePolygon[i]).coordinate.latitude;
        double y1 = ((CLLocation *)geofencePolygon[i]).coordinate.longitude;
        double x2;
        double y2;
        //return to original point to close polygon
        if (((CLLocation *)geofencePolygon[i]).coordinate.latitude == ((CLLocation *)[geofencePolygon lastObject]).coordinate.latitude) {
            x2 = ((CLLocation *)geofencePolygon[0]).coordinate.latitude;
            y2 = ((CLLocation *)geofencePolygon[0]).coordinate.longitude;
        }
        else {
            x2 = ((CLLocation *)geofencePolygon[i+1]).coordinate.latitude;
            y2 = ((CLLocation *)geofencePolygon[i+1]).coordinate.longitude;
        }
        //calculate the percentage of the distance between (x1,y1) and (x2,y2)
        double lineMagnitude = sqrt(pow((x2 - x1), 2.0) + pow((y2 - y1), 2.0));
        double u1 = ((x3 - x1)*(x2 - x1))+((y3 - y1)*(y2 - y1));
        double u =  u1 / (lineMagnitude * lineMagnitude);
        if (lineMagnitude == 0) {
            continue;
        }
        //NSLog(@"u = %f", u);
        //point (x1, y1) is closest
        if (u < 0) {
            u = 0;
        }
        //point (x2, y2) is closest
        else if (u > 1) {
            u = 1;
        }
        //closest point on the line
        double xu = x1 + u * (x2 - x1);
        double yu = y1 + u * (y2 - y1);
        
        //NSLog(@"point: %f,%f", xu, yu);
        
        CLLocation *coordinatePoint = [[CLLocation alloc] initWithLatitude:xu longitude:yu];
        double newDistance = [location distanceFromLocation:coordinatePoint];
        
        if (shortestDistanceInMeters == 0.0) {
            shortestDistanceInMeters = [location distanceFromLocation:coordinatePoint];
            NSLog(@"closest point: %f,%f", xu, yu);
        }
        if (newDistance < shortestDistanceInMeters) {
            shortestDistanceInMeters = newDistance;
            NSLog(@"closest point: %f,%f", xu, yu);
        }
    }
    return shortestDistanceInMeters;
}

+ (BOOL)isWithinBoundariesWithOverhang:(CLLocation *)location agency:(TSJavelinAPIAgency *)agency
{
    if (!location || !agency) {
        return NO;
    }
    
    double metersFromBoundary = [TSGeofence distanceFromPoint:location toGeofencePolygon:agency.agencyBoundaries];
    bool isInsideGeofence = [TSGeofence isLocation:location insideGeofence:agency.agencyBoundaries];
    
    NSLog(@"%fm From Boundary", metersFromBoundary);
    NSLog(@"%fm Accuracy", location.horizontalAccuracy);
    NSLog(@"Accuracy - MetersFromBoundary = %fm", location.horizontalAccuracy - metersFromBoundary);
    
    if (isInsideGeofence) {
        NSLog(@"isInsideGeofence");
        if (metersFromBoundary > location.horizontalAccuracy - metersFromBoundary) {
            NSLog(@"InsideGeofence and (metersFromBoundary < location.horizontalAccuracy - metersFromBoundary)");
            return YES;
        }
    }
//#warning GeoTesting
//        return YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TSGeofenceUserIsOutsideBoundariesWithOverhang
                                                        object:nil];
    
    return NO;
}

+ (BOOL)isInitiallyWithinBoundariesWithOverhang:(CLLocation *)location
{
    
    double metersFromBoundary = [TSGeofence distanceFromPoint:location toGeofencePolygon:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.agencyBoundaries];
    bool isInsideGeofence = [TSGeofence isLocation:location insideGeofence:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.agencyBoundaries];
    
    NSLog(@"%fm From Boundary", metersFromBoundary);
    NSLog(@"%fm Accuracy", location.horizontalAccuracy);
    NSLog(@"Accuracy - MetersFromBoundary = %fm", location.horizontalAccuracy - metersFromBoundary);
    if (isInsideGeofence) {
        return YES;
        NSLog(@"isInsideGeofence");
    }
    if (!isInsideGeofence && metersFromBoundary < location.horizontalAccuracy - metersFromBoundary) {
        NSLog(@"NotInsideGeofence but (metersFromBoundary < location.horizontalAccuracy - metersFromBoundary)");
            return YES;
    }
    NSLog(@"Initially Outside Geofence");
//#warning GeoTesting
//        return YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TSGeofenceUserIsInitiallyOutsideBoundariesWithOverhang
                                                        object:nil];
    
    return NO;
}


#pragma mark - Geofence Proximity

//start here
- (void)updateProximityToAgencies:(CLLocation *)currentLocation {
    
    if (![[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency) {
        return;
    }
    
    if (!_lastAgencyUpdate) {
        [self updateNearbyAgencies:currentLocation];
        return;
    }
   
    
    if ([_lastAgencyUpdate distanceFromLocation:currentLocation] > _distanceToNearestAgencyBoundary) {
        [self updateNearbyAgencies:currentLocation];
    }
}

- (void)updateNearbyAgencies:(CLLocation *)currentLocation {
    
    _nearbyAgencies = @[[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency];
    
    [self checkInsideNearbyAgencies:currentLocation completion:^(TSJavelinAPIAgency *insideAgency) {
        
#warning Nearby Agency Check Off - Using user agency
//        if (!insideAgency && !_nearbyAgencies) {
//            
//            [[TSJavelinAPIClient sharedClient] getAgenciesNearby:currentLocation radius:5.0 completion:^(NSArray *agencies) {
//                _nearbyAgencies = agencies;
//                [self checkInsideNearbyAgencies:currentLocation completion:nil];
//            }];
//        }
    }];
}

- (void)updateDistanceToNearestBoundary:(CLLocation *)currentLocation {
    
    double distance = -1;
    
    if (_nearbyAgencies.count > 0) {
        for (TSJavelinAPIAgency *agency in [_nearbyAgencies copy]) {
            
            if (distance < 0) {
                distance = [TSGeofence distanceFromPoint:currentLocation toGeofencePolygon:agency.agencyBoundaries];
            }
            else if ([TSGeofence distanceFromPoint:currentLocation toGeofencePolygon:agency.agencyBoundaries] < distance) {
                distance = [TSGeofence distanceFromPoint:currentLocation toGeofencePolygon:agency.agencyBoundaries];
            }
        }
    }
    else {
        distance = 1000;
    }
    
    _distanceToNearestAgencyBoundary = distance;
}


- (void)checkInsideNearbyAgencies:(CLLocation *)currentLocation completion:(void(^)(TSJavelinAPIAgency *insideAgency))completion {
    
    _lastAgencyUpdate = currentLocation;
    
    [self updateDistanceToNearestBoundary:currentLocation];
    
    for (TSJavelinAPIAgency *agency in [_nearbyAgencies copy]) {
        
        if ([TSGeofence isWithinBoundariesWithOverhang:currentLocation agency:agency]) {
            self.currentAgency = agency;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TSGeofenceUserDidEnterAgency object:agency userInfo:nil];
            
            if (completion) {
                completion(agency);
            }
            
            return;
        }
    }
    
    if (_currentAgency) {
        _currentAgency = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TSGeofenceUserDidLeaveAgency object:nil userInfo:nil];
    }
    
    if (completion) {
        completion(nil);
    }
}


#pragma mark - Agency Updates

- (void)setCurrentAgency:(TSJavelinAPIAgency *)currentAgency {
    _currentAgency = currentAgency;
    
    if (!_currentAgency.largeLogo) {
        [_currentAgency addObserver:self forKeyPath:@"largeLogo" options: 0  context: NULL];
    }
    if (!_currentAgency.alternateLogo) {
        [_currentAgency addObserver:self forKeyPath:@"alternateLogo" options: 0  context: NULL];
    }
    if (!_currentAgency.smallLogo) {
        [_currentAgency addObserver:self forKeyPath:@"smallLogo" options: 0  context: NULL];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
//    [object removeObserver:self forKeyPath:keyPath];
    if (_currentAgency) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TSGeofenceUserDidEnterAgency object:object userInfo:nil];
    }
}

+ (void)registerForAgencyProximityUpdates:(id)object action:(SEL)selector {
    
    [[NSNotificationCenter defaultCenter] addObserver:object selector:selector name:TSGeofenceUserDidEnterAgency object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:object selector:selector name:TSGeofenceUserDidLeaveAgency object:nil];
}


#pragma mark - Out Of Bounds UI

- (void)showOutsideBoundariesWindow {
    
    [self performSelector:@selector(hideWindow) withObject:nil afterDelay:3.0];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideWindow)];
    
    CGRect frame = CGRectMake(0.0f, 0.0f, 260, 140);
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    _window.alpha = 0.0f;
    [_window addGestureRecognizer:tap];
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.center = _window.center;
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:frame];
    toolbar.barStyle = UIBarStyleBlack;
    [view addSubview:toolbar];
    
    float inset = 10;
    TSBaseLabel *windowMessage = [[TSBaseLabel alloc] initWithFrame:CGRectMake(inset, 0, frame.size.width - inset*2, frame.size.height)];
    windowMessage.numberOfLines = 0;
    windowMessage.backgroundColor = [UIColor clearColor];
    windowMessage.text = [NSString stringWithFormat:@"Chat Unavailable\n\nYou are located outside of the %@ boundaries", [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.name];
    
    if (![[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency) {
        windowMessage.text = @"Chat Unavailable\n\nYou are located outside the boundaries of an organization that uses TapShield";
    }
    
    windowMessage.font = [TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f];
    windowMessage.textColor = [UIColor whiteColor];
    windowMessage.textAlignment = NSTextAlignmentCenter;
    
    [view addSubview:windowMessage];
    
    [_window addSubview:view];
    [_window makeKeyAndVisible];
    
    [UIView animateWithDuration:0.3f animations:^{
        _window.alpha = 1.0f;
        view.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:nil];
}

- (void)hideWindow {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3f animations:^{
            _window.alpha = 0.0f;
        } completion:^(BOOL finished) {
            _window = nil;
        }];
    });
}


@end
