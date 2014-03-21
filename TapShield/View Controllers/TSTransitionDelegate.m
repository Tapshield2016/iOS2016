//
//  TSTransitionDelegate.m
//  TapShield
//
//  Created by Adam Share on 3/5/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSTransitionDelegate.h"

@implementation TSTransitionDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    TSTransitionAnimation *controller = [[TSTransitionAnimation alloc]init];
    controller.isPresenting = YES;
    return controller;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {

    TSTransitionAnimation *controller = [[TSTransitionAnimation alloc]init];
    controller.isDismissing = YES;
    return controller;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

#pragma mark - UINavigationControllerDelegate

/*
 Called when pushing/popping a view controller on a navigation controller that has a delegate
 */
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    id<UIViewControllerAnimatedTransitioning> animationController;
    
    // Fade In - Push
    if (operation == UINavigationControllerOperationPush) {
        TSTransitionAnimation *animator = [[TSTransitionAnimation alloc] init];
        animator.isPushing = YES;
        animationController = animator;
    }
    // Fade Out - Pop
    else if (operation == UINavigationControllerOperationPop) {
        TSTransitionAnimation *animator = [[TSTransitionAnimation alloc] init];
        animator.isPopping = YES;
        animationController = animator;
    }
    
    return animationController;
}

@end
