//
//  TSJavelinAPITimesStampedModel.m
//  TapShield
//
//  Created by Adam Share on 11/24/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPITimeStampedModel.h"

@implementation TSJavelinAPITimeStampedModel

- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super initWithAttributes:attributes];
    if (self) {
        _creationDate = [self reformattedTimeStamp:[attributes nonNullObjectForKey:@"creation_date"]];
        _lastModified = [self reformattedTimeStamp:[attributes valueForKey:@"last_modified"]];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:self.creationDate forKey:@"creation_date"];
    [encoder encodeObject:self.lastModified forKey:@"last_modified"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super initWithCoder:decoder])) {
        //decode properties, other class vars
        self.creationDate = [decoder decodeObjectForKey:@"creation_date"];
        self.lastModified = [decoder decodeObjectForKey:@"last_modified"];
    }
    return self;
}

@end
