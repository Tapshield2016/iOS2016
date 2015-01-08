//
//  NSURL+FileType.h
//  TapShield
//
//  Created by Adam Share on 6/4/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (FileType)


- (BOOL)isAudio;
- (BOOL)isVideo;
- (BOOL)isImage;

@end
