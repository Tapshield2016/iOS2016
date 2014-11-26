//
//  TSUserNotificationCell.h
//  TapShield
//
//  Created by Adam Share on 11/24/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseTableViewCell.h"
#import "TSJavelinAPIUserNotification.h"

@interface TSUserNotificationCell : TSBaseTableViewCell

@property (strong, nonatomic) TSJavelinAPIUserNotification *notification;

@end
