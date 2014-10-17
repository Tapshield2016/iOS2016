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

- (instancetype)initWithPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    self = [super init];
    if (self) {
        
        self.recordID = ABRecordGetRecordID(person);
        [self getChosenContactInfoFromPerson:person property:property identifier:identifier];
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
            
            CFErrorRef error = nil;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
            ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID ( addressBook, _recordID );
            
            NSData *data = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(recordRef, kABPersonImageFormatThumbnail);
            
            UIImage *image = [UIImage imageWithData:data];
            
            self.image = [image imageWithRoundedCornersRadius:image.size.height/2];
            self.alternateImage = [[[UIImage imageWithData:data] gaussianBlur] imageWithRoundedCornersRadius:image.size.height/2];
            CFRelease(recordRef);
            CFRelease(addressBook);
        }
        
        _matchedUser = [attributes nonNullObjectForKey:@"matched_user"];
        
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

- (void)getChosenContactInfoFromPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    self.name = [self getTitleForABRecordRef:person];
    
    ABMultiValueRef multiRef = ABRecordCopyValue(person, property);
    CFIndex index = ABMultiValueGetIndexForIdentifier (multiRef, identifier);
    NSString *contactInfo = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(multiRef, index);
    CFRelease(multiRef);
    
    if (property == kABPersonEmailProperty) {
        self.email = contactInfo;
    }
    else if (property == kABPersonPhoneProperty) {
        self.phoneNumber = contactInfo;
    }
    
    NSData *data = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
    
    UIImage *image = [UIImage imageWithData:data];
    
    self.image = [image imageWithRoundedCornersRadius:image.size.height/2];
    self.alternateImage = [[[UIImage imageWithData:data] gaussianBlur] imageWithRoundedCornersRadius:image.size.height/2];
}


@end
