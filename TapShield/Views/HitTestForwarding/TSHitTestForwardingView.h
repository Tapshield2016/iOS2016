//
//  TSHitTestForwardingView.h
//  TapShield
//
//  Created by Adam Share on 3/31/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSHitTestForwardingView : UIView

@property (nonatomic, strong) UIView *sendToView;

@end
