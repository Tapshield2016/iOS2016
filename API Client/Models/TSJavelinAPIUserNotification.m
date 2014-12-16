//
//  TSJavelinAPIUserNotification.m
//  TapShield
//
//  Created by Adam Share on 11/24/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIUserNotification.h"
#import "TSJavelinAPIClient.h"
#import "TSJavelinAPIMassAlert.h"
#import "TSJavelinAPIClient.h"
#import "TSJavelinAPIAlert.h"

#define kContentTypeObjectsAndKeys NSStringFromClass([TSJavelinAPIAlert class]), @"alert", NSStringFromClass([TSJavelinAPIChatMessage class]), @"chat message", NSStringFromClass([TSJavelinAPIEntourageMember class]), @"entourage member", NSStringFromClass([TSJavelinAPIEntourageSession class]), @"entourage session", NSStringFromClass([TSJavelinAPIMassAlert class]), @"mass alert", NSStringFromClass([TSJavelinAPINamedLocation class]), @"named location", NSStringFromClass([TSJavelinAPISocialCrimeReport class]), @"social crime report", NSStringFromClass([TSJavelinAPIUser class]), @"user", nil

@implementation TSJavelinAPIUserNotification

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super initWithAttributes:attributes];
    if (!self) {
        return nil;
    }
    
    _title = [attributes nonNullObjectForKey:@"title"];
    _message = [attributes nonNullObjectForKey:@"message"];
    _type = [attributes nonNullObjectForKey:@"type"];
    _read = [[attributes nonNullObjectForKey:@"read"] boolValue];
    
    NSString *type = [attributes nonNullObjectForKey:@"content_type"];
    if (type) {
        NSDictionary *contentTypeDict = [[NSDictionary alloc] initWithObjectsAndKeys:kContentTypeObjectsAndKeys];
        _contentType = [contentTypeDict objectForKey:type];
        _actionObject = [[NSClassFromString(_contentType) alloc] initWithAttributes:[attributes nonNullObjectForKey:@"action_object"]];
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.message forKey:@"message"];
    [encoder encodeObject:self.type forKey:@"type"];
    [encoder encodeBool:self.read forKey:@"read"];
    [encoder encodeObject:self.actionObject forKey:@"action_object"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super initWithCoder:decoder])) {
        //decode properties, other class vars
        self.title = [decoder decodeObjectForKey:@"title"];
        self.message = [decoder decodeObjectForKey:@"message"];
        self.type = [decoder decodeObjectForKey:@"type"];
        self.read = [decoder decodeBoolForKey:@"read"];
        self.actionObject = [decoder decodeObjectForKey:@"action_object"];
    }
    return self;
}

- (TSJavelinAPIAlert *)alert {
    
    if ([_contentType isEqualToString:NSStringFromClass([TSJavelinAPIAlert class])]) {
        return _actionObject;
    }
    
    return nil;
}

- (TSJavelinAPISocialCrimeReport *)crimeReport {
    
    if ([_contentType isEqualToString:NSStringFromClass([TSJavelinAPISocialCrimeReport class])]) {
        return _actionObject;
    }
    
    return nil;
}

- (TSJavelinAPIEntourageMember *)entourageMember {
    
    if ([_contentType isEqualToString:NSStringFromClass([TSJavelinAPIEntourageMember class])]) {
        return _actionObject;
    }
    
    return nil;
}

- (TSJavelinAPIEntourageSession *)entourageSession {
    
    if ([_contentType isEqualToString:NSStringFromClass([TSJavelinAPIEntourageSession class])]) {
        return _actionObject;
    }
    
    return nil;
}

- (TSJavelinAPIMassAlert *)massAlert {
    
    if ([_contentType isEqualToString:NSStringFromClass([TSJavelinAPIMassAlert class])]) {
        return _actionObject;
    }
    
    return nil;
}

- (TSJavelinAPINamedLocation *)namedLocation {
    
    if ([_contentType isEqualToString:NSStringFromClass([TSJavelinAPINamedLocation class])]) {
        return _actionObject;
    }
    
    return nil;
}

- (TSJavelinAPIUser *)user {
    
    if ([_contentType isEqualToString:NSStringFromClass([TSJavelinAPIUser class])]) {
        return _actionObject;
    }
    
    return nil;
}




@end
