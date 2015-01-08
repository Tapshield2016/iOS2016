//
//  TSPopUpWindow.h
//  TapShield
//
//  Created by Adam Share on 5/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSBaseLabel.h"

@protocol TSPopUpWindowDelegate <NSObject>

@optional
- (void)didDismissWindow:(UIWindow *)window;

@end

@interface TSPopUpWindow : UIWindow

@property (weak, nonatomic) id <TSPopUpWindowDelegate> popUpDelegate;

- (id)initWithView:(UIView *)view;
- (id)initWithMessage:(NSString *)message tapToDismiss:(BOOL)tap;
- (instancetype)initWithActivityIndicator:(NSString *)message;
- (instancetype)initWithRepeatCheckBox:(NSString *)archiveKey title:(NSString *)title message:(NSString *)message;

- (void)show;
- (void)dismiss:(void (^)(BOOL finished))completion;

@end
