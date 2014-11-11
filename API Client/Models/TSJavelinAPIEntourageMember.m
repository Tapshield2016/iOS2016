//
//  TSJavelinAPIEntourageMember.m
//  TapShield
//
//  Created by Adam Share on 4/20/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIEntourageMember.h"
#import "UIImage+Color.h"
#import "UIImage+Resize.h"
#import "TSJavelinAPIClient.h"
#import "TSUtilities.h"

@implementation TSJavelinAPIEntourageMember

- (instancetype)initWithPerson:(ABRecordRef)person {
    
    self = [super init];
    if (self) {
        
        _alwaysVisible = NO;
        _notifyCalled911 = NO;
        
        _trackRoute = YES;
        _notifyArrival = YES;
        _notifyNonArrival = YES;
        _notifyYank = YES;
        
        self.recordID = ABRecordGetRecordID(person);
        [self getContactInfoFromPerson:person];
    }
    return self;
}

- (id)initWithAttributes:(NSDictionary *)attributes {
    
    self = [super initWithAttributes:attributes];
    if (self) {
        _name = [attributes nonNullObjectForKey:@"name"];
        _first = [attributes nonNullObjectForKey:@"first"];
        _last = [attributes nonNullObjectForKey:@"last"];
        
        _email = [attributes nonNullObjectForKey:@"email_address"];
        _phoneNumber = [attributes nonNullObjectForKey:@"phone_number"];
        _recordID  = [[attributes nonNullObjectForKey:@"record_id"] intValue];
        
        if (_recordID) {
            [self setImageForRecordID:_recordID];
        }
        
        if ([attributes nonNullObjectForKey:@"matched_user"]) {
            _matchedUser = [[TSJavelinAPIUser alloc] initWithOnlyURLAttribute:attributes forKey:@"matched_user"];
        }
        
        _alwaysVisible = [[attributes nonNullObjectForKey:@"always_visible"] boolValue];
        
        _trackRoute = [[attributes nonNullObjectForKey:@"track_route"] boolValue];
        _notifyArrival = [[attributes nonNullObjectForKey:@"notify_arrival"] boolValue];
        _notifyNonArrival = [[attributes nonNullObjectForKey:@"notify_non_arrival"] boolValue];
        
        _notifyCalled911 = [[attributes nonNullObjectForKey:@"notify_called_911"] boolValue];
        _notifyYank = [[attributes nonNullObjectForKey:@"notify_yank"] boolValue];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        _name = [coder decodeObjectForKey:@"name"];
        _first = [coder decodeObjectForKey:@"first"];
        _last = [coder decodeObjectForKey:@"last"];
        
        _email = [coder decodeObjectForKey:@"email"];
        _phoneNumber = [coder decodeObjectForKey:@"phoneNumber"];
        _image = [coder decodeObjectForKey:@"image"];
        _alternateImage = [coder decodeObjectForKey:@"alternateImage"];
        _recordID = [[coder decodeObjectForKey:@"record_id"] intValue];
        
        _matchedUser = [coder decodeObjectForKey:@"matched_user"];
        
        _alwaysVisible = [[coder decodeObjectForKey:@"always_visible"] boolValue];
        
        _trackRoute = [[coder decodeObjectForKey:@"track_route"] boolValue];
        _notifyArrival = [[coder decodeObjectForKey:@"notify_arrival"] boolValue];
        _notifyNonArrival = [[coder decodeObjectForKey:@"notify_non_arrival"] boolValue];
        
        _notifyCalled911 = [[coder decodeObjectForKey:@"notify_called_911"] boolValue];
        _notifyYank = [[coder decodeObjectForKey:@"notify_yank"] boolValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject: _name forKey: @"name"];
    [encoder encodeObject: _first forKey: @"first"];
    [encoder encodeObject: _last forKey: @"last"];
    
    [encoder encodeObject: _email forKey: @"email"];
    [encoder encodeObject: _phoneNumber forKey: @"phoneNumber"];
    [encoder encodeObject: _image forKey: @"image"];
    [encoder encodeObject: _alternateImage forKey: @"alternateImage"];
    [encoder encodeObject: @(_recordID) forKey: @"record_id"];
    
    [encoder encodeObject:_matchedUser forKey:@"matched_user"];
    
    [encoder encodeObject:@(_alwaysVisible) forKey:@"always_visible"];
    
    [encoder encodeObject:@(_trackRoute) forKey:@"track_route"];
    [encoder encodeObject:@(_notifyArrival) forKey:@"notify_arrival"];
    [encoder encodeObject:@(_notifyNonArrival) forKey:@"notify_non_arrival"];
    
    [encoder encodeObject:@(_notifyCalled911) forKey:@"notify_called_911"];
    [encoder encodeObject:@(_notifyYank) forKey:@"notify_yank"];
}

- (NSDictionary *)parametersFromMember {
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    if (!_email && !_phoneNumber) {
        return nil;
    }
    
    if ([[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].url) {
        [dictionary setObject:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].url forKey:@"user"];
    }
    else {
        return nil;
    }
    
    if (_name) {
        [dictionary setObject:_name forKey:@"name"];
    }
    else {
        return nil;
    }
    
    if (_first) {
        [dictionary setObject:_first forKey:@"first"];
    }
    
    if (_last) {
        [dictionary setObject:_last forKey:@"last"];
    }
    
    if (_phoneNumber) {
        [dictionary setObject:[TSUtilities removeNonNumericalCharacters:_phoneNumber] forKey:@"phone_number"];
    }
    
    if (_email) {
        [dictionary setObject:_email forKey:@"email_address"];
    }
    
    [dictionary setObject:@(_recordID) forKey:@"record_id"];
    
    [dictionary setObject:@(_alwaysVisible) forKey:@"always_visible"];
    
    [dictionary setObject:@(_trackRoute) forKey:@"track_route"];
    [dictionary setObject:@(_notifyArrival) forKey:@"notify_arrival"];
    [dictionary setObject:@(_notifyNonArrival) forKey:@"notify_non_arrival"];
    
    [dictionary setObject:@(_notifyCalled911) forKey:@"notify_called_911"];
    [dictionary setObject:@(_notifyYank) forKey:@"notify_yank"];
    
    return dictionary;
}


- (NSString *)getTitleForABRecordRef:(ABRecordRef)record {
    _first = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonFirstNameProperty);
    _last = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonLastNameProperty);
    NSString *organization = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonOrganizationProperty);
    NSString *title = @"";
    
    if (_first && !_last) {
        title = _first;
    }
    else if (!_first && _last) {
        title = _last;
    }
    else if (_first && _last) {
        title = [NSString stringWithFormat:@"%@ %@", _first, _last];
    }
    else if (!_first && !_last) {
        if (organization) {
            title = organization;
        }
    }
    return title;
}

- (void)mobileNumberFromPerson:(ABRecordRef)person {
    
    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSString *mobile;
    NSString *other;
    NSString *mobileLabel;
    
    for (CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
        
        mobileLabel = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(phones, i);
        
        if ([mobileLabel isEqualToString:(__bridge_transfer NSString *)kABPersonPhoneMobileLabel]) {
            mobile = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, i);
        }
        else if ([mobileLabel isEqualToString:(__bridge_transfer NSString *)kABPersonPhoneIPhoneLabel]) {
            mobile = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, i);
            break ;
        }
        else {
            other = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, i);
        }
    }
    
    if (mobile) {
        self.phoneNumber = mobile;
    }
    else {
        self.phoneNumber = other;
    }
    
    CFRelease(phones);
}

- (void)emailFromPerson:(ABRecordRef)person {
    
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    NSString *home;
    NSString *work;
    NSString *other;
    NSString *emailLabel;
    
    for (CFIndex i = 0; i < ABMultiValueGetCount(emails); i++) {
        
        emailLabel = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(emails, i);
        
        if ([emailLabel isEqualToString:(__bridge_transfer NSString *)kABHomeLabel]) {
            home = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, i);
            break;
        }
        else if ([emailLabel isEqualToString:(__bridge_transfer NSString *)kABWorkLabel]) {
            work = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, i);
        }
        else {
            other = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, i);
        }
    }
    
    if (home) {
        self.email = home;
    }
    else if (work) {
        self.email = work;
    }
    else {
        self.email = other;
    }
    
    CFRelease(emails);
}

- (void)imageFromPerson:(ABRecordRef)person {
    
    NSData *data = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
    
    if (data) {
        UIImage *image = [UIImage imageWithData:data];
        
        self.image = [image imageWithRoundedCornersRadius:image.size.height/2];
//        self.alternateImage = [[[UIImage imageWithData:data] gaussianBlur] imageWithRoundedCornersRadius:image.size.height/2];
    }
}

- (void)getContactInfoFromPerson:(ABRecordRef)person {
    
    self.name = [self getTitleForABRecordRef:person];
    
    [self mobileNumberFromPerson:person];
    [self emailFromPerson:person];
    [self imageFromPerson:person];
}


- (void)setImageForRecordID:(ABRecordID)recordID {
    
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (!error) {
        ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID ( addressBook, recordID );
        
        TSJavelinAPIEntourageMember *member = [[TSJavelinAPIEntourageMember alloc] initWithPerson:recordRef];
        
        if ([self isEqual:member]) {
            [self imageFromPerson:recordRef];
        }
        else {
            self.recordID = 0;
        }
    }
    
    CFRelease(addressBook);
}

- (BOOL)isEqual:(id)object {
    
    if ([object isKindOfClass:[TSJavelinAPIEntourageMember class]]) {
        TSJavelinAPIEntourageMember *member = object;
        
        int numberYes = 0;
        BOOL phoneNumberSame = NO;
        BOOL emailSame = NO;
        BOOL recordIDSame = NO;
        BOOL firstNameSame = NO;
        BOOL lastNameSame = NO;
        
        if (member.recordID == self.recordID) {
            recordIDSame = YES;
            numberYes++;
        }
        
        if (member.phoneNumber && self.phoneNumber) {
            if ([member.phoneNumber isEqualToString:self.phoneNumber]) {
                phoneNumberSame = YES;
                numberYes++;
            }
        }
        
        if (member.email && self.email) {
            if ([member.email isEqualToString:self.email]) {
                emailSame = YES;
                numberYes++;
            }
        }
        
        if (member.first && self.first) {
            if ([member.first isEqualToString:self.first]) {
                firstNameSame = YES;
                numberYes++;
            }
        }
        
        if (member.last && self.last) {
            if ([member.last isEqualToString:self.last]) {
                lastNameSame = YES;
                numberYes++;
            }
        }
        
        if (recordIDSame && (phoneNumberSame || emailSame)) {
            return YES;
        }
        
        if (numberYes >= 3) {
            return YES;
        }
    }
    
    return NO;
}

@end
