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

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self resetBoolsToDefault];
    }
    return self;
}

- (instancetype)initWithPerson:(ABRecordRef)person {
    
    self = [super init];
    if (self) {
        [self resetBoolsToDefault];
        self.recordID = ABRecordGetRecordID(person);
        [self getContactInfoFromPerson:person];
    }
    return self;
}

- (void)resetBoolsToDefault {
    
    _alwaysVisible = NO;
    _notifyCalled911 = NO;
    
    _trackRoute = YES;
    _notifyArrival = YES;
    _notifyNonArrival = YES;
    _notifyYank = YES;
}

- (id)initWithAttributes:(NSDictionary *)attributes {
    
    self = [super initWithAttributes:attributes];
    if (self) {
        [self updateWithAttributes:attributes];
    }
    return self;
}

- (void)updateWithAttributes:(NSDictionary *)attributes {
    
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
    
    return [TSJavelinAPIEntourageMember nameFromFirst:_first last:_last alternate:organization];
}

+ (NSString *)nameFromFirst:(NSString *)first last:(NSString *)last alternate:(NSString *)organization {
    
    NSString *title = @"";
    
    if (first && !last) {
        title = first;
    }
    else if (!first && last) {
        title = last;
    }
    else if (first && last) {
        title = [NSString stringWithFormat:@"%@ %@", first, last];
    }
    else if (!first && !last) {
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


+ (TSJavelinAPIEntourageMember *)memberFromUser:(TSJavelinAPIUser *)user {
    
    TSJavelinAPIEntourageMember *member;
    
    ABRecordRef matching = [TSJavelinAPIEntourageMember contactContainingPhoneNumber:user.phoneNumber
                                                                               email:user.email
                                                                           firstName:user.firstName
                                                                            lastName:user.lastName];
    if (matching) {
        member = [[TSJavelinAPIEntourageMember alloc] initWithPerson:matching];
        
        if (user.email) {
            member.email = user.email;
        }
        
        if (user.phoneNumber) {
            member.phoneNumber = user.email;
        }
    }
    else {
        member = [[TSJavelinAPIEntourageMember alloc] init];
        member.first = user.firstName;
        member.last = user.lastName;
        member.name = [TSJavelinAPIEntourageMember nameFromFirst:user.firstName last:user.lastName alternate:user.username];
        member.email = user.email;
        member.phoneNumber = user.email;
    }
    
    member.lastReportedLocation = user.lastReportedLocation;
    member.lastReportedTime = user.lastReportedTime;
    member.matchedUser = user;
    member.session = user.entourageSession;
    
    return member;
}


+ (ABRecordRef)contactContainingPhoneNumber:(NSString *)phoneNumber email:(NSString *)email firstName:(NSString *)firstName lastName:(NSString *)lastName {
    
    // Remove non numeric characters from the phone number
    phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    // Create a new address book object with data from the Address Book database
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (!addressBook) {
        return nil;
    } else if (error) {
        CFRelease(addressBook);
        return nil;
    }
    
    // Requests access to address book data from the user
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {});
    
    NSPredicate *predicate;
    NSArray *filteredContacts;
    NSArray *allPeople = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    
    if (phoneNumber) {
        // Build a predicate that searches for contacts that contain the phone number
        predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary *bindings) {
            ABMultiValueRef phoneNumbers = ABRecordCopyValue( (__bridge ABRecordRef)record, kABPersonPhoneProperty);
            BOOL result = NO;
            for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
                NSString *contactPhoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                contactPhoneNumber = [[contactPhoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
                if ([contactPhoneNumber rangeOfString:phoneNumber].location != NSNotFound) {
                    result = YES;
                    break;
                }
            }
            CFRelease(phoneNumbers);
            return result;
        }];
        
        // Search the users contacts for contacts that contain the phone number
        filteredContacts = [allPeople filteredArrayUsingPredicate:predicate];
    }
    
    if (!filteredContacts.count && email) {
        predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary *bindings) {
            ABMultiValueRef emails = ABRecordCopyValue( (__bridge ABRecordRef)record, kABPersonEmailProperty);
            BOOL result = NO;
            for (CFIndex i = 0; i < ABMultiValueGetCount(emails); i++) {
                NSString *contactEmail = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(emails, i);
                if ([contactEmail isEqualToString:email]) {
                    result = YES;
                    break;
                }
            }
            CFRelease(emails);
            return result;
        }];
        
        filteredContacts = [allPeople filteredArrayUsingPredicate:predicate];
    }
    
    CFRelease(addressBook);
    
    if (!filteredContacts.count) {
        return nil;
    }
    
    if (filteredContacts.count == 1) {
        return (__bridge ABRecordRef)[filteredContacts firstObject];
    }
    
    ABRecordRef matching;
    
    
    
    for (int i = 0; i < filteredContacts.count; i++) {
        BOOL firstNameMatch = NO;
        BOOL lastNameMatch = NO;
        ABRecordRef person = (__bridge ABRecordRef)filteredContacts[i];
        
        NSString *firstNameProperty = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *lastNameProperty = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        
        if ([firstNameProperty isEqualToString:firstName]) {
            firstNameMatch = YES;
            matching = person;
        }
        if ([lastNameProperty isEqualToString:lastName]) {
            lastNameMatch = YES;
            matching = person;
        }
        
        if (firstNameMatch && lastNameMatch) {
            return matching;
        }
        if (!matching) {
            matching = person;
        }
    }
    
    return matching;
}

+ (NSArray *)entourageMembersFromUsers:(NSArray *)arrayOfUsers {
    
    if (!arrayOfUsers) {
        return nil;
    }
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:arrayOfUsers.count];
    for (NSDictionary *attributes in arrayOfUsers) {
        TSJavelinAPIUser *user = [[TSJavelinAPIUser alloc] initWithAttributes:attributes];
        [mutableArray addObject:[TSJavelinAPIEntourageMember memberFromUser:user]];
    }
    
    return mutableArray;
}

- (void)compareURLAndMerge:(TSJavelinAPIEntourageMember *)member {
    
    if ([self.url isEqualToString:member.url]) {
        _name = member.name;
        _first = member.first;
        _last = member.last;
        
        _email = member.email;
        _phoneNumber = member.phoneNumber;
        _recordID  = member.recordID;
        
        _image = member.image;
        
        _matchedUser = member.matchedUser;
        
        _alwaysVisible = member.alwaysVisible;
        
        _trackRoute = member.trackRoute;
        _notifyArrival = member.notifyArrival;
        _notifyNonArrival = member.notifyNonArrival;
        _notifyCalled911 = member.notifyCalled911;
        _notifyYank = member.notifyYank;
        
        _lastReportedLocation = member.lastReportedLocation;
        _lastReportedTime = member.lastReportedTime;
        _session = member.session;
    }
}

+ (NSArray *)sortedMemberArray:(NSArray *)array {
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    return [array sortedArrayUsingDescriptors:@[sort]];
}

@end
