//
//  TSSpotCrimeAPIClient.m
//  TapShield
//
//  Created by Adam Share on 3/29/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSSpotCrimeAPIClient.h"

static NSString * const TSSpotCrimeAPIClientUrl = @"http://api.spotcrime.com/";
static NSString * const TSSpotCrimeAPIKey = @"2be4edd6ebd10379d1a1eb6600747726654fc81645ecae386a9a9a440329";


@implementation TSSpotCrimeAPIClient

static TSSpotCrimeAPIClient *_sharedClient = nil;
static dispatch_once_t onceToken;

+ (instancetype)initializeSharedClient {
    
    if (!_sharedClient) {
        dispatch_once(&onceToken, ^{
            _sharedClient = [[TSSpotCrimeAPIClient alloc] initWithBaseURL:[NSURL URLWithString:TSSpotCrimeAPIClientUrl]];
        });
        
        // Enable the network activity manager
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
        NSURL *authURL = [NSURL URLWithString:TSSpotCrimeAPIClientUrl];
        NSString *baseAuthURL = [NSString stringWithFormat:@"%@://%@", [authURL scheme], [authURL host]];
        if ([authURL port] && ![[authURL port] isEqual: @(80)]) {
            baseAuthURL = [NSString stringWithFormat:@"%@:%@/", baseAuthURL, [authURL port]];
        }
        else {
            baseAuthURL = [NSString stringWithFormat:@"%@/", baseAuthURL];
        }
        
        _sharedClient.baseAuthURL = baseAuthURL;
    }
    
    return _sharedClient;
}

+ (instancetype)sharedClient {
    if (_sharedClient == nil) {
        [NSException raise:@"Shared Client Not Initialized"
                    format:@"Before calling [TSSpotCrimeAPIClient sharedClient] you must first initialize the shared client"];
    }
    
    return _sharedClient;
}



- (void)getSpotCrimeAtLocation:(CLLocation *)currentLocation radiusMiles:(float)radius since:(NSDate *)date maxReturned:(int)maxNumber sortBy:(SpotCrimeSorting)sorting order:(SpotCrimeOrder)order type:(SpotCrimeTypes)type completion:(void (^)(NSArray *crimes))completion {
    
    if (!currentLocation || !radius) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[@(currentLocation.coordinate.latitude) stringValue] forKey:@"lat"];
    [parameters setObject:[@(currentLocation.coordinate.longitude) stringValue] forKey:@"lon"];
    [parameters setObject:[NSString stringWithFormat:@"%f", radius] forKey:@"radius"];
    
    if (date) {
        [parameters setObject:[self dateToString:date] forKey:@"since"];
    }
    if (maxNumber) {
        [parameters setObject:[@(maxNumber) stringValue] forKey:@"max_records"];
    }
    if (sorting) {
        [parameters setObject:[self spotCrimeSortingToString:sorting] forKey:@"sort_by"];
    }
    if (order) {
        [parameters setObject:[self spotCrimeOrderToString:order] forKey:@"sort_order"];
    }
    if (type) {
        [parameters setObject:[self spotCrimeTypesToString:type] forKey:@"types"];
    }
    
    [self.requestSerializer setValue:TSSpotCrimeAPIKey
                  forHTTPHeaderField:@"key"];
    [self GET:[NSString stringWithFormat:@"%@crimes.json", _baseAuthURL]
   parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          if (completion) {
              completion([self filterSpotCrimeResponse:responseObject]);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@", error);
      }];
    
}


- (NSArray *)filterSpotCrimeResponse:(id)responseObject {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    
    if ([(NSDictionary *)responseObject objectForKey:@"crimes"]) {
        NSArray *crimeArray = [(NSDictionary *)responseObject objectForKey:@"crimes"];
        
        for (NSDictionary *dictionary in crimeArray) {
            TSSpotCrimeLocation *crimeLocation = [[TSSpotCrimeLocation alloc] initWithAttributes:dictionary];
            [mutableArray addObject:crimeLocation];
        }
    }
    
    return mutableArray;
}

- (NSString *)dateToString:(NSDate *)date {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    //Optionally for time zone converstions
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    return [formatter stringFromDate:date];
}


- (NSString*)spotCrimeOrderToString:(SpotCrimeOrder)enumValue {
    NSArray *orderArray = [[NSArray alloc] initWithObjects:kSpotCrimeOrderArray];
    return [orderArray objectAtIndex:enumValue];
}

- (NSString*)spotCrimeSortingToString:(SpotCrimeSorting)enumValue {
    NSArray *sortingArray = [[NSArray alloc] initWithObjects:kSpotCrimeSortingArray];
    return [sortingArray objectAtIndex:enumValue];
}

- (NSString*)spotCrimeTypesToString:(SpotCrimeTypes)enumValue {
    NSArray *typesArray = [[NSArray alloc] initWithObjects:kSpotCrimeTypesArray];
    return [typesArray objectAtIndex:enumValue];
}


@end
