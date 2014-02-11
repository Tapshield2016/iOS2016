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
    _hairColor = [attributes valueForKey:@"hair_color"];
    _gender = [attributes valueForKey:@"gender"];
    _race = [attributes valueForKey:@"race"];
    _height = [attributes valueForKey:@"height"];
    _weight = [[attributes objectForKey:@"weight"] integerValue];
    _knownAllergies = [attributes valueForKey:@"known_allergies"];
    _medications = [attributes valueForKey:@"medications"];
    _emergencyContactFirstName = [attributes valueForKey:@"emergency_contact_first_name"];
    _emergencyContactLastName = [attributes valueForKey:@"emergency_contact_last_name"];
    _emergencyContactPhoneNumber = [attributes valueForKey:@"emergency_contact_phone_number"];
    _emergencyContactRelationship = [attributes valueForKey:@"emergency_contact_relationship"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc

    [encoder encodeObject: _profileImage forKey: @"profile_image"];
    [encoder encodeObject: _profileImageURL forKey: @"profile_image_url"];
    [encoder encodeObject: _birthday forKey: @"birthday"];
    [encoder encodeObject: _address forKey:@"address"];
    [encoder encodeObject: _hairColor forKey:@"hair_color"];
    [encoder encodeObject: _gender forKey:@"gender"];
    [encoder encodeObject: _race forKey:@"race"];
    [encoder encodeObject: _height forKey:@"height"];
    [encoder encodeObject: @(_weight) forKey:@"weight"];
    [encoder encodeObject: _knownAllergies forKey:@"known_allergies"];
    [encoder encodeObject: _medications forKey:@"medications"];
    [encoder encodeObject: _emergencyContactFirstName forKey:@"emergency_contact_first_name"];
    [encoder encodeObject: _emergencyContactLastName forKey:@"emergency_contact_last_name"];
    [encoder encodeObject: _emergencyContactPhoneNumber forKey:@"emergency_contact_phone_number"];
    [encoder encodeObject: _emergencyContactRelationship forKey:@"emergency_contact_relationship"];
    [encoder encodeObject: _user forKey:@"user"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        _profileImage = [decoder decodeObjectForKey:@"profile_image"];
        _profileImageURL = [decoder decodeObjectForKey:@"profile_image_url"];
        _birthday = [decoder decodeObjectForKey:@"birthday"];
        _address = [decoder decodeObjectForKey:@"address"];
        _hairColor = [decoder decodeObjectForKey:@"hair_color"];
        _gender = [decoder decodeObjectForKey:@"gender"];
        _race = [decoder decodeObjectForKey:@"race"];
        _height = [decoder decodeObjectForKey:@"height"];
        _weight = [[decoder decodeObjectForKey:@"weight"] unsignedIntegerValue];
        _knownAllergies = [decoder decodeObjectForKey:@"known_allergies"];
        _medications = [decoder decodeObjectForKey:@"medications"];
        _emergencyContactFirstName = [decoder decodeObjectForKey:@"emergency_contact_first_name"];
        _emergencyContactLastName = [decoder decodeObjectForKey:@"emergency_contact_last_name"];
        _emergencyContactPhoneNumber = [decoder decodeObjectForKey:@"emergency_contact_phone_number"];
        _emergencyContactRelationship = [decoder decodeObjectForKey:@"emergency_contact_relationship"];
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

    if (_hairColor) {
        attributes[@"hair_color"] = _hairColor;
    }

    if (_gender) {
        attributes[@"gender"] = _gender;
    }

    if (_race) {
        attributes[@"race"] = _race;
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
        attributes[@"emergency_contact_relationship"] = _emergencyContactRelationship;
    }
    if (_profileImageURL) {
        attributes[@"profile_image_url"] = _profileImageURL;
    }
    
    return attributes;
}

+ (NSArray *)genderChoices {
    return @[
             @{@"shortCode": @"", @"title": @""},
             @{@"shortCode": @"M", @"title": @"Male"},
             @{@"shortCode": @"F", @"title": @"Female"}];
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

@end
