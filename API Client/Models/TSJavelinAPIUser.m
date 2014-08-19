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
    _apiToken = [attributes nonNullObjectForKey:@"token"];
        
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

- (TSJavelinAPIUser *)updateWithAttributes:(NSDictionary *)attributes {
    
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
    
    emailDomain = [emailDomain stringByReplacingOccurrencesOfString:@"@" withString:@""];
    NSArray *userEmailDomain = [_email componentsSeparatedByString:@"@"];
    
    if ([[userEmailDomain lastObject] rangeOfString:emailDomain].location == NSNotFound) {
        return NO;
    }
    
    return YES;
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

@end
