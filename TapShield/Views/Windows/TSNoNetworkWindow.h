//
//  TSNoNetworkWindow.h
//  TapShield
//
//  Created by Adam Share on 7/15/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSNoNetworkWindow : UIWindow

- (void)show;
- (void)dismiss:(void (^)(BOOL finished))completion;

@end
