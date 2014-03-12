//
//  TSMapOverlayCircle.h
//  TapShield
//
//  Created by Adam Share on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface TSMapOverlayCircle : UIImageView

//for use if animating over an MKOverlay. Otherwise set to nil
@property (nonatomic,strong) MKCircle* circle;

//methods to control animations
-(void) startAnimatingWithColor:(UIColor *)color andFrame:(CGRect)frame;
-(void) stopAnimating;

@end
