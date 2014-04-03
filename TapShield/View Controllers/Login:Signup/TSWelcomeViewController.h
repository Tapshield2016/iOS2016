//
//  TSWelcomeViewController.h
//  TapShield
//
//  Created by Adam Share on 3/19/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"
#import "TSGradientSwipeViewController.h"

@interface TSWelcomeViewController : TSBaseViewController
@property (weak, nonatomic) IBOutlet UIImageView *splashLargeLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *smallLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIView *swipeLabelView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

@property (strong, nonatomic) TSGradientSwipeViewController *swipeViewController;

@property (nonatomic) BOOL isFirstTimeViewed;

@end
