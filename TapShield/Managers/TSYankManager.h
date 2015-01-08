//
//  TSYankManager.h
//  TapShield
//
//  Created by Adam Share on 4/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const TSYankManagerSettingAutoEnableYank;
extern NSString * const TSYankManagerDidYankHeadphonesNotification;

typedef void (^TSYankManagerYankEnabled)(BOOL enabled);

@interface TSYankManager : NSObject

+ (instancetype)sharedYankManager;
- (void)enableYank:(TSYankManagerYankEnabled)completion;
- (void)disableYank;

@property (assign, nonatomic) BOOL isEnabled;

@end
