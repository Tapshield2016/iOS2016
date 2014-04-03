//
//  TSRouteTimeAnnotation.h
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseMapAnnotation.h"

//bubble_time_RT_icon

#define kAnnotationImageDirectionArray @"LT", @"RT", @"LB", @"RB", nil
typedef enum {
    kLeftTop,
    kRightTop,
    kLeftBottom,
    kRightBottom,
} RelativeLocation;

typedef enum {
    kTop = -1,
    kMiddle = 0,
    kBottom = 1,
    kLeft = 1,
    kRight = 2,
    kCenter = 3,
} LocationParts;

@interface TSRouteTimeAnnotation : TSBaseMapAnnotation

@property (nonatomic, assign) RelativeLocation annotationViewDirection;
@property (nonatomic, assign) RelativeLocation travelVectorDirection;
@property (nonatomic, assign) CGPoint viewCenterOffset;
@property (nonatomic, assign) BOOL isInCenter;
@property (nonatomic, assign) BOOL isSelected;

- (void)setImageDirectionRelativeToStartingPoint:(TSBaseMapAnnotation *)start endingPoint:(TSBaseMapAnnotation *)end;
- (void)setImageDirectionRelativeToRouteOptions:(NSArray *)routeOptions;
- (UIImage *)imageForAnnotationViewDirection;


@end
