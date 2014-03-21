//
//  TSAnimatedView.h
//  TapShield
//
//  Created by Adam Share on 3/20/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSAnimatedView : UIView


- (void)addCircularAnimationWithCircleFrame:(CGRect)frame arcCenter:(CGPoint)center startAngle:(float)startAngle endAngle:(float)endAngle duration:(float)duration;

@end
