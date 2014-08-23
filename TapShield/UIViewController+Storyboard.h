//
//  UIViewController+Storyboard.h
//  TapShield
//
//  Created by Adam Share on 8/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Storyboard)

+ (instancetype)instantiateFromStoryboard:(Class)class;

@end
