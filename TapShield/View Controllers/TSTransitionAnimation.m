//
//  TSTransitionAnimation.m
//  TapShield
//
//  Created by Adam Share on 3/5/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSTransitionAnimation.h"
#import "TSDestinationSearchViewController.h"

@implementation TSTransitionAnimation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    if (self.isPresenting) {
        if (self.isTopDownPresentation) {
            [self executeTopDownPresentationAnimation:transitionContext];
        }
        else {
            [self executePresentationAnimation:transitionContext];
        }
    }
    else if (self.isDismissing) {
        
        if (self.isTopDownPresentation) {
            [self executeTopDownDismissalAnimation:transitionContext];
        }
        else {
            [self executeDismissalAnimation:transitionContext];
        }
    }
    else if (self.isPushing) {
        if (self.isSlide) {
            [self executeSlideTransition:transitionContext];
        }
        else {
            [self executePushAnimation:transitionContext];
        }
    }
    else if (self.isPopping) {
        if (self.isSlide) {
            [self executeSlideTransition:transitionContext];
        }
        else {
            [self executePopAnimation:transitionContext];
        }
    }
}

- (void)executeTopDownPresentationAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *inView = [transitionContext containerView];
    [inView addSubview:toViewController.view];
    
    CGPoint centerOffScreen = inView.center;
    centerOffScreen.y -= inView.bounds.size.height;
    toViewController.view.center = centerOffScreen;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        toViewController.view.center = inView.center;
        
    } completion:^(BOOL finished) {
        
//        if ([toViewController isKindOfClass:[UINavigationController class]]) {
//            if ([[(UINavigationController *)toViewController topViewController] isKindOfClass:[TSDestinationSearchViewController class]]) {
//                [(TSDestinationSearchViewController *)[(UINavigationController *)toViewController topViewController] presentationAnimation];
//            }
//        }
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)executeTopDownDismissalAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *inView = [transitionContext containerView];
    
    [inView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGPoint centerOffScreen = inView.center;
        centerOffScreen.y -= inView.bounds.size.height;
        fromViewController.view.center = centerOffScreen;
        
    } completion:^(BOOL finished) {
        [fromViewController.view removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
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

#pragma mark - Push Fade Animation

- (void)executePushAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *inView = [transitionContext containerView];
    [inView addSubview:toViewController.view];
    
    toViewController.view.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        toViewController.view.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)executePopAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *inView = [transitionContext containerView];
    [inView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    [UIView animateKeyframesWithDuration:0.3f delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:1.0 animations:^{
            
            fromViewController.view.alpha = 0.0f;
        }];
        
    } completion:^(BOOL finished) {
        [fromViewController.view removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}


#pragma mark - Push Slide Animation

- (void)executeSlideTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    UIView *containerView = [transitionContext containerView];
    CGFloat duration = 0.3f;
    
    CGRect initialFrame = [transitionContext initialFrameForViewController:fromVC];
    CGRect offscreenRectRight = initialFrame;
    offscreenRectRight.origin.x += CGRectGetWidth(initialFrame);
    CGRect offscreenRectLeft = initialFrame;
    offscreenRectLeft.origin.x -= CGRectGetWidth(initialFrame);
    
    // Presenting
    if (self.isPushing) {
        // Position the view offscreen
        toView.frame = offscreenRectRight;
        [containerView addSubview:toView];
        
        // Animate the view onscreen
        [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations: ^{
            toView.frame = initialFrame;
            fromView.frame = offscreenRectLeft;
        } completion: ^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
    // Dismissing
    else {
        [containerView addSubview:toView];
        [containerView sendSubviewToBack:toView];
        toView.frame = offscreenRectLeft;
        // Animate the view offscreen
        [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations: ^{
            toView.frame = initialFrame;
            fromView.frame = offscreenRectRight;
        } completion: ^(BOOL finished) {
            [fromView removeFromSuperview];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}


@end
