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

@implementation TSJavelinAPIEntourageMember

- (instancetype)initWithPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    self = [super init];
    if (self) {
        
        self.recordID = ABRecordGetRecordID(person);
        [self getChosenContactInfoFromPerson:person property:property identifier:identifier];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        _name = [coder decodeObjectForKey:@"name"];
        _email = [coder decodeObjectForKey:@"email"];
        _phoneNumber = [coder decodeObjectForKey:@"phoneNumber"];
        _image = [coder decodeObjectForKey:@"image"];
        _alternateImage = [coder decodeObjectForKey:@"alternateImage"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject: _name forKey: @"name"];
    [encoder encodeObject: _email forKey: @"email"];
    [encoder encodeObject: _phoneNumber forKey: @"phoneNumber"];
    [encoder encodeObject: _image forKey: @"image"];
    [encoder encodeObject: _alternateImage forKey: @"alternateImage"];
}


- (NSString *)getTitleForABRecordRef:(ABRecordRef)record {
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonLastNameProperty);
    NSString *organization = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonOrganizationProperty);
    NSString *title = @"";
    
    if (firstName && !lastName) {
        title = firstName;
    }
    else if (!firstName && lastName) {
        title = lastName;
    }
    else if (firstName && lastName) {
        title = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
    else if (!firstName && !lastName) {
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
