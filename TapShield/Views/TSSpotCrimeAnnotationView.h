//
//  TSSpotCrimeAnnotationView.h
//  TapShield
//
//  Created by Adam Share on 5/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseAnnotationView.h"

@interface TSSpotCrimeAnnotationView : TSBaseAnnotationView

- (float)alphaForReportDate;

- (void)setImageFromAnnotation:(id<MKAnnotation>)annotation;

@end
