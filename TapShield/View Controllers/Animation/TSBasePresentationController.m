

#import "TSBasePresentationController.h"

@implementation TSBasePresentationController

- (instancetype)initWithPresentingViewController:(UIViewController *)presentingViewController presentedViewController:(UIViewController *)presentedViewController
{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if(self)
    {
        
    }
    return self;
}

- (CGRect)frameOfPresentedViewInContainerView
{
    CGRect containerBounds = [[self containerView] bounds];
    
    return containerBounds;
}

- (void)presentationTransitionWillBegin
{
    [super presentationTransitionWillBegin];
    
    [[[self presentedViewController] transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
    } completion:nil];
    
    [UIView animateWithDuration:1.0 animations:^{
        
    }];
}

- (void)containerViewWillLayoutSubviews
{
    
}

- (void)containerViewDidLayoutSubviews
{
    
}

- (void)dismissalTransitionWillBegin
{
    [super dismissalTransitionWillBegin];

    [[[self presentedViewController] transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    } completion:nil];
}


@end
