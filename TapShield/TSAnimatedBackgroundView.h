//
//  TSAnimatedBackgroundImageView.h
//  TapShield
//
//  Created by Adam Share on 11/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSAnimatedBackgroundView : UIView

- (void)animateRoute;
- (void)stopRouteAnimation;

@property (strong ,nonatomic) CAShapeLayer *pathLayer;

@end
