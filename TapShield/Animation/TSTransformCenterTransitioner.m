

#import "TSTransformCenterTransitioner.h"
#import "TSBasePresentationController.h"

@implementation TSTransformCenterTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    return [[TSBasePresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (TSTransformCenterAnimatedTransitioning *)animationController
{
    TSTransformCenterAnimatedTransitioning *animationController = [[TSTransformCenterAnimatedTransitioning alloc] init];
    return animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    TSTransformCenterAnimatedTransitioning *animationController = [self animationController];
    [animationController setIsPresentation:YES];
    
    return animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    TSTransformCenterAnimatedTransitioning *animationController = [self animationController];
    [animationController setIsPresentation:NO];
    
    return animationController;
}

@end

@implementation TSTransformCenterAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    if (self.isPresentation) {
        return 0.3;
    }
    
    return 0.5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = [fromVC view];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = [toVC view];
    
    UIView *containerView = [transitionContext containerView];
    
    BOOL isPresentation = [self isPresentation];
    
    if(isPresentation)
    {
        [containerView addSubview:toView];
    }
    
    UIViewController *animatingVC = isPresentation? toVC : fromVC;
    UIView *animatingView = [animatingVC view];
    
    [animatingView setFrame:[transitionContext finalFrameForViewController:animatingVC]];
    
    CGAffineTransform presentedTransform = CGAffineTransformIdentity;
    CGAffineTransform entryTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.001, 0.001), CGAffineTransformMakeRotation(8 * M_PI));
    CGAffineTransform dismissedTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.5, 1.5), CGAffineTransformMakeRotation(8 * M_PI));
    
    [animatingView setTransform:isPresentation ? entryTransform : presentedTransform];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:300.0
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [animatingView setTransform:isPresentation ? presentedTransform : dismissedTransform];
                         
                         if (!isPresentation) {
                             animatingView.alpha = 0;
                         }
                     }
                     completion:^(BOOL finished){
                         if(![self isPresentation])
                         {
                             [fromView removeFromSuperview];
                         }
                         [transitionContext completeTransition:YES];
                     }];
}

@end
