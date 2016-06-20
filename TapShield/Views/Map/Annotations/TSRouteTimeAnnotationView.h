//
//  TSRouteTimeAnnotationView.h
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseAnnotationView.h"

@interface TSRouteTimeAnnotationView : TSBaseAnnotationView

@property (assign, nonatomic) BOOL isFlipped;

- (void)setupViewForAnnotation:(id<MKAnnotation>)annotation;
- (void)flipViewAwayfromView:(UIView *)view;

@end
