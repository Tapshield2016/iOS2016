//
//  TSRouteOption.h
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSRouteTimeAnnotation.h"

//bubble_time_RT_icon

#define kAnnotationImageDirectionArray @"LT", @"RT", @"LB", @"RB", nil
typedef enum {
    kLeftTop,
    kRightTop,
    kLeftBottom,
    kRightBottom,
} RelativeLocation;

@interface TSRouteOption : NSObject

@property (nonatomic, strong) MKRoute *route;
@property (nonatomic, strong) TSRouteTimeAnnotation *routeTimeAnnotation;

@end
