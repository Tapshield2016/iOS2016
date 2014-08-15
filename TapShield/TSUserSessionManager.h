//
//  TSUserSessionManager.h
//  TapShield
//
//  Created by Adam Share on 8/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSUserSessionManager : NSObject

+ (instancetype)sharedManager;

- (void)checkForUserAgency;

@end
