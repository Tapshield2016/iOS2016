//
//  NSString+HTML.h
//  TapShield
//
//  Created by Adam Share on 5/27/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTML)

- (NSString *)stringByDecodingXMLEntities;
- (NSString *)encodeStringForURLPath;

@end
