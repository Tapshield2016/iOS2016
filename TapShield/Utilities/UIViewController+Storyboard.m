//
//  UIViewController+Storyboard.m
//  TapShield
//
//  Created by Adam Share on 8/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "UIViewController+Storyboard.h"

@implementation UIViewController (Storyboard)

+ (instancetype)instantiateFromStoryboard:(Class)class {
    
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(class)];
}

+ (instancetype)instantiateFromStoryboardID:(NSString *)string {
    
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:string];
}

@end
