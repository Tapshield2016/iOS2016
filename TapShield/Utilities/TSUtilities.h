//
//  TSUtilities.h
//  TapShield
//
//  Created by Ben Boyd on 2/18/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MapKit/MapKit.h>

@interface TSUtilities : NSObject

+ (NSString *)formattedStringForDuration:(NSTimeInterval)duration;
+ (NSString *)getTitleForABRecordRef:(ABRecordRef)record;

//distance
+ (double)distanceOfPoint:(MKMapPoint)point toPoly:(MKPolyline *)polyline;
+ (MKMapPoint)closestPoint:(MKMapPoint)point toPoly:(MKPolyline *)polyline;

@end
