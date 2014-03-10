//
//  TSBasePageViewController.h
//  TapShield
//
//  Created by Adam Share on 3/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSConstants.h"
#import "TSAppDelegate.h"
#import "TSJavelinAPIClient.h"
#import "TSJavelinAPIAuthenticationManager.h"
#import "TSColorPalette.h"
#import "UIImage+Color.h"
#import "UIView+FirstResponder.h"
#import "TSLocationController.h"
#import "TSTransitionDelegate.h"
#import "TSNumberPadButton.h"

@interface TSBasePageViewController : UIPageViewController

@property (assign, nonatomic) BOOL translucentBackground;
@property (strong, nonatomic) UIToolbar *toolbar;

@end
