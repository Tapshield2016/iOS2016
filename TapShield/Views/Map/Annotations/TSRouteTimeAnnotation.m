//
//  TSRouteTimeAnnotation.m
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRouteTimeAnnotation.h"
#import "TSRouteOption.h"

@implementation TSRouteTimeAnnotation


- (void)setImageDirectionRelativeToStartingPoint:(TSBaseMapAnnotation *)start endingPoint:(TSBaseMapAnnotation *)end {
    
    double yDifference = end.coordinate.latitude - start.coordinate.latitude;
    double xDifference = end.coordinate.longitude - start.coordinate.longitude;
//    float radians = atan2(yDifference, xDifference);
    
    RelativeLocation vectorDirection = 0;
    
    if (xDifference > 0) {
        vectorDirection += kRight;
    }
    else {
        vectorDirection += kLeft;
    }
    
    if (yDifference > 0) {
        vectorDirection += kTop;
    }
    else {
        vectorDirection += kBottom;
    }
    
    _travelVectorDirection = vectorDirection;
    
    NSArray *annotations = @[start, end];
    
    LocationParts xLocation = kMiddle;
    LocationParts yLocation = kMiddle;
    
    for (TSBaseMapAnnotation *annotation in annotations) {
        if (annotation.coordinate.latitude >= self.coordinate.latitude) {
            if (yLocation != kBottom) {
                yLocation += kBottom;
            }
        }
        else if (annotation.coordinate.latitude <= self.coordinate.latitude) {
            if (yLocation != kTop) {
                yLocation += kTop;
            }
        }
    }
    
    if (yLocation == kMiddle) {
        
        _isInCenter = YES;
        
        yLocation = kBottom;
    }
    
    for (TSBaseMapAnnotation *annotation in annotations) {
        if (annotation.coordinate.longitude >= self.coordinate.longitude) {
            if (xLocation != kLeft) {
                xLocation += kLeft;
            }
        }
        else if (annotation.coordinate.longitude <= self.coordinate.longitude) {
            if (xLocation != kRight) {
                xLocation += kRight;
            }
        }
    }
    
    if (xLocation == kCenter) {
        
        if (vectorDirection == kLeftTop || vectorDirection == kRightBottom) {
            
            if (yLocation == kBottom) {
                xLocation = kLeft;
            }
            else {
                xLocation = kRight;
            }
        }
        else {
            if (yLocation != kBottom) {
                xLocation = kLeft;
            }
            else {
                xLocation = kRight;
            }
        }
    }
    else {
        _isInCenter = NO;
    }
    
    _annotationViewDirection = xLocation + yLocation;
}

- (void)setImageDirectionRelativeToRouteOptions:(NSArray *)routeOptions {
    
    if (!_isInCenter) {
        return;
    }
    
    BOOL above = NO;
    BOOL below = NO;
    
    for (TSRouteOption *routeOption in routeOptions) {
        
        if (routeOption.routeTimeAnnotation.coordinate.latitude >= self.coordinate.latitude) {
            below = YES;
        }
        
        if (routeOption.routeTimeAnnotation.coordinate.latitude <= self.coordinate.latitude) {
            above = YES;
        }
        
    }
    
    if (above && below) {
        return;
    }
    else if (below) {
        
        if (_travelVectorDirection == kRightTop || _travelVectorDirection == kLeftBottom) {
            _annotationViewDirection = kLeftTop;
        }
        else if (_travelVectorDirection == kLeftTop || _travelVectorDirection == kRightBottom) {
            _annotationViewDirection = kRightTop;
        }
    }
    else {
        if (_travelVectorDirection == kRightTop || _travelVectorDirection == kLeftBottom) {
            _annotationViewDirection = kRightBottom;
        }
        else if (_travelVectorDirection == kLeftTop || _travelVectorDirection == kRightBottom) {
            _annotationViewDirection = kLeftBottom;
        }
    }
    
}

- (UIImage *)imageForAnnotationViewDirection {
    
    NSString *prefix = @"bubble_time_";
    if (!_isSelected) {
        prefix = @"bubble_time2_";
    }
    
    NSString *imageName = [NSString stringWithFormat:@"%@%@_icon", prefix, [self relativeLocationToString:_annotationViewDirection]];
    UIImage *image = [UIImage imageNamed:imageName];
    
    if (_annotationViewDirection == kLeftBottom) {
        _viewCenterOffset = CGPointMake(image.size.width/2, -image.size.height/2);
    }
    else if (_annotationViewDirection == kRightBottom) {
        _viewCenterOffset = CGPointMake(-image.size.width/2, -image.size.height/2);
    }
    else if (_annotationViewDirection == kLeftTop) {
        _viewCenterOffset = CGPointMake(image.size.width/2, image.size.height/2);
    }
    else if (_annotationViewDirection == kRightTop) {
        _viewCenterOffset = CGPointMake(-image.size.width/2, image.size.height/2);
    }
    
    return image;
}

- (NSString*)relativeLocationToString:(RelativeLocation)enumValue {
    NSArray *orderArray = [[NSArray alloc] initWithObjects:kAnnotationImageDirectionArray];
    return [orderArray objectAtIndex:enumValue];
}



@end
