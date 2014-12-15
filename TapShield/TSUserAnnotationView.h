//
//  TSUserAnnotationView.h
//  TapShield
//
//  Created by Adam Share on 4/3/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseAnnotationView.h"

@interface TSUserAnnotationView : TSBaseAnnotationView

@property (nonatomic, weak) MKMapView *mapView;

- (void)updateAnimatedViewAt:(CLLocation *)location;

- (void)updateAnimatedUserAnnotation;

@end
