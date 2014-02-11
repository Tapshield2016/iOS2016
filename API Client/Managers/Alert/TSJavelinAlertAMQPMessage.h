//
//  TSJavelinAlertAMQPMessage.h
//  Javelin
//
//  Created by Ben Boyd on 11/1/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSJavelinAlertAMQPMessage : NSObject

+ (NSString *)amqpMessageStringFromDictionary:(NSDictionary *)dictionary;

@end
