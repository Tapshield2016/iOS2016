//
//  TSJavelinMassNotificationManager.m
//  TapShield
//
//  Created by Adam Share on 5/26/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinMassNotificationManager.h"

static NSString * const TSMassNotificationsViewControllerSavedNotifications = @"TSTSMassNotificationsViewControllerSavedNotifications";

@implementation TSJavelinMassNotificationManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.notifications = [[NSMutableArray alloc] initWithArray:[self unarchiveNotifications]];
    }
    return self;
}

- (void)getNewMassAlerts:(TSJavelinMassNotificationManagerResultBlock)completion {
    
    [[TSJavelinAPIClient sharedClient] getMassAlerts:^(NSArray *massAlerts) {
        [self getRSSFeed:massAlerts completion:completion];
    }];
    
}

- (void)getRSSFeed:(NSArray *)massAlerts completion:(TSJavelinMassNotificationManagerResultBlock)completion {
    
    if ([[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.rssFeed.length) {
        [RSSParser parseRSSFeed:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.rssFeed
                     parameters:nil
                        success:^(RSSChannel *channel) {
                            
                            [self addRSSFeed:channel massAlerts:massAlerts];
                            
                            if (completion) {
                                completion(_notifications);
                            }
                        }
                        failure:^(NSError *error) {
                            [self newNotifications:massAlerts];
                            
                            if (completion) {
                                completion(_notifications);
                            }
                        }];
    }
    else {
        [self newNotifications:massAlerts];
        
        if (completion) {
            completion(_notifications);
        }
    }
}

- (void)newNotifications:(NSArray *)notifications {
    
    _notifications = [[NSMutableArray alloc] initWithArray:notifications];
    [self archiveNotifications];
}

- (void)addRSSFeed:(RSSChannel *)channel massAlerts:(NSArray *)massAlerts {
    
    NSMutableArray *muteableArray = [[NSMutableArray alloc] initWithArray:massAlerts];
    
    for (RSSItem *item in channel.items) {
        
        TSJavelinAPIMassAlert *alert = [[TSJavelinAPIMassAlert alloc] initWithRSSItem:item];
        [muteableArray addObject:alert];
    }
    
    [self newNotifications:[self sortByTimestamp:muteableArray]];
}

- (NSMutableArray *)sortByTimestamp:(NSMutableArray *)array {
    
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    [array sortUsingDescriptors:@[dateSort]];
    
    return array;
}

#pragma mark - Archive Notifications

- (void)archiveNotifications {
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_notifications];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:TSMassNotificationsViewControllerSavedNotifications];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)unarchiveNotifications {
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:TSMassNotificationsViewControllerSavedNotifications];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end
