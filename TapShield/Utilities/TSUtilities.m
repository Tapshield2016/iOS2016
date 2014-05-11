//
//  TSUtilities.m
//  TapShield
//
//  Created by Ben Boyd on 2/18/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSUtilities.h"

@implementation TSUtilities

#pragma mark - Frame Size

+ (CGSize)text:(NSString *)text sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
    CGRect frame = [text boundingRectWithSize:size
                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                   attributes:@{NSFontAttributeName:font}
                                      context:nil];
    return frame.size;
}

#pragma mark - String Formatting

+ (NSString *)removeNonNumericalCharacters:(NSString *)phoneNumber {
    
    if (!phoneNumber) {
        return nil;
    }
    
    NSCharacterSet *charactersToRemove = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    return phoneNumber;
}

+ (NSString *)formatPhoneNumber:(NSString *)rawString {
    
    if (!rawString) {
        return nil;
    }
    
    if ([self removeNonNumericalCharacters:rawString].length < 7) {
        return rawString;
    }
    
    NSMutableString *mutableNumber = [NSMutableString stringWithString:[self removeNonNumericalCharacters:rawString]];
    [mutableNumber insertString:@"-" atIndex:6];
    [mutableNumber insertString:@") " atIndex:3];
    [mutableNumber insertString:@"(" atIndex:0];
    return mutableNumber;
}

+ (NSString *)formattedStringForTime:(NSTimeInterval)duration {
    
    if (duration < 0) {
        return @"00:00";
    }
    
    long durationInSeconds = lroundf(duration);
    NSInteger hours = durationInSeconds / 3600;
    NSInteger minutes = (durationInSeconds % 3600) / 60;
    NSInteger seconds = durationInSeconds % 60;
    
    if (hours > 0) {
        return [NSString stringWithFormat:@"%02ld:%02d:%02d", (long)hours, minutes, seconds];
    }
    else {
//        if (minutes == 0) {
//            return [NSString stringWithFormat:@":%02d", seconds];
//        }
        
        return [NSString stringWithFormat:@"%02ld:%02d", (long)minutes, seconds];
    }
}

+ (NSString *)formattedStringForDuration:(NSTimeInterval)duration {
    long durationInSeconds = lroundf(duration);
    NSInteger hours = durationInSeconds / 3600;
    NSInteger minutes = (durationInSeconds % 3600) / 60;
    NSInteger seconds = durationInSeconds % 60;

    if (hours > 0) {
        if (minutes == 0) {
            return [NSString stringWithFormat:@"%lih", (long)hours];
        }
        return [NSString stringWithFormat:@"%lih %limin", (long)hours, (long)minutes];
    }
    else {
        if (minutes == 0) {
            return [NSString stringWithFormat:@"%lisec", (long)seconds];
        }
        
        return [NSString stringWithFormat:@"%limin", (long)minutes];
    }
}

+ (NSString *)formattedDescriptiveStringForDuration:(NSTimeInterval)duration {
    long durationInSeconds = lroundf(duration);
    NSInteger hours = durationInSeconds / 3600;
    NSInteger minutes = (durationInSeconds % 3600) / 60;
    NSInteger seconds = durationInSeconds % 60;
    
    NSString *hourString = @"hours";
    if (hours == 1) {
        hourString = @"hour";
    }
    NSString *minutesString = @"minutes";
    if (minutes == 1) {
        minutesString = @"minute";
    }
    NSString *secondsString = @"seconds";
    if (seconds == 1) {
        secondsString = @"second";
    }
    
    if (hours > 0) {
        if (minutes == 0) {
            return [NSString stringWithFormat:@"%li %@", (long)hours, hourString];
        }
        return [NSString stringWithFormat:@"%li %@ %li %@", (long)hours, hourString, (long)minutes, minutesString];
    }
    else {
        if (minutes == 0) {
            return [NSString stringWithFormat:@"%li %@", (long)seconds, secondsString];
        }
        
        return [NSString stringWithFormat:@"%li %@", (long)minutes, minutesString];
    }
}

+ (NSString *)formattedStringForDistanceInUSStandard:(CLLocationDistance)meters {
    
    long distanceInMiles = lroundf(meters * 0.000621371);
    
    if (distanceInMiles == 1) {
        return [NSString stringWithFormat:@"%i mile", (int)distanceInMiles];
    }
    else if (distanceInMiles == 0) {
        
        long distanceInFeet = (int)lroundf(meters*3.28084);
        
        if (distanceInFeet == 1) {
            return [NSString stringWithFormat:@"%i foot", (int)distanceInFeet];
        }
        return [NSString stringWithFormat:@"%i feet", (int)distanceInFeet];
    }
    
    return [NSString stringWithFormat:@"%i miles", (int)distanceInMiles];
}

+ (NSString *)getTitleForABRecordRef:(ABRecordRef)record {
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonLastNameProperty);
    NSString *organization = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonOrganizationProperty);
    NSString *title = @"";

    if (firstName && !lastName) {
        title = firstName;
    }
    else if (!firstName && lastName) {
        title = lastName;
    }
    else if (firstName && lastName) {
        title = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
    else if (!firstName && !lastName) {
        if (organization) {
            title = organization;
        }
    }
    return title;
}

# pragma mark - Distance Methods

+ (double)distanceOfPoint:(MKMapPoint)point toPoly:(MKPolyline *)polyline {
    
    MKMapPoint pointClosest = pointClosest = [TSUtilities closestPoint:point toPoly:polyline];
    
    return MKMetersBetweenMapPoints(pointClosest, point);
}

+ (MKMapPoint)closestPoint:(MKMapPoint)point toPoly:(MKPolyline *)polyline {
    double distance = MAXFLOAT;
    MKMapPoint returnPoint = MKMapPointMake(0, 0);
    for (int n = 0; n < polyline.pointCount - 1; n++) {
        
        MKMapPoint ptA = polyline.points[n];
        MKMapPoint ptB = polyline.points[n + 1];
        
        double xDelta = ptB.x - ptA.x;
        double yDelta = ptB.y - ptA.y;
        
        if (xDelta == 0.0 && yDelta == 0.0) {
            
            // Points must not be equal
            continue;
        }
        
        double u = ((point.x - ptA.x) * xDelta + (point.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta);
        MKMapPoint pointClosest;
        if (u < 0.0) {
            
            pointClosest = ptA;
        }
        else if (u > 1.0) {
            
            pointClosest = ptB;
        }
        else {
            
            pointClosest = MKMapPointMake(ptA.x + u * xDelta, ptA.y + u * yDelta);
        }
        
        double compareDistance = MKMetersBetweenMapPoints(pointClosest, point);
        if (compareDistance < distance) {
            distance = compareDistance;
            returnPoint = pointClosest;
        }
    }
    
    return returnPoint;
}

+ (NSString *)formattedAddressWithoutNameFromMapItem:(MKMapItem *)mapItem {
    
    NSArray *formattedAddressLines = mapItem.placemark.addressDictionary[@"FormattedAddressLines"];
    NSString *address;
    
    for (NSString *string in formattedAddressLines) {
        
        if ([string isEqualToString:mapItem.name]) {
            continue;
        }
        
        if (!address) {
            address = string;
            continue;
        }
        
        if ([string isEqualToString:mapItem.placemark.country]) {
            continue;
        }
        
        address = [NSString stringWithFormat:@"%@ %@", address, string];
    }
    
    return address;
}

+ (NSString *)formattedViewableDate:(NSDate *)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d MMM yyyy h:mm:ss a"];
    NSString *dateString = [dateFormat stringFromDate:date];
    
    return dateString;
}

+ (NSString *)formattedDateTime:(NSDate *)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yy h:mm a"];
    NSString *dateString = [dateFormat stringFromDate:date];
    
    return dateString;
}


@end
