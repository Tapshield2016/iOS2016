//
//  TSTransitionAnimation.m
//  TapShield
//
//  Created by Adam Share on 3/5/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSTransitionAnimation.h"

@implementation TSTransitionAnimation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 1.0f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    if (self.isPresenting) {
        [self executePresentationAnimation:transitionContext];
    }
    else {
        [self executeDismissalAnimation:transitionContext];
    }
}

- (void)executePresentationAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *inView = [transitionContext containerView];
    [inView addSubview:toViewController.view];
    
    CGPoint centerOffScreen = inView.center;
    
    centerOffScreen.y = 2 * inView.bounds.size.height;
    toViewController.view.center = centerOffScreen;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        toViewController.view.center = inView.center;
        
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)executeDismissalAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *inView = [transitionContext containerView];
    [inView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    [UIView animateKeyframesWithDuration:0.5f delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:1.0 animations:^{
            fromViewController.view.transform = CGAffineTransformScale(fromViewController.view.transform, 3, 3);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:1.0 animations:^{
            for (UIView *view in fromViewController.view.subviews) {
                view.alpha = 0.0f;
            }
        }];
        
    } completion:^(BOOL finished) {
        [fromViewController.view removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}


@end
