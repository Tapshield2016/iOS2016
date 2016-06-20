//
//  TSJavelinAPIUserNotification.h
//  TapShield
//
//  Created by Adam Share on 11/24/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPITimeStampedModel.h"
#import "TSJavelinAPIClient.h"
#import "TSJavelinAPIMassAlert.h"

@interface TSJavelinAPIUserNotification : TSJavelinAPITimeStampedModel

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *message;

@property (strong, nonatomic) NSString *type;

@property (assign, nonatomic) BOOL read;

@property (strong, nonatomic) id actionObject;

@property (strong, nonatomic) NSString *contentType;

@property (readonly) TSJavelinAPIUser *user;
@property (readonly) TSJavelinAPIEntourageMember *entourageMember;
@property (readonly) TSJavelinAPIEntourageSession *entourageSession;
@property (readonly) TSJavelinAPIAlert *alert;
@property (readonly) TSJavelinAPINamedLocation *namedLocation;
@property (readonly) TSJavelinAPIMassAlert *massAlert;
@property (readonly) TSJavelinAPISocialCrimeReport *crimeReport;


@end
