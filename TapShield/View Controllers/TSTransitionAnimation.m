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
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *inView = [transitionContext containerView];
    UIViewController *toViewController = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [inView addSubview:toViewController.view];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [toViewController.view setFrame:CGRectMake(0, screenRect.size.height, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height)];
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         
                         [toViewController.view setFrame:CGRectMake(0, 0, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
}


@end
