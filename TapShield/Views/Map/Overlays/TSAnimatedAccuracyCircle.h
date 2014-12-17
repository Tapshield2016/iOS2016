//
//  TSMapOverlayCircle.h
//  TapShield
//
//  Created by Adam Share on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface TSAnimatedAccuracyCircle : UIImageView

@property (nonatomic, assign) BOOL isBlueColor;

@property (nonatomic, assign) BOOL annotationAnimating;

//methods to control animations
- (void) startAnimatingWithColor:(UIColor *)color andFrame:(CGRect)frame;
- (void) stopAnimating;

@end
