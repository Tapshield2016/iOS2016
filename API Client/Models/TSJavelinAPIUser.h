//
//  TSJavelinAPIUser.h
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GooglePlus/GooglePlus.h>
#import "TSJavelinAPIBaseModel.h"
#import "TSJavelinAPIUserProfile.h"
#import "TSJavelinAPIEmail.h"
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import "TSJavelinAPIEntourageSession.h"

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
@property (nonatomic, strong) NSMutableDictionary *entourageMembers;
@property (nonatomic, strong) NSArray *usersWhoAddedUser;
@property (nonatomic, strong) NSArray *secondaryEmails;

@property (nonatomic, strong) NSDate *locationTimestamp;
@property (nonatomic, strong) CLLocation *location;

@property (assign) BOOL isEmailVerified;
@property (assign, getter=isPhoneNumberVerified) BOOL phoneNumberVerified;
@property (nonatomic, strong) NSString *apiToken;

@property (strong, nonatomic) TSJavelinAPIEntourageSession *entourageSession;

@property (readonly) NSString *fullName;

- (BOOL)shouldUpdateAlwaysVisibleLocation;
- (BOOL)shouldUpdateTrackingLocation;

- (NSDictionary *)parametersForUpdate;
- (NSDictionary *)parametersForRegistration;

- (void)setEntourageMembersForKeys:(NSArray *)entourageMembers;

- (BOOL)canJoinAgency:(TSJavelinAPIAgency *)agency;
- (BOOL)isAvailableForDomain:(NSString *)emailDomain;
- (TSJavelinAPIEmail *)hasSecondaryEmail:(NSString *)email;
- (BOOL)setSecondaryEmailVerified:(NSString *)email;

- (NSString *)firstAndLastName;

- (void)updateUserProfileFromFacebook:(NSDictionary*)user;
- (void)updateUserProfileFromTwitter:(NSDictionary *)attributes;
- (void)updateUserProfileFromGoogle:(GTLPlusPerson *)person;
- (void)updateUserProfileFromLinkedIn:(NSDictionary *)attributes;

- (void)updateEntourageMember:(id)member;

- (void)setUsersWhoAddedUserWithoutKVO:(NSArray *)usersWhoAddedUser;

@end
