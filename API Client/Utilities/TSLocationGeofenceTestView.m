//
//  TSLocationGeofenceTestView.m
//  TestTapShield
//
//  Created by Adam Share on 12/11/13.
//  Copyright (c) 2013 TapShield. All rights reserved.
//

#import "TSLocationGeofenceTestView.h"
#import "TSAppDelegate.h"
#import "TSGeofence.h"
#import "TSJavelinAPIClient.h"
#import "TSJavelinAPIUser.h"
#import "TSJavelinAPIAgency.h"

@implementation TSLocationGeofenceTestView

+ (void)showDataFromLocation:(CLLocation *)currentLocation {
    
    NSString *isLocationInBoundaries;
    NSString *isDistanceGreaterThanOverhang;
    NSString *willCall911AtStart;
    NSString *willCall911AtEnd;
    NSArray *boundaries = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.agencyBoundaries;
    double distance = [TSGeofence distanceFromPoint:currentLocation toGeofencePolygon:boundaries];

    if ([TSGeofence isLocation:currentLocation insideGeofence:boundaries]) {
        isLocationInBoundaries = @"Yes";
        willCall911AtStart = @"No";
        if (currentLocation.horizontalAccuracy - distance > distance) {
            willCall911AtEnd = @"Yes";
        }
        else {
            willCall911AtEnd = @"No";
        }
    }
    else {
        isLocationInBoundaries = @"No";
        willCall911AtEnd = @"Yes";
        if (currentLocation.horizontalAccuracy - distance > distance) {
            if (currentLocation.horizontalAccuracy > 500) {
                willCall911AtStart = @"No";
            }
            else {
                willCall911AtStart = @"Yes";
            }
        }
        else {
            willCall911AtStart = @"Yes";
        }
    }
    
    if (currentLocation.horizontalAccuracy - distance < distance) {
        isDistanceGreaterThanOverhang = @"Yes";
    }
    else {
        isDistanceGreaterThanOverhang = @"No";
    }
    
    NSString *locationCoordinateString = [NSString stringWithFormat:@"Location\n(%f, %f)", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
    NSString *locationDataString = [NSString stringWithFormat:@"Accuracy = %.1fm\n\nIsWithinBounds = %@\n\nDistanceFromGeofence = %fm\n\nOverhang = %fm\n(Accuracy - Distance)\n\nDistance > Overhang = %@\n\nwillCall911AtStart = %@\n\nwillCall911AtEnd = %@", currentLocation.horizontalAccuracy, isLocationInBoundaries, distance, currentLocation.horizontalAccuracy - distance, isDistanceGreaterThanOverhang, willCall911AtStart, willCall911AtEnd];
    
    UIView *locationDataView = [[UIView alloc] initWithFrame:CGRectMake(20, 100, 280, 300)];
    locationDataView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.85];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 280, 60)];
    titleLabel.text = locationCoordinateString;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    //titleLabel.font = [UIFont fontWithName:FONT_STANDARD size:25];
    titleLabel.numberOfLines = 2;
    titleLabel.textColor = [UIColor whiteColor];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 280, 240)];
    messageLabel.text = locationDataString;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    //messageLabel.font = [UIFont fontWithName:FONT_STANDARD size:15];
    messageLabel.numberOfLines = 20;
    messageLabel.textColor = [UIColor whiteColor];
    
    locationDataView.tag = 101;
    locationDataView.userInteractionEnabled = NO;
    
    TSAppDelegate *appDelegate = (TSAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([appDelegate.window viewWithTag:101]) {
        [[appDelegate.window viewWithTag:101] removeFromSuperview];
    }
    [locationDataView addSubview:titleLabel];
    [locationDataView addSubview:messageLabel];
    [appDelegate.window addSubview:locationDataView];
}



@end
