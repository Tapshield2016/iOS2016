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

+ (CGSize)text:(NSString *)text sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

+ (NSString *)removeNonNumericalCharacters:(NSString *)phoneNumber;
+ (NSString *)formatPhoneNumber:(NSString *)rawString;

+ (NSString *)formattedViewableDate:(NSDate *)date;
+ (NSString *)formattedDateTime:(NSDate *)date;
+ (NSString *)formattedStringForTime:(NSTimeInterval)duration;
+ (NSString *)formattedStringForDuration:(NSTimeInterval)duration;
+ (NSString *)formattedDescriptiveStringForDuration:(NSTimeInterval)duration;
+ (NSString *)formattedStringForDistanceInUSStandard:(CLLocationDistance)meters;

+ (NSString *)getTitleForABRecordRef:(ABRecordRef)record;

+ (NSString *)formattedAddressWithoutNameFromMapItem:(MKMapItem *)mapItem;

//distance
+ (double)distanceOfPoint:(MKMapPoint)point toPoly:(MKPolyline *)polyline;
+ (MKMapPoint)closestPoint:(MKMapPoint)point toPoly:(MKPolyline *)polyline;

@end
