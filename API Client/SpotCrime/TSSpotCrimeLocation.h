//
//  TSSpotCrimeLocation.h
//  TapShield
//
//  Created by Adam Share on 3/30/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface TSSpotCrimeLocation : CLLocation

@property (strong, nonatomic) NSString *type;   //:"Assault",
@property (strong, nonatomic) NSString *address; //:"8XX N. CAROLINE STREET"
@property (strong, nonatomic) NSString *link; //:"http://spotcrime.com/crime/2392310288a90eee2890388cf8c679b4519c4619",
@property (strong, nonatomic) NSString *cdid; //:23923102,
@property (strong, nonatomic) NSString *date; //:"10/17/11 09:00 PM",

+ (UIImage *)imageFromSpotCrimeType:(NSString *)type;
- (id)initWithAttributes:(NSDictionary *)attributes;

@end
