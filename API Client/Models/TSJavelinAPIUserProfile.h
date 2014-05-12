//
//  TSJavelinAPIUserProfile.h
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"

#define kGenderLongArray @[@"Not now", @"Male", @"Female"]
#define kGenderShortArray @[@"", @"M", @"F"]

typedef enum {
    kNone,
    kMale,
    kFemale,
}ProfileGender;

#define kHairColorLongArray @[@"Not now", @"Blonde", @"Brown", @"Black", @"Red", @"Bald", @"Gray", @"Other"]
#define kHairColorShortArray @[@"", @"Y", @"BR", @"BL", @"R", @"BA", @"GR", @"O"];

typedef enum {
    kBlonde = 1,
    kBrown,
    kBlack,
    kRed,
    kBald,
    kGray,
    kOtherHairType,
}ProfileHairColor;

#define kRaceLongArray @[@"Not now", @"Black/African Descent", @"White/Caucasian", @"East Indian", @"Asian", @"Latino/Hispanic", @"Middle Eastern", @"Pacific Islander", @"Native American", @"Other"]
#define kRaceShortArray @[@"", @"BA", @"WC", @"EI", @"AS", @"LH", @"ME", @"PI", @"NA", @"O"];

typedef enum {
    kBlackAfricanDescent = 1,
    kWhiteCaucasian,
    kEastIndian,
    kAsian,
    kLatinoHispanic,
    kMiddleEastern,
    kPacificIslander,
    kNativeAmerican,
    kOtherRace,
}ProfileRace;


#define kRelationshipLongArray @[@"Not now", @"Father", @"Mother", @"Spouse", @"Boyfriend", @"Girlfriend", @"Brother", @"Sister", @"Friend", @"Other"]
#define kRelationshipShortArray @[@"", @"F", @"M", @"S", @"BF", @"GF", @"B", @"S", @"FR", @"O"]

typedef enum {
    kFather = 1,
    kMother,
    kSpouse,
    kBoyfriend,
    kGirlfriend,
    kBrother,
    kSister,
    kFriend,
    kOtherRelationship,
}ProfileRelationship;


@class TSJavelinAPIUser;

@interface TSJavelinAPIUserProfile : TSJavelinAPIBaseModel


@property (nonatomic, strong) TSJavelinAPIUser *user;
@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic, strong) NSString *profileImageURL;

//Basic Info
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, assign) ProfileGender gender;

//ContactData
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSDictionary *addressDictionary;

//Appearance
@property (nonatomic, strong) NSString *height;
@property (assign) NSUInteger weight;
@property (nonatomic, assign) ProfileHairColor hairColor;
@property (nonatomic, assign) ProfileRace race;

//Medical
@property (nonatomic, strong) NSString *knownAllergies;
@property (nonatomic, strong) NSString *medications;

//Emergency Contact
@property (nonatomic, strong) NSString *emergencyContactFirstName;
@property (nonatomic, strong) NSString *emergencyContactLastName;
@property (nonatomic, strong) NSString *emergencyContactPhoneNumber;
@property (nonatomic, assign) ProfileRelationship emergencyContactRelationship;

- (NSDictionary *)dictionaryFromAttributes;

+ (NSArray *)genderChoices;
+ (NSArray *)hairColorChoices;
+ (NSArray *)raceChoices;
+ (NSArray *)relationshipChoices;

+ (NSString*)genderToLongString:(ProfileGender)enumValue;
+ (NSString*)genderToShortString:(ProfileGender)enumValue;
+ (int)indexOfShortGenderString:(NSString *)shortString;

+ (NSString*)hairColorToLongString:(ProfileHairColor)enumValue;
+ (NSString*)hairColorToShortString:(ProfileHairColor)enumValue;
+ (int)indexOfShortHairColorString:(NSString *)shortString;

+ (NSString*)raceToLongString:(ProfileRace)enumValue;
+ (NSString*)raceToShortString:(ProfileRace)enumValue;
+ (int)indexOfShortRaceString:(NSString *)shortString;

+ (NSString*)relationshipToLongString:(ProfileRelationship)enumValue;
+ (NSString*)relationshipToShortString:(ProfileRelationship)enumValue;
+ (int)indexOfShortRelationshipString:(NSString *)shortString;


@end
