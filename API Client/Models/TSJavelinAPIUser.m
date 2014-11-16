//
//  TSJavelinAPIUser.m
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIUser.h"
#import "TSJavelinAPIAgency.h"
#import "TSJavelinAPIEntourageMember.h"
#import "TSJavelinAPIClient.h"
#import "TSLocationController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "GTLPlusPerson.h"

@interface TSJavelinAPIUser ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation TSJavelinAPIUser

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super initWithAttributes:attributes];
    if (!self) {
        return nil;
    }

    _username = [attributes valueForKey:@"username"];
    _email = [attributes valueForKey:@"email"];
    
    if ([attributes[@"agency"] isKindOfClass:[NSDictionary class]]) {
        _agency = [[TSJavelinAPIAgency alloc] initWithAttributes:attributes[@"agency"]];
    }
    else if ([attributes[@"agency"] isKindOfClass:[NSString class]]) {
        _agency = [[TSJavelinAPIAgency alloc] initWithOnlyURLAttribute:attributes forKey:@"agency"];
    }
    _phoneNumber = [attributes valueForKey:@"phone_number"];
    _disarmCode = [attributes valueForKey:@"disarm_code"];
    _firstName = [attributes valueForKey:@"first_name"];
    _lastName = [attributes valueForKey:@"last_name"];
    _isEmailVerified = [[attributes nonNullObjectForKey:@"is_active"] boolValue];
    _phoneNumberVerified = [[attributes nonNullObjectForKey:@"phone_number_verified"] boolValue];
    self.entourageMembers = [attributes nonNullObjectForKey:@"entourage_members"];
    self.secondaryEmails = [attributes nonNullObjectForKey:@"secondary_emails"];
    
    _userProfile = [self unarchiveUserProfile];
    
    if (!_userProfile) {
        _userProfile = [[TSJavelinAPIUserProfile alloc] init];
    }
    
    _apiToken = [attributes nonNullObjectForKey:@"token"];
    
    double lat = [[attributes nonNullObjectForKey:@"latitude"] doubleValue];
    double lon = [[attributes nonNullObjectForKey:@"longitude"] doubleValue];
    if (lat && lon) {
        _location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lon) altitude:[[attributes nonNullObjectForKey:@"altitude"] floatValue]  horizontalAccuracy:[[attributes nonNullObjectForKey:@"accuracy"] floatValue] verticalAccuracy:0 timestamp:[self reformattedTimeStamp:[attributes nonNullObjectForKey:@"location_timestamp"]]];
    }
    
//    if ([attributes nonNullObjectForKey:@"location_timestamp"]) {
//        _locationTimestamp = [self reformattedTimeStamp:[attributes nonNullObjectForKey:@"location_timestamp"]];
//    }
    
    if ([attributes nonNullObjectForKey:@"entourage_session"]) {
        _entourageSession = [[TSJavelinAPIEntourageSession alloc] initWithAttributes:[attributes nonNullObjectForKey:@"entourage_session"]];
    }
        
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:_username forKey:@"username"];
    [encoder encodeObject:_email forKey:@"email"];
    [encoder encodeObject:_agency forKey:@"agency"];
    [encoder encodeObject:_phoneNumber forKey:@"phoneNumber"];
    [encoder encodeObject:_disarmCode forKey:@"disarmCode"];
    [encoder encodeObject:_firstName forKey:@"firstName"];
    [encoder encodeObject:_lastName forKey:@"lastName"];
    [encoder encodeObject:[NSNumber numberWithBool:_isEmailVerified] forKey:@"isVerified"];
    [encoder encodeObject:[NSNumber numberWithBool:_phoneNumberVerified] forKey:@"phone_number_verified"];
    
    if (_apiToken) {
        [encoder encodeObject:_apiToken forKey:@"apiToken"];
    }

    if (_userProfile) {
        [encoder encodeObject:_userProfile forKey:@"userProfile"];
    }
    
    if (_entourageMembers) {
        [encoder encodeObject:_entourageMembers forKey:@"entourage_members"];
    }
    
    if (_secondaryEmails) {
        [encoder encodeObject:_entourageMembers forKey:@"secondary_emails"];
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.url = [decoder decodeObjectForKey:@"url"];
        _username = [decoder decodeObjectForKey:@"username"];
        _email = [decoder decodeObjectForKey:@"email"];
        _agency = [decoder decodeObjectForKey:@"agency"];
        _phoneNumber = [decoder decodeObjectForKey:@"phoneNumber"];
        _disarmCode = [decoder decodeObjectForKey:@"disarmCode"];
        _firstName = [decoder decodeObjectForKey:@"firstName"];
        _lastName = [decoder decodeObjectForKey:@"lastName"];
        _isEmailVerified = [[decoder decodeObjectForKey:@"isVerified"] boolValue];
        _phoneNumberVerified = [[decoder decodeObjectForKey:@"phone_number_verified"] boolValue];
        
        if ([decoder containsValueForKey:@"apiToken"]) {
            _apiToken = [decoder decodeObjectForKey:@"apiToken"];
        }

        if ([decoder containsValueForKey:@"userProfile"]) {
            _userProfile = [decoder decodeObjectForKey:@"userProfile"];
        }
        
        if ([decoder containsValueForKey:@"entourage_members"]) {
            _entourageMembers = [decoder decodeObjectForKey:@"entourage_members"];
        }
        
        if ([decoder containsValueForKey:@"secondary_emails"]) {
            _secondaryEmails = [decoder decodeObjectForKey:@"secondary_emails"];
        }
    }
    return self;
}

- (instancetype)updateWithAttributes:(NSDictionary *)attributes {
    
    _username = [attributes valueForKey:@"username"];
    _email = [attributes valueForKey:@"email"];
    
    if ([[attributes nonNullObjectForKey:@"agency"] isKindOfClass:[NSDictionary class]]) {
        _agency = [[TSJavelinAPIAgency alloc] initWithAttributes:attributes[@"agency"]];
    }
    else if ([attributes[@"agency"] isKindOfClass:[NSString class]]) {
        TSJavelinAPIAgency *agency = [[TSJavelinAPIAgency alloc] initWithOnlyURLAttribute:attributes forKey:@"agency"];
        
        if (agency.identifier != _agency.identifier) {
            _agency = agency;
            [[TSJavelinAPIClient sharedClient] getAgencyForLoggedInUser:nil];
        }
    }
    else if (![attributes nonNullObjectForKey:@"agency"]) {
        _agency = nil;
    }
    
    _phoneNumber = [attributes valueForKey:@"phone_number"];
    _disarmCode = [attributes valueForKey:@"disarm_code"];
    _firstName = [attributes valueForKey:@"first_name"];
    _lastName = [attributes valueForKey:@"last_name"];
    _isEmailVerified = [[attributes nonNullObjectForKey:@"is_active"] boolValue];
    _phoneNumberVerified = [[attributes nonNullObjectForKey:@"phone_number_verified"] boolValue];
    self.entourageMembers = [attributes nonNullObjectForKey:@"entourage_members"];
    self.secondaryEmails = [attributes nonNullObjectForKey:@"secondary_emails"];
    
    if ([attributes nonNullObjectForKey:@"token"]) {
        _apiToken = [attributes nonNullObjectForKey:@"token"];
    }
    
    return self;
}

- (void)setEntourageMembers:(NSArray *)entourageMembers {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:entourageMembers.count];
    for (NSDictionary *dictionary in entourageMembers) {
        TSJavelinAPIEntourageMember *member = [[TSJavelinAPIEntourageMember alloc] initWithAttributes:dictionary];
        [mutableArray addObject:member];
    }
    
    _entourageMembers = mutableArray;
}

- (void)setSecondaryEmails:(NSArray *)secondaryEmails {
    
    if (!secondaryEmails || !secondaryEmails.count) {
        return;
    }
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:secondaryEmails.count];
    for (NSDictionary *dictionary in secondaryEmails) {
        TSJavelinAPIEmail *email = [[TSJavelinAPIEmail alloc] initWithAttributes:dictionary];
        [mutableArray addObject:email];
    }
    
    _secondaryEmails = mutableArray;
}

- (NSDictionary *)parametersForUpdate {
    
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    if (_email) {
        [mutableDictionary setObject:_email forKey:@"email"];
    }
    if (_phoneNumber) {
        [mutableDictionary setObject:_phoneNumber forKey:@"phone_number"];
    }
    if (_disarmCode) {
        [mutableDictionary setObject:_disarmCode forKey:@"disarm_code"];
    }
    if (_firstName) {
        [mutableDictionary setObject:_firstName forKey:@"first_name"];
    }
    if (_lastName) {
        [mutableDictionary setObject:_lastName forKey:@"last_name"];
    }
    if (_agency) {
        [mutableDictionary setObject:_agency.url forKey:@"agency"];
    }
    
    return mutableDictionary;
}

- (NSDictionary *)parametersForRegistration {
    
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    if (_agency.identifier) {
        [mutableDictionary setObject:@(_agency.identifier) forKey:@"agency"];
    }
    if (_email) {
        [mutableDictionary setObject:_email forKey:@"email"];
    }
    if (_password) {
        [mutableDictionary setObject:_password forKey:@"password"];
    }
    if (_phoneNumber) {
        [mutableDictionary setObject:_phoneNumber forKey:@"phone_number"];
    }
    if (_disarmCode) {
        [mutableDictionary setObject:_disarmCode forKey:@"disarm_code"];
    }
    if (_firstName) {
        [mutableDictionary setObject:_firstName forKey:@"first_name"];
    }
    if (_lastName) {
        [mutableDictionary setObject:_lastName forKey:@"last_name"];
    }
    
    return mutableDictionary;
}

- (void)setUserProfile:(TSJavelinAPIUserProfile *)userProfile {
    
    _userProfile = userProfile;
    
    [self archiveUserProfile];
}

- (void)archiveUserProfile {
    
    if (_userProfile) {
        NSString *string = [NSString stringWithFormat:@"%@-profile", _username];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_userProfile];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:string];
    }
}

- (TSJavelinAPIUserProfile *)unarchiveUserProfile {
    
    NSString *string = [NSString stringWithFormat:@"%@-profile", _username];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:string];
    
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return nil;
}

- (BOOL)isAvailableForDomain:(NSString *)emailDomain {
    
    if (!emailDomain) {
        return NO;
    }
    
    emailDomain = [emailDomain stringByReplacingOccurrencesOfString:@"@" withString:@""];
    NSArray *userEmailDomain = [_email componentsSeparatedByString:@"@"];
    
    if ([[userEmailDomain lastObject] rangeOfString:emailDomain].location != NSNotFound) {
        return YES;
    }
    
    for (TSJavelinAPIEmail *email in _secondaryEmails) {
        
        if (email.isActive) {
            userEmailDomain = [email.email componentsSeparatedByString:@"@"];
            
            if ([[userEmailDomain lastObject] rangeOfString:emailDomain].location != NSNotFound) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)canJoinAgency:(TSJavelinAPIAgency *)agency {
    
    if (!agency.requireDomainEmails || [self isAvailableForDomain:agency.domain]) {
        if (_phoneNumberVerified) {
            return YES;
        }
    }
    
    return NO;
}

- (TSJavelinAPIEmail *)hasSecondaryEmail:(NSString *)email {
    
    for (TSJavelinAPIEmail *secondaryEmail in _secondaryEmails) {
        if ([secondaryEmail.email isEqualToString:email]) {
            return secondaryEmail;
        }
    }
    
    return nil;
}

- (BOOL)setSecondaryEmailVerified:(NSString *)email {
    
    for (TSJavelinAPIEmail *secondaryEmail in _secondaryEmails) {
        if ([secondaryEmail.email isEqualToString:email]) {
            secondaryEmail.isActive = YES;
            return YES;
        }
    }
    
    return NO;
}


#pragma mark - Social Login

- (void)updateUserProfileFromFacebook:(NSDictionary<FBGraphUser> *)user {
    
    if (!_userProfile) {
        _userProfile = [[TSJavelinAPIUserProfile alloc] init];
    }
    
    if (user.birthday) {
        _userProfile.birthday = [user.birthday stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    }
    
    if (user.location && !_userProfile.addressDictionary) {
        [[TSLocationController sharedLocationController] geocodeAddressString:user.location.name
                                                         dictionaryCompletion:^(NSDictionary *addressDictionary) {
            
                                                             _userProfile.addressDictionary = addressDictionary;
                                                             [[[TSJavelinAPIClient sharedClient] authenticationManager] archiveLoggedInUser];
                                                         }];
    }
    
    NSString *gender = [user objectForKey:@"gender"];
    if (gender) {
        
        for (int i = 0; i < kGenderLongArray.count; i++) {
            if ([[kGenderLongArray[i] lowercaseString] isEqualToString:[gender lowercaseString]]) {
                _userProfile.gender = i;
            }
        }
    }
    NSString *imageUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large&width=400&height=400", user.objectID];
    [self profileImageFromURL:imageUrl];
}

- (void)updateUserProfileFromGoogle:(GTLPlusPerson *)person {
    
    if (!_userProfile) {
        _userProfile = [[TSJavelinAPIUserProfile alloc] init];
    }
    
    if (person.birthday) {
        _userProfile.birthday = [TSJavelinAPIUserProfile unFormattedBirthday:person.birthday];
    }
    
    NSString *gender = person.gender;
    if (gender) {
        
        for (int i = 0; i < kGenderLongArray.count; i++) {
            if ([[kGenderLongArray[i] lowercaseString] isEqualToString:[gender lowercaseString]]) {
                _userProfile.gender = i;
            }
        }
    }
    
    if (person.image) {
        NSString *imageUrl = person.image.url;
        imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"sz=50" withString:@"sz=400"];
        [self profileImageFromURL:imageUrl];
    }
    
    if (person.placesLived) {
        for (GTLPlusPersonPlacesLivedItem *item in person.placesLived) {
            if (item.primary.boolValue) {
                [[TSLocationController sharedLocationController] geocodeAddressString:item.value dictionaryCompletion:^(NSDictionary *addressDictionary) {
                    _userProfile.addressDictionary = addressDictionary;
                    [[[TSJavelinAPIClient sharedClient] authenticationManager] archiveLoggedInUser];
                }];
            }
        }
    }
}

- (void)updateUserProfileFromLinkedIn:(NSDictionary *)attributes {
    
    static NSString *dateOfBirth = @"dateOfBirth";
    static NSString *dayKey = @"day";
    static NSString *monthKey = @"month";
    static NSString *yearKey = @"year";
    
    
    static NSString *mainAddress = @"mainAddress";
    
    static NSString *phoneNumbers = @"phoneNumbers";
    static NSString *values = @"values";
    
    static NSString *phoneNumber = @"phoneNumber";
    static NSString *phoneType = @"phoneType";
    static NSString *mobile = @"mobile";
    
    static NSString *pictureUrl = @"pictureUrl";
    
    if (!_userProfile) {
        _userProfile = [[TSJavelinAPIUserProfile alloc] init];
    }
    
    NSDictionary *dictionary = [attributes nonNullObjectForKey:dateOfBirth];
    if (dictionary) {
        
        NSString *year = [[dictionary objectForKey:yearKey] stringValue];
        NSString *month = [[dictionary objectForKey:monthKey] stringValue];
        NSString *day = [[dictionary objectForKey:dayKey] stringValue];
        
        if (day.length == 1) {
            day = [NSString stringWithFormat:@"0%@", day];
        }
        if (month.length == 1) {
            month = [NSString stringWithFormat:@"0%@", month];
        }
        _userProfile.birthday = [NSString stringWithFormat:@"%@-%@-%@", month, day, year];
    }
    
    if ([attributes nonNullObjectForKey:mainAddress]) {
        [[TSLocationController sharedLocationController] geocodeAddressString:[attributes nonNullObjectForKey:mainAddress]
                                                         dictionaryCompletion:^(NSDictionary *addressDictionary) {
                                                             _userProfile.addressDictionary = addressDictionary;
                                                             [[[TSJavelinAPIClient sharedClient] authenticationManager] archiveLoggedInUser];
                                                         }];
    }
    
    dictionary = [attributes nonNullObjectForKey:phoneNumbers];
    if (dictionary) {
        NSArray *array = [dictionary objectForKey:values];
        
        for (NSDictionary *dic in array) {
            if ([[dic objectForKey:phoneType] isEqualToString:mobile]) {
                if (!_phoneNumber) {
                    _phoneNumber = [dic objectForKey:phoneNumber];
                    [[[TSJavelinAPIClient sharedClient] authenticationManager] updateLoggedInUser:nil];
                }
            }
        }
    }
    
    if ([attributes objectForKey:pictureUrl]) {
        
        [self profileImageFromURL:[attributes objectForKey:pictureUrl]];
    }
}

- (void)updateUserProfileFromTwitter:(NSDictionary *)attributes {
    
    if (!_userProfile) {
        _userProfile = [[TSJavelinAPIUserProfile alloc] init];
    }
    
    static NSString *defaultProfileImage = @"default_profile_image";
    static NSString *profileImageURL = @"profile_image_url";
    static NSString *location = @"location";
    
    if (![[attributes objectForKey:defaultProfileImage] boolValue]) {
        NSString *imageUrl = [attributes objectForKey:profileImageURL];
        imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
        [self profileImageFromURL:imageUrl];
    }
    
    if ([attributes nonNullObjectForKey:location]) {
        [[TSLocationController sharedLocationController] geocodeAddressString:[attributes nonNullObjectForKey:location]
                                                         dictionaryCompletion:^(NSDictionary *addressDictionary) {
                                                             _userProfile.addressDictionary = addressDictionary;
                                                             [[[TSJavelinAPIClient sharedClient] authenticationManager] archiveLoggedInUser];
                                                         }];
    }
}

- (void)profileImageFromURL:(NSString *)urlPath {
    
    NSURL *url = [NSURL URLWithString:urlPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    _imageView = [[UIImageView alloc] init];
    
    __weak __typeof(self)weakSelf = self;
    [_imageView setImageWithURLRequest:request
                      placeholderImage:nil
                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                   weakSelf.userProfile.profileImage = image;
                                   [[[TSJavelinAPIClient sharedClient] authenticationManager] archiveLoggedInUser];
                               } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                   NSLog(@"%@", error.localizedDescription);
                               }];
}

- (NSString *)firstAndLastName {
    
    if (!_firstName.length || !_lastName.length) {
        if (!_firstName.length && !_lastName.length) {
            return nil;
        }
        else if (!_firstName.length) {
            return _lastName;
        }
        else {
            return _firstName;
        }
    }
    
    return [NSString stringWithFormat:@"%@ %@", _firstName, _lastName];
}

- (void)updateEntourageMember:(TSJavelinAPIEntourageMember *)member {
    
    if (![_entourageMembers containsObject:member]) {
        NSMutableArray *mutable = [[NSMutableArray alloc] initWithArray:_entourageMembers];
        for (TSJavelinAPIEntourageMember *currentMember in _entourageMembers) {
            if ([currentMember isEqual:member]) {
                [mutable removeObject:currentMember];
                [mutable addObject:member];
            }
        }
        
        _entourageMembers = mutable;
    }
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] archiveLoggedInUser];
}

@end
