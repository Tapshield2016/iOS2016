//
//  TSJavelinAPIAlert.h
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"
#import <CoreLocation/CoreLocation.h>

@class TSJavelinAPIAgency;
@class TSJavelinAPIUser;

@interface TSJavelinAPIAlert : TSJavelinAPIBaseModel

@property (nonatomic, strong) TSJavelinAPIAgency *agency;
@property (nonatomic, strong) TSJavelinAPIUser *agencyDispatcher;
@property (nonatomic, strong) TSJavelinAPIUser *agencyUser;
@property (nonatomic, strong) NSString *locationAddress;
@property (nonatomic, strong) NSString *alertStatus;
@property (nonatomic, assign) NSTimeInterval callLength;
@property (nonatomic, assign) CLLocation *location;


/*
 
 {
 "url": "http://127.0.0.1:8000/api/v1/alerts/3/",
 "creation_date": "2013-10-24T19:39:29.091Z",
 "last_modified": "2013-10-24T19:39:29.091Z",
 "agency": "http://127.0.0.1:8000/api/v1/agencies/1/",
 "agency_user": "http://127.0.0.1:8000/api/v1/users/1/",
 "agency_dispatcher": "http://127.0.0.1:8000/api/v1/users/10/",
 "accepted_time": null,
 "completed_time": null,
 "disarmed_time": null,
 "pending_time": null,
 "location_accuracy": null,
 "location_address": "",
 "location_altitude": null,
 "location_latitude": null,
 "location_longitude": null,
 "status": "P",
 "initiated_by": "E"
 },
 
 */

@end
