//
//  TSJavelinAPIAgency.h
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"
#include <CoreLocation/CoreLocation.h>

@interface TSJavelinAPIAgency : TSJavelinAPIBaseModel

@property (readonly) NSString *name;
@property (readonly) NSString *domain;
@property (readonly) NSString *dispatcherPhoneNumber;
@property (readonly) NSString *dispatcherSecondaryPhoneNumber;
@property (readonly) NSString *dispatcherScheduleStart;
@property (readonly) NSString *dispatcherScheduleEnd;
@property (readonly) NSString *alertCompletedMessage;
@property (readonly) NSArray *agencyBoundaries;
@property (readonly) BOOL requireDomainEmails;
@property (readonly) BOOL displayCommandAlert;
@property (readonly) BOOL showAgencyNameInAppNavbar;


@property (readonly) CLLocationCoordinate2D agencyCenter;

@end
