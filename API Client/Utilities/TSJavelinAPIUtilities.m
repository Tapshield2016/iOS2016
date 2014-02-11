//
//  TSJavelinAPIUtilities.m
//  Javelin
//
//  Created by Ben Boyd on 11/14/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIUtilities.h"

@implementation TSJavelinAPIUtilities

+ (NSString *)uuidString {
    // Returns a UUID

    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);

    return uuidStr;
}

@end
