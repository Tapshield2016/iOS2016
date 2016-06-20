//
//  TSJavelinMassNotificationManager.h
//  TapShield
//
//  Created by Adam Share on 5/26/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSJavelinAPIClient.h"
#import "TSJavelinPushNotificationManager.h"
#import "TSJavelinAPIMassAlert.h"
#import "RSSParser.h"
#import "RSSItem.h"
#import "RSSChannel.h"


typedef void (^TSJavelinMassNotificationManagerResultBlock)(NSArray *massAlerts);

@interface TSJavelinMassNotificationManager : NSObject

@property (strong, nonatomic) NSMutableArray *notifications;

- (void)getNewMassAlerts:(TSJavelinMassNotificationManagerResultBlock)completion;

@end
