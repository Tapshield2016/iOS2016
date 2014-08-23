//
//  TSNavigationDelegate.h
//  TapShield
//
//  Created by Adam Share on 8/19/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSNavigationDelegate : NSObject <UINavigationBarDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

- (void)customizeRegistrationNavigationController:(UINavigationController *)navigationController;

@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UIImageView *progressImageView;
@property (nonatomic, strong) UIBarButtonItem *nextButton;

@property (nonatomic, strong) NSArray *registrationViewControllers;

@end
