//
//  TSJavelinAPIAuthenticationResult.h
//  Javelin
//
//  Created by Ben Boyd on 11/5/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSJavelinAPIAuthenticationResult : NSObject

@property (nonatomic, strong) NSString *loginFailureReason;
@property (nonatomic, strong) NSDictionary *responseHeaders;
@property (nonatomic, strong) NSURLResponse *serverResponse;
@property (nonatomic, assign) NSInteger statusCode;

+ (instancetype)authenticationResultFromResponse:(NSURLResponse *)response;

@end
