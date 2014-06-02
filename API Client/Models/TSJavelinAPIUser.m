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
    _isEmailVerified = [[attributes objectForKey:@"is_active"] boolValue];
    _phoneNumberVerified = [[attributes objectForKey:@"phone_number_verified"] boolValue];
    self.entourageMembers = [attributes valueForKey:@"entourage_members"];
        
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.url forKey:@"url"];
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
    }
    return self;
}

- (TSJavelinAPIUser *)updateWithAttributes:(NSDictionary *)attributes {
    
    _username = [attributes valueForKey:@"username"];
    _email = [attributes valueForKey:@"email"];
    
    if ([attributes[@"agency"] isKindOfClass:[NSDictionary class]]) {
        _agency = [[TSJavelinAPIAgency alloc] initWithAttributes:attributes[@"agency"]];
    }
    
    _phoneNumber = [attributes valueForKey:@"phone_number"];
    _disarmCode = [attributes valueForKey:@"disarm_code"];
    _firstName = [attributes valueForKey:@"first_name"];
    _lastName = [attributes valueForKey:@"last_name"];
    _isEmailVerified = [[attributes objectForKey:@"is_active"] boolValue];
    _phoneNumberVerified = [[attributes objectForKey:@"phone_number_verified"] boolValue];
    self.entourageMembers = [attributes valueForKey:@"entourage_members"];
    
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

@end
