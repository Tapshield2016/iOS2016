//
//  TSJavelinAPIEntourageMember.h
//  TapShield
//
//  Created by Adam Share on 4/20/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"
#import "TSJavelinAPIUser.h"
#import <AddressBook/AddressBook.h>
#import "TSJavelinAPIEntourageSession.h"
@class TSEntourageMemberAnnotation;

@interface TSJavelinAPIEntourageMember : TSJavelinAPIBaseModel

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *first;
@property (strong, nonatomic) NSString *last;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *alternateImage;
@property (assign, nonatomic) ABRecordID recordID;

@property (nonatomic, strong) CLLocation *location;

@property (strong, nonatomic) TSJavelinAPIUser *matchedUser;
@property (assign, nonatomic) BOOL alwaysVisible;
@property (assign, nonatomic) BOOL trackRoute;
@property (assign, nonatomic) BOOL notifyArrival;
@property (assign, nonatomic) BOOL notifyNonArrival;
@property (assign, nonatomic) BOOL notifyCalled911;
@property (assign, nonatomic) BOOL notifyYank;

@property (strong, nonatomic) TSJavelinAPIEntourageSession *session;

- (instancetype)initWithPerson:(ABRecordRef)person;
- (NSDictionary *)parametersFromMember;

+ (TSJavelinAPIEntourageMember *)memberFromUser:(TSJavelinAPIUser *)user;

+ (ABRecordRef)contactContainingPhoneNumber:(NSString *)phoneNumber email:(NSString *)email firstName:(NSString *)firstName lastName:(NSString *)lastName;

+ (NSArray *)entourageMembersFromUsers:(NSArray *)arrayOfUsers;

- (BOOL)compareURLAndMerge:(TSJavelinAPIEntourageMember *)member;

+ (NSArray *)sortedMemberArray:(NSArray *)array;

- (BOOL)isEqualToMember:(id)object;

- (void)compareAndMergeMember:(TSJavelinAPIEntourageMember *)member;

- (void)forceMergeMember:(TSJavelinAPIEntourageMember *)member;

@end
