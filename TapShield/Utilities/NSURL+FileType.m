//
//  NSURL+FileType.m
//  TapShield
//
//  Created by Adam Share on 6/4/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "NSURL+FileType.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation NSURL (FileType)


- (CFStringRef)getType:(NSURL *)url {
    
    NSString *file = [url path];
    CFStringRef fileExtension = (__bridge CFStringRef) [file pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    CFStringRef type = kUTTypeURL;
    if (UTTypeConformsTo(fileUTI, kUTTypeImage)) {
        type = kUTTypeImage;
    }
    else if (UTTypeConformsTo(fileUTI, kUTTypeMovie)){
        type = kUTTypeMovie;
    }
    else if (UTTypeConformsTo(fileUTI, kUTTypeVideo)){
        type = kUTTypeMovie;
    }
    else if (UTTypeConformsTo(fileUTI, kUTTypeAudio)){
        type = kUTTypeAudio;
    }
    
    CFRelease(fileUTI);
    return type;
}



- (BOOL)isAudio {
    
    if (UTTypeEqual([self getType:self], kUTTypeAudio)) {
        return YES;
    }
    return NO;
}

- (BOOL)isVideo {
    
    if (UTTypeEqual([self getType:self], kUTTypeMovie)) {
        return YES;
    }
    
    if (UTTypeEqual([self getType:self], kUTTypeVideo)) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isImage {
    
    if (UTTypeEqual([self getType:self], kUTTypeImage)) {
        return YES;
    }
    return NO;
}

@end
