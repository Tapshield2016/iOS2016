//
//  TSUtilities.m
//  TapShield
//
//  Created by Ben Boyd on 2/18/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSUtilities.h"
#import "NSDate+Utilities.h"
#import <AVFoundation/AVFoundation.h>

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

+ (NSString *)formattedStringForTimeWithMs:(NSTimeInterval)duration {
    
    if (duration < 0) {
        return @"00:00.00";
    }
    
    long durationInSeconds = lroundf(duration);
    NSInteger hours = durationInSeconds / 3600;
    NSInteger minutes = (durationInSeconds % 3600) / 60;
    NSInteger seconds = durationInSeconds % 60;
    float milliseconds = duration - floor(duration);
    
    if (hours > 0) {
        return [NSString stringWithFormat:@"%02ld:%02d:%02d", (long)hours, minutes, seconds];
    }
    else {
        //        if (minutes == 0) {
        //            return [NSString stringWithFormat:@":%02d", seconds];
        //        }
        float sec = seconds + milliseconds;
        NSNumberFormatter *numFormatter = [NSNumberFormatter new];
        [numFormatter setMaximumFractionDigits:2];
        [numFormatter setMinimumIntegerDigits:2];
        [numFormatter setMinimumFractionDigits:2];
        return [NSString stringWithFormat:@"%02ld:%@", (long)minutes, [numFormatter stringFromNumber:@(sec)]];
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
    [dateFormat setDateFormat:@"MM/dd/yy h:mm a"];
    NSString *dateString = [dateFormat stringFromDate:date];
    
    return dateString;
}

+ (NSString *)dateDescriptionSinceNow:(NSDate *)date {
    
    NSDate *now = [NSDate date];
    int seconds = abs([date timeIntervalSinceNow]);
    
    if (seconds < 60) {
        
        if (seconds == 1) {
            return [NSString stringWithFormat:@"%i second ago", seconds];
        }
        
        return [NSString stringWithFormat:@"%i seconds ago", seconds];
    }
    
    if ([date minutesBeforeDate:now] < 60) {
        
        if ([date minutesBeforeDate:now] == 1) {
            return [NSString stringWithFormat:@"%i minute ago", [date minutesBeforeDate:now]];
        }
        
        return [NSString stringWithFormat:@"%i minutes ago", [date minutesBeforeDate:now]];
    }
    
    if ([date hoursBeforeDate:now] < 6) {
        
        if ([date hoursBeforeDate:now] == 1) {
            return [NSString stringWithFormat:@"%i hour ago", [date hoursBeforeDate:now]];
        }
        
        return [NSString stringWithFormat:@"%i hours ago", [date hoursBeforeDate:now]];
    }
    
    
    if (date.isToday) {
        return [NSString stringWithFormat:@"%@ today", date.shortTimeString];
    }
    
    if (date.isYesterday) {
        return [NSString stringWithFormat:@"%@ yesterday", date.shortTimeString];
    }
    
    
    return [TSUtilities formattedDateTime:date];
}

+ (NSString *)formattedTime:(NSDate *)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"h:mm a"];
    NSString *dateString = [dateFormat stringFromDate:date];
    
    return dateString;
}

+ (NSString *)relativeDateStringForDate:(NSDate *)date {

    if (date.isToday) {
        return [NSString stringWithFormat:@"%@", [TSUtilities formattedTime:date]];
    }
    
    return [TSUtilities formattedDateTime:date];
}


+ (void)videoThumbnailFromBeginning:(NSURL *)videoUrl completion:(void(^)(UIImage *image))completion {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMake(1, 10);
    [generator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithBytes:&time objCType:@encode(CMTime)]] completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        if (completion) {
            completion([UIImage imageWithCGImage:image]);
        }
    }];
}

+ (void)convertToMP4:(NSString *)videoPath completion:(void(^)(AVAssetExportSessionStatus status, NSString *path))completion {
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetPassthrough];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        videoPath = [NSString stringWithFormat:@"%@/temp-conversion.mp4", [paths objectAtIndex:0]];
        exportSession.outputURL = [NSURL fileURLWithPath:videoPath];
        NSLog(@"videopath of your mp4 file = %@",videoPath);
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        //make sure file doesn't exist already
        [TSUtilities deleteFile:videoPath];
        
        //  CMTime start = CMTimeMakeWithSeconds(1.0, 600);
        //  CMTime duration = CMTimeMakeWithSeconds(3.0, 600);
        //  CMTimeRange range = CMTimeRangeMake(start, duration);
        //   exportSession.timeRange = range;
        //  UNCOMMENT ABOVE LINES FOR CROP VIDEO
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                    
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                    
                    if (completion) {
                        completion([exportSession status], videoPath);
                    }
                    
                    break;
                    
                case AVAssetExportSessionStatusCancelled:
                    
                    NSLog(@"Export canceled");
                    
                    if (completion) {
                        completion([exportSession status], videoPath);
                    }
                    
                    break;
                    
                case AVAssetExportSessionStatusCompleted:
                    
                    NSLog(@"Export Completed");
                    
                    if (completion) {
                        completion([exportSession status], videoPath);
                    }
                    
                    break;
                    
                case AVAssetExportSessionStatusExporting:
                    
                    NSLog(@"Export Exporting");
                    
                    break;
                    
                case AVAssetExportSessionStatusWaiting:
                    
                    NSLog(@"Export Waiting");
                    
                    break;
                    
                default:
                    
                    break;
                    
            }
        }];
        
    }
}

+ (void)deleteFile:(NSString *)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path  error:&error];
    }
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
}

@end
