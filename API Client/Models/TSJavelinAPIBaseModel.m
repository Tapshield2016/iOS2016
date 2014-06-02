//
//  TSJavelinAPIBaseModel.m
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"

@implementation TSJavelinAPIBaseModel

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.url = [attributes valueForKey:@"url"];

    return self;
}

- (instancetype)initWithOnlyURLAttribute:(NSDictionary *)attributes forKey:(NSString *)key {
    return [self initWithAttributes:@{@"url": [attributes valueForKey:key]}];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.url forKey:@"url"];
    [encoder encodeObject:[NSNumber numberWithUnsignedInteger:self.identifier] forKey:@"identifier"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.url = [decoder decodeObjectForKey:@"url"];
        _identifier = [[decoder decodeObjectForKey:@"identifier"] unsignedIntegerValue];
    }
    return self;
}

- (void)setUrl:(NSString *)url {
    _url = url;

    if (!url || [url isKindOfClass:[NSNull class]]) {
        _identifier = 0;
        return;
    }
    
    // Expects a path like /api/v1/users/1/, so the 2nd to last item in the
    // list of components should be our integer ID.
    NSArray *urlComponents = [_url componentsSeparatedByString:@"/"];
    if (urlComponents.count) {
        _identifier = [urlComponents[urlComponents.count - 2] integerValue];
    }
}

- (NSDate *)reformattedTimeStamp:(NSString *)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *date = [dateFormatter dateFromString:string];
    
    return date;
}

@end
