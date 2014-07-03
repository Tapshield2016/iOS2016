//
//  TSJavelinAPIUser.h
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSJavelinAPIBaseModel.h"
#import "TSJavelinAPIUserProfile.h"

@class TSJavelinAPIGroup;
@class TSJavelinAPIAgency;

@interface TSJavelinAPIUser : TSJavelinAPIBaseModel

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) TSJavelinAPIAgency *agency;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *disarmCode;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, strong) TSJavelinAPIUserProfile *userProfile;
@property (nonatomic, strong) NSArray *entourageMembers;
@property (nonatomic, strong) NSArray *secondaryEmails;

@property (assign) BOOL isEmailVerified;
@property (assign) BOOL phoneNumberVerified;
@property (nonatomic, strong) NSString *apiToken;

- (TSJavelinAPIUser *)updateWithAttributes:(NSDictionary *)attributes;
- (NSDictionary *)parametersForUpdate;
- (NSDictionary *)parametersForRegistration;

@end
