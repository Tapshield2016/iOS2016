//
//  TSUserLocationAnnotation.h
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/CoreAnimation.h>
#import "TSBaseMapAnnotation.h"

@class TSUserAnnotationView;

@interface TSUserLocationAnnotation : TSBaseMapAnnotation 

- (instancetype)initWithLocation:(CLLocation *)location;

@property (nonatomic, weak) TSUserAnnotationView *annotationView;
@property (nonatomic, strong) CLLocation *location;

@end
