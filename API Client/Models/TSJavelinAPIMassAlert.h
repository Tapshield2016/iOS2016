//
//  TSJavelinAPIMassAlert.h
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"
#import "RSSItem.h"

@class TSJavelinAPIAgency;
@class TSJavelinAPIUser;

@interface TSJavelinAPIMassAlert : TSJavelinAPIBaseModel

@property (readonly) TSJavelinAPIAgency *agency;
@property (readonly) TSJavelinAPIUser *agencyDispatcher;
@property (readonly) NSString *message;
@property (readonly) NSDate *timeStamp;

- (instancetype)initWithRSSItem:(RSSItem *)item;

/*
 
 "url": "http://127.0.0.1:8000/api/v1/mass-alerts/1/",
 "creation_date": "2013-10-23T01:00:23.206Z",
 "last_modified": "2013-10-23T01:00:23.206Z",
 "agency": "http://127.0.0.1:8000/api/v1/agencies/1/",
 "agency_dispatcher": "http://127.0.0.1:8000/api/v1/users/1/",
 "message": "Test message!"
 
 */

@end
