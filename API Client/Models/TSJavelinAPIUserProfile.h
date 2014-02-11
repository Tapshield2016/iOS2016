//
//  TSJavelinAPIUserProfile.h
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"

@class TSJavelinAPIUser;

@interface TSJavelinAPIUserProfile : TSJavelinAPIBaseModel

@property (nonatomic, strong) TSJavelinAPIUser *user;
@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic, strong) NSString *profileImageURL;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *hairColor;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *race;
@property (nonatomic, strong) NSString *height;
@property (assign) NSUInteger weight;
@property (nonatomic, strong) NSString *knownAllergies;
@property (nonatomic, strong) NSString *medications;
@property (nonatomic, strong) NSString *emergencyContactFirstName;
@property (nonatomic, strong) NSString *emergencyContactLastName;
@property (nonatomic, strong) NSString *emergencyContactPhoneNumber;
@property (nonatomic, strong) NSString *emergencyContactRelationship;

- (NSDictionary *)dictionaryFromAttributes;

+ (NSArray *)genderChoices;
+ (NSArray *)hairColorChoices;
+ (NSArray *)raceChoices;
+ (NSArray *)relationshipChoices;


@end
