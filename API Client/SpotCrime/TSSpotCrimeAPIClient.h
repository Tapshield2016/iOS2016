//
//  TSSpotCrimeAPIClient.h
//  TapShield
//
//  Created by Adam Share on 3/29/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import <CoreLocation/CoreLocation.h>
#import "TSSpotCrimeLocation.h"

#define kSpotCrimeSortingArray @"date", @"distance", nil
typedef enum {
    sortByDate, // == 0 (Default)
    sortByDistance, // == 1
} SpotCrimeSorting;

#define kSpotCrimeOrderArray @"DESC", @"ASC", nil
typedef enum {
    orderDescending, // == 0 (Default)
    orderAscending, // == 1
} SpotCrimeOrder;


#define kSpotCrimeTypesArray @"Arrest", @"Arson", @"Assault", @"Burglary", @"Other", @"Robbery", @"Shooting", @"Theft", @"Vandalism", nil

#define kSpotCrimeTypesShortArray @"A", @"AR", @"AS", @"B", @"O", @"R", @"S", @"T", @"V", nil
typedef enum {
    arrest,
    arson,
    assault,
    burglary,
    other,
    robbery,
    shooting,
    theft,
    vandalism,
} SpotCrimeTypes;

@interface TSSpotCrimeAPIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

- (void)getSpotCrimeAtLocation:(CLLocation *)currentLocation radiusMiles:(float)radius since:(NSDate *)date maxReturned:(int)maxNumber sortBy:(SpotCrimeSorting)sorting order:(SpotCrimeOrder)order type:(SpotCrimeTypes)type completion:(void (^)(NSArray *crimes))completion;

- (void)getSpotCrimeDescription:(TSSpotCrimeLocation *)location completion:(void(^)(TSSpotCrimeLocation *location))completion;

+ (NSString *)spotCrimeTypesToString:(SpotCrimeTypes)enumValue;

@property (nonatomic, strong) NSString *baseAuthURL;

@end
