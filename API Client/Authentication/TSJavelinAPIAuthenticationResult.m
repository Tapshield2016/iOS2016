//
//  TSJavelinAPIAuthenticationResult.m
//  Javelin
//
//  Created by Ben Boyd on 11/5/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIAuthenticationResult.h"

@implementation TSJavelinAPIAuthenticationResult

+ (instancetype)authenticationResultFromResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

    TSJavelinAPIAuthenticationResult *resultObject = [[TSJavelinAPIAuthenticationResult alloc] init];
    resultObject.responseHeaders = [httpResponse allHeaderFields];
    resultObject.serverResponse = response;
    resultObject.statusCode = [httpResponse statusCode];

    return resultObject;
}

@end
