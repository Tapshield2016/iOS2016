//
//  TSTransitionAnimation.h
//  TapShield
//
//  Created by Adam Share on 3/5/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSPushTransitionAnimation : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isPresenting;
@property (nonatomic, assign) BOOL isDismissing;
@property (nonatomic, assign) BOOL isPushing;
@property (nonatomic, assign) BOOL isPopping;

@property (nonatomic, assign) BOOL isTopDownPresentation;
@property (nonatomic, assign) BOOL isBottomUpPresentation;
@property (nonatomic, assign) BOOL isSlide;

@end
