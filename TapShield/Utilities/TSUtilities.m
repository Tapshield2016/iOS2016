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

+ (NSString *)formattedStringForDuration:(NSTimeInterval)duration {
    long durationInSeconds = lroundf(duration);
    NSInteger hours = durationInSeconds / 3600;
    NSInteger minutes = (durationInSeconds % 3600) / 60;
    NSInteger seconds = durationInSeconds % 60;

    if (hours > 0) {
        if (minutes == 0) {
            return [NSString stringWithFormat:@"%lih", (long)hours];
        }
        return [NSString stringWithFormat:@"%lih %imin", (long)hours, minutes];
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
        return [NSString stringWithFormat:@"%li %@ %i %@", (long)hours, hourString, minutes, minutesString];
    }
    else {
        if (minutes == 0) {
            return [NSString stringWithFormat:@"%li %@", (long)seconds, secondsString];
        }
        
        return [NSString stringWithFormat:@"%li %@", (long)minutes, minutesString];
    }
}

+ (NSString *)fromattedStringForDistanceInUSStandard:(CLLocationDistance)meters {
    
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

@end
