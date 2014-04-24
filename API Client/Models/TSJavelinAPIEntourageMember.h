//
//  TSJavelinAPIEntourageMember.h
//  TapShield
//
//  Created by Adam Share on 4/20/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"
#import <AddressBook/AddressBook.h>

@interface TSJavelinAPIEntourageMember : TSJavelinAPIBaseModel

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) UIImage *image;

- (instancetype)initWithPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;

@end
