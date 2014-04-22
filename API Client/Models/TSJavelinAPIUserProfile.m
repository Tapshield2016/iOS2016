//
//  TSJavelinAPIUserProfile.m
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIUserProfile.h"
#import "TSJavelinAPIUser.h"

@implementation TSJavelinAPIUserProfile

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super initWithAttributes:attributes];
    if (!self) {
        return nil;
    }
    
    _profileImage = [attributes valueForKey:@"profile_image"];;
    _profileImageURL = [attributes valueForKey:@"profile_image_url"];
    _birthday = [attributes valueForKey:@"birthday"];
    _address = [attributes valueForKey:@"address"];
    _addressDictionary = [attributes valueForKey:@"address_dictionary"];
    _hairColor = [[attributes valueForKey:@"hair_color"] integerValue];
    _gender = [[attributes valueForKey:@"gender"] integerValue];
    _race = [[attributes valueForKey:@"race"] integerValue];
    _height = [attributes valueForKey:@"height"];
    _weight = [[attributes objectForKey:@"weight"] integerValue];
    _knownAllergies = [attributes valueForKey:@"known_allergies"];
    _medications = [attributes valueForKey:@"medications"];
    _emergencyContactFirstName = [attributes valueForKey:@"emergency_contact_first_name"];
    _emergencyContactLastName = [attributes valueForKey:@"emergency_contact_last_name"];
    _emergencyContactPhoneNumber = [attributes valueForKey:@"emergency_contact_phone_number"];
    _emergencyContactRelationship = [[attributes valueForKey:@"emergency_contact_relationship"] integerValue];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc

    [encoder encodeObject: _profileImage forKey: @"profile_image"];
    [encoder encodeObject: _profileImageURL forKey: @"profile_image_url"];
    [encoder encodeObject: _birthday forKey: @"birthday"];
    [encoder encodeObject: _address forKey:@"address"];
    [encoder encodeObject:_addressDictionary forKey:@"address_dictionary"];
    [encoder encodeInteger: _hairColor forKey:@"hair_color"];
    [encoder encodeInteger: _gender forKey:@"gender"];
    [encoder encodeInteger: _race forKey:@"race"];
    [encoder encodeObject: _height forKey:@"height"];
    [encoder encodeObject: @(_weight) forKey:@"weight"];
    [encoder encodeObject: _knownAllergies forKey:@"known_allergies"];
    [encoder encodeObject: _medications forKey:@"medications"];
    [encoder encodeObject: _emergencyContactFirstName forKey:@"emergency_contact_first_name"];
    [encoder encodeObject: _emergencyContactLastName forKey:@"emergency_contact_last_name"];
    [encoder encodeObject: _emergencyContactPhoneNumber forKey:@"emergency_contact_phone_number"];
    [encoder encodeInteger: _emergencyContactRelationship forKey:@"emergency_contact_relationship"];
    [encoder encodeObject: _user forKey:@"user"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        _profileImage = [decoder decodeObjectForKey:@"profile_image"];
        _profileImageURL = [decoder decodeObjectForKey:@"profile_image_url"];
        _birthday = [decoder decodeObjectForKey:@"birthday"];
        _address = [decoder decodeObjectForKey:@"address"];
        _addressDictionary = [decoder decodeObjectForKey:@"address_dictionary"];
        
        id object = [decoder decodeObjectForKey:@"hair_color"];
        if ([object isKindOfClass:[NSString class]]) {
            _hairColor = [TSJavelinAPIUserProfile indexOfShortHairColorString:object];
        }
        else {
            _hairColor = [[decoder decodeObjectForKey:@"hair_color"] integerValue];
        }
        
        object = [decoder decodeObjectForKey:@"gender"];
        if ([object isKindOfClass:[NSString class]]) {
            _gender = [TSJavelinAPIUserProfile indexOfShortGenderString:object];
        }
        else {
            _gender = [[decoder decodeObjectForKey:@"gender"] integerValue];
        }
    
        object = [decoder decodeObjectForKey:@"race"];
        if ([object isKindOfClass:[NSString class]]) {
            _race = [TSJavelinAPIUserProfile indexOfShortRaceString:object];
        }
        else {
            _race = [[decoder decodeObjectForKey:@"race"] integerValue];
        }
        
        _height = [decoder decodeObjectForKey:@"height"];
        _weight = [[decoder decodeObjectForKey:@"weight"] unsignedIntegerValue];
        _knownAllergies = [decoder decodeObjectForKey:@"known_allergies"];
        _medications = [decoder decodeObjectForKey:@"medications"];
        _emergencyContactFirstName = [decoder decodeObjectForKey:@"emergency_contact_first_name"];
        _emergencyContactLastName = [decoder decodeObjectForKey:@"emergency_contact_last_name"];
        _emergencyContactPhoneNumber = [decoder decodeObjectForKey:@"emergency_contact_phone_number"];
        
        object = [decoder decodeObjectForKey:@"emergency_contact_relationship"];
        if ([object isKindOfClass:[NSString class]]) {
            _emergencyContactRelationship = [TSJavelinAPIUserProfile indexOfShortRelationshipString:object];
        }
        else {
            _emergencyContactRelationship = [[decoder decodeObjectForKey:@"emergency_contact_relationship"] integerValue];
        }
        
        _user = [decoder decodeObjectForKey:@"user"];
    }
    return self;
}

- (NSDictionary *)dictionaryFromAttributes {
    // For each property on class, if not nil then add into dictionary and return it
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithCapacity:16];


    if (_user) {
        attributes[@"user"] = _user.url;
    }
    if (_birthday) {
        attributes[@"birthday"] = _birthday;
    }
    
    if (_address) {
        attributes[@"address"] = _address;
    }
    
    if (_addressDictionary) {
        attributes[@"address"] = [TSJavelinAPIUserProfile stringFromAddressDictionary:_addressDictionary];
    }

    if (_hairColor) {
        attributes[@"hair_color"] = [TSJavelinAPIUserProfile hairColorToShortString:_hairColor];
    }

    if (_gender) {
        attributes[@"gender"] = [TSJavelinAPIUserProfile genderToShortString:_gender];
    }

    if (_race) {
        attributes[@"race"] = [TSJavelinAPIUserProfile raceToShortString:_race];
    }

    if (_height) {
        attributes[@"height"] = _height;
    }

    if (_weight) {
        attributes[@"weight"] = @(_weight);
    }

    if (_knownAllergies) {
        attributes[@"known_allergies"] = _knownAllergies;
    }

    if (_medications) {
        attributes[@"medications"] = _medications;
    }

    if (_emergencyContactFirstName) {
        attributes[@"emergency_contact_first_name"] = _emergencyContactFirstName;
    }

    if (_emergencyContactLastName) {
        attributes[@"emergency_contact_last_name"] = _emergencyContactLastName;
    }

    if (_emergencyContactPhoneNumber) {
        attributes[@"emergency_contact_phone_number"] = _emergencyContactPhoneNumber;
    }

    if (_emergencyContactRelationship) {
        attributes[@"emergency_contact_relationship"] = [TSJavelinAPIUserProfile relationshipToShortString:_emergencyContactRelationship];
    }
    if (_profileImageURL) {
        attributes[@"profile_image_url"] = _profileImageURL;
    }
    
    return attributes;
}


+ (NSString *)genderToLongString:(ProfileGender)enumValue {
    
    NSArray *orderArray = kGenderLongArray;
    
    if (enumValue >= kGenderLongArray.count) {
        return [orderArray objectAtIndex:0];
    }
    return [orderArray objectAtIndex:enumValue];
}

+ (NSString *)genderToShortString:(ProfileGender)enumValue {
    NSArray *orderArray = kGenderShortArray;
    
    if (enumValue >= kGenderShortArray.count) {
        return [orderArray objectAtIndex:0];
    }
    
    return [orderArray objectAtIndex:enumValue];
}

+ (int)indexOfShortGenderString:(NSString *)shortString {
    
    if (!shortString) {
        return 0;
    }
    
    NSArray *orderArray = kGenderShortArray;
    return [orderArray indexOfObject:shortString];
}

+ (NSArray *)genderChoices {
    return @[
             @{@"shortCode": @"", @"title": @""},
             @{@"shortCode": @"M", @"title": @"Male"},
             @{@"shortCode": @"F", @"title": @"Female"}];
}

+ (NSString *)hairColorToLongString:(ProfileHairColor)enumValue {
    NSArray *orderArray = kHairColorLongArray;
    return [orderArray objectAtIndex:enumValue];
}

+ (NSString *)hairColorToShortString:(ProfileHairColor)enumValue {
    NSArray *orderArray = kHairColorShortArray;
    return [orderArray objectAtIndex:enumValue];
}

+ (int)indexOfShortHairColorString:(NSString *)shortString {
    
    NSArray *orderArray = kHairColorShortArray;
    return [orderArray indexOfObject:shortString];
}

+ (NSArray *)hairColorChoices {
    return @[
             @{@"shortCode": @"", @"title": @""},
             @{@"shortCode": @"Y", @"title": @"Blonde"},
             @{@"shortCode": @"BR", @"title": @"Brown"},
             @{@"shortCode": @"BL", @"title": @"Black"},
             @{@"shortCode": @"R", @"title": @"Red"},
             @{@"shortCode": @"BA", @"title": @"Bald"},
             @{@"shortCode": @"GR", @"title": @"Gray"},
             @{@"shortCode": @"O", @"title": @"Other"}];
}

+ (NSString *)raceToLongString:(ProfileRace)enumValue {
    NSArray *orderArray = kRaceLongArray;
    return [orderArray objectAtIndex:enumValue];
}

+ (NSString *)raceToShortString:(ProfileRace)enumValue {
    NSArray *orderArray = kRaceShortArray;
    return [orderArray objectAtIndex:enumValue];
}

+ (int)indexOfShortRaceString:(NSString *)shortString {
    
    NSArray *orderArray = kRaceShortArray;
    return [orderArray indexOfObject:shortString];
}

+ (NSArray *)raceChoices {
    return @[
             @{@"shortCode": @"", @"title": @""},
             @{@"shortCode": @"BA", @"title": @"Black/African Descent"},
             @{@"shortCode": @"WC", @"title": @"White/Caucasian"},
             @{@"shortCode": @"EI", @"title": @"East Indian"},
             @{@"shortCode": @"AS", @"title": @"Asian"},
             @{@"shortCode": @"LH", @"title": @"Latino/Hispanic"},
             @{@"shortCode": @"ME", @"title": @"Middle Eastern"},
             @{@"shortCode": @"PI", @"title": @"Pacific Islander"},
             @{@"shortCode": @"NA", @"title": @"Native American"},
             @{@"shortCode": @"O", @"title": @"Other"}];
}

+ (NSString *)relationshipToLongString:(ProfileRelationship)enumValue {
    NSArray *orderArray = kRelationshipLongArray;
    return [orderArray objectAtIndex:enumValue];
}

+ (NSString *)relationshipToShortString:(ProfileRelationship)enumValue {
    NSArray *orderArray = kRelationshipShortArray;
    return [orderArray objectAtIndex:enumValue];
}

+ (int)indexOfShortRelationshipString:(NSString *)shortString {
    
    NSArray *orderArray = kRelationshipShortArray;
    return [orderArray indexOfObject:shortString];
}

+ (NSArray *)relationshipChoices {
    return @[
             @{@"shortCode": @"", @"title": @""},
             @{@"shortCode": @"F", @"title": @"Father"},
             @{@"shortCode": @"M", @"title": @"Mother"},
             @{@"shortCode": @"S", @"title": @"Spouse"},
             @{@"shortCode": @"BF", @"title": @"Boyfriend"},
             @{@"shortCode": @"GF", @"title": @"Girlfriend"},
             @{@"shortCode": @"B", @"title": @"Brother"},
             @{@"shortCode": @"S", @"title": @"Sister"},
             @{@"shortCode": @"FR", @"title": @"Friend"},
             @{@"shortCode": @"O", @"title": @"Other"}];
}

+ (NSString *)stringFromAddressDictionary:(NSDictionary *)addressDictionary {
    
    NSString *address;
    
    NSString *street = [addressDictionary objectForKey:@"Street"];
    if (street) {
        address = street;
    }
    
    NSString *city = [addressDictionary objectForKey:@"City"];
    if (city) {
        if (address) {
            address = [NSString stringWithFormat:@"%@, %@", address, city];
        }
        else {
            address = city;
        }
    }
    
    NSString *state = [addressDictionary objectForKey:@"State"];
    if (state) {
        if (address) {
            address = [NSString stringWithFormat:@"%@, %@", address, state];
        }
        else {
            address = state;
        }
    }
    
    NSString *zip = [addressDictionary objectForKey:@"Zip code"];
    if (zip) {
        if (address) {
            address = [NSString stringWithFormat:@"%@ %@", address, zip];
        }
        else {
            address = zip;
        }
    }
    
    return address;
}

@end
