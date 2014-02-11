//
//  TSJavelinAlertAMQPMessage.m
//  Javelin
//
//  Created by Ben Boyd on 11/1/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAlertAMQPMessage.h"
#import <resolv.h>
#import "TSJavelinAPIUtilities.h"

@interface TSJavelinAlertAMQPMessage ()

@property (nonatomic, strong) NSString *body;

@end

@implementation TSJavelinAlertAMQPMessage

+ (NSString *)amqpMessageStringFromDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *baseMessageDictionary = [[NSMutableDictionary alloc] initWithCapacity:5];
    baseMessageDictionary[@"id"] = [TSJavelinAPIUtilities uuidString];
    baseMessageDictionary[@"task"] = @"core.tasks.new_alert";
    baseMessageDictionary[@"args"] = @[dictionary];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:baseMessageDictionary options:0 error:&error];
    
    if (error) {
        NSLog(@"Conversion error: %@", error);
    }
    
    TSJavelinAlertAMQPMessage *message = [[TSJavelinAlertAMQPMessage alloc] init];
    NSString *amqpMessageString = [message amqpMessageStringFromData:jsonData];
    
    return amqpMessageString;
}

- (NSString *)amqpMessageStringFromData:(NSData *)data {
    NSData *encodedData = [self encodeData:data];
    NSString *messageString = nil;
    
    if (encodedData) {
        NSError *error;
        NSDictionary *amqpMessageDictionary = [self amqpMessageDictionaryWithBody:encodedData];
        NSData *messageData = [NSJSONSerialization dataWithJSONObject:amqpMessageDictionary options:0 error:&error];
        if (!error) {
            messageString = [[NSString alloc] initWithData:[self encodeData:messageData] encoding:NSUTF8StringEncoding];
        }
    }
    
    return messageString;
}

- (NSDictionary *)amqpMessageDictionaryWithBody:(NSData *)body {
    NSDictionary *message = @{ @"body": [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding],
                               @"headers": [NSNull null],
                               @"content-type": @"application/json",
                               @"properties": @{ @"body_encoding": @"base64",
                                                 @"delivery_info": @{ @"priority": @(0),
                                                                      @"routing_key": @"core.new_alert",
                                                                      @"exchange": @"new_alert"},
                                                 @"delivery_mode": @(2),
                                                 @"delivery_tag": [TSJavelinAPIUtilities uuidString]},
                               @"content-encoding": @"binary"};
    
    return message;
}

- (NSData *)encodeData:(NSData *)data {
    NSData *encodedData = nil;
    NSUInteger dataToEncodeLength = data.length;
    // Last +1 below to accommodate trailing '\0':
    NSUInteger encodedBufferLength = ((dataToEncodeLength + 2) / 3) * 4 + 1;
    char *encodedBuffer = malloc(encodedBufferLength);
    int encodedRealLength = b64_ntop(data.bytes, dataToEncodeLength, encodedBuffer, encodedBufferLength);
    
    if (encodedRealLength >= 0) {
        // In real life, you might not want the nul-termination byte, so you
        // might not want the '+ 1'.
        encodedData = [NSData dataWithBytesNoCopy:encodedBuffer length:encodedRealLength freeWhenDone:YES];
    } else {
        free(encodedBuffer);
    }
    
    return encodedData;
}

@end