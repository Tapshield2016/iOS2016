//
//  TSFaceBookLogin.h
//  TapShield
//
//  Created by Adam Share on 3/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "FBLoginView.h"
#import "TSCircularButton.h"

@interface TSFacebookLogin : FBLoginView

@property (strong, nonatomic) TSCircularButton *circleButton;

- (void)addCircularAnimationWithCircleFrame:(CGRect)frame arcCenter:(CGPoint)center startAngle:(float)startAngle endAngle:(float)endAngle duration:(float)duration;

@end
