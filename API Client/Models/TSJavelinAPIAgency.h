//
//  TSJavelinAPIAgency.h
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"
#import "TSJavelinAPITheme.h"

extern NSString * const TSJavelinAPIAgencyDidFinishSmallLogoDownload;

@interface TSJavelinAPIAgency : TSJavelinAPIBaseModel

@property (readonly) NSString *name;
@property (readonly) NSString *domain;
@property (readonly) NSString *dispatcherPhoneNumber;
@property (readonly) NSString *dispatcherSecondaryPhoneNumber;
@property (readonly) NSString *alertModeName;
@property (readonly) NSString *dispatcherScheduleStart;
@property (readonly) NSString *dispatcherScheduleEnd;
@property (readonly) NSString *alertCompletedMessage;

@property (readonly) NSString *rssFeed;
@property (readonly) NSString *infoUrl;

@property (readonly) NSArray *agencyBoundaries;

@property (readonly) BOOL requireDomainEmails;
@property (readonly) BOOL launchCallToDispatcherOnAlert;
@property (readonly) BOOL displayCommandAlert;
@property (readonly) BOOL showAgencyNameInAppNavbar;

@property (readonly) CLLocationCoordinate2D agencyCenter;

@property (readonly) NSArray *dispatchCenters;
@property (readonly) NSArray *regions;

//Theme
@property (strong, nonatomic) TSJavelinAPITheme *theme;

- (NSArray *)openDispatchCenters;
- (NSDate *)nextOpeningHoursStatusChange;
- (BOOL)domainMatchesEmail:(NSString *)email;

@end
