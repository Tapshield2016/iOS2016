//
//  TSJavelinAPINamedLocation.m
//  TapShield
//
//  Created by Adam Share on 11/19/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPINamedLocation.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@implementation TSJavelinAPINamedLocation

- (id)initWithAttributes:(NSDictionary *)attributes {
    
    if (!attributes) {
        return nil;
    }
    
    self = [super initWithAttributes:attributes];
    if (!self) {
        return self;
    }
    
    NSString *street = [attributes nonNullObjectForKey:@"street"];
    NSString *city = [attributes nonNullObjectForKey:@"city"];
    NSString *state = [attributes nonNullObjectForKey:@"state"];
    NSString *zip = [attributes nonNullObjectForKey:@"zip"];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:4];
    if (street) {
        [dictionary setObject:street forKey:(__bridge NSString *)kABPersonAddressStreetKey];
    }
    
    if (city) {
        [dictionary setObject:city forKey:(__bridge NSString *)kABPersonAddressCityKey];
    }
    
    if (state) {
        [dictionary setObject:state forKey:(__bridge NSString *)kABPersonAddressStateKey];
    }
    
    if (zip) {
        [dictionary setObject:zip forKey:(__bridge NSString *)kABPersonAddressZIPKey];
    }
    
    if (dictionary.allValues.count) {
        self.addressDictionary = [NSDictionary dictionaryWithDictionary:dictionary];
    }
    
    self.formattedAddress = [attributes nonNullObjectForKey:@"formatted_address"];
    self.name = [attributes nonNullObjectForKey:@"name"];
    self.location = [[CLLocation alloc] initWithLatitude:[[attributes nonNullObjectForKey:@"latitude"] doubleValue] longitude:[[attributes nonNullObjectForKey:@"longitude"] doubleValue]];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:_addressDictionary forKey:@"addressDictionary"];
    [encoder encodeObject:_formattedAddress forKey:@"formatted_address"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_location forKey:@"location"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super initWithCoder:decoder])) {
        
        _addressDictionary = [decoder decodeObjectForKey:@"addressDictionary"];
        _formattedAddress = [decoder decodeObjectForKey:@"formatted_address"];
        _name = [decoder decodeObjectForKey:@"name"];
        _location = [decoder decodeObjectForKey:@"location"];
    }
    return self;
}

- (id)initWithMapItem:(MKMapItem *)item {
    
    self = [super init];
    if (!self) {
        return self;
    }
    
    self.addressDictionary = item.placemark.addressDictionary;
    self.formattedAddress = ABCreateStringWithAddressDictionary(item.placemark.addressDictionary, NO);
    self.name = item.name;
    self.location = item.placemark.location;
    
    return self;
}


- (MKMapItem *)mapItem {
    MKMapItem *item;
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:_location.coordinate addressDictionary:_addressDictionary];
    
    item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = _name;
    
    return item;
}

- (NSDictionary *)parametersFromLocation {
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    if (_addressDictionary) {
        NSString *street = [_addressDictionary objectForKey:(__bridge NSString *)kABPersonAddressStreetKey];
        NSString *city = [_addressDictionary objectForKey:(__bridge NSString *)kABPersonAddressCityKey];
        NSString *state = [_addressDictionary objectForKey:(__bridge NSString *)kABPersonAddressStateKey];
        NSString *zip = [_addressDictionary objectForKey:(__bridge NSString *)kABPersonAddressZIPKey];
        
        if (street) {
            [dictionary setObject:street forKey:@"street"];
        }
        
        if (city) {
            [dictionary setObject:city forKey:@"city"];
        }
        
        if (state) {
            [dictionary setObject:state forKey:@"state"];
        }
        
        if (zip) {
            [dictionary setObject:zip forKey:@"zip"];
        }
    }
    
    if (_formattedAddress) {
        [dictionary setObject:_formattedAddress forKey:@"formatted_address"];
    }
    
    if (_name) {
        [dictionary setObject:_name forKey:@"name"];
    }
    
    if (_location) {
        [dictionary setObject:@(_location.coordinate.latitude) forKey:@"latitude"];
        [dictionary setObject:@(_location.coordinate.longitude) forKey:@"longitude"];
    }
    
    return dictionary;
}

@end
