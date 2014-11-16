//
//  TSJavelinAPITheme.m
//  TapShield
//
//  Created by Adam Share on 11/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPITheme.h"
#import "TSJavelinAPIBaseModel+AFNetworking.h"
#import "TSColorPalette.h"

static NSString * const kPrimaryColor =  @"primary_color";
static NSString * const kSecondaryColor =  @"secondary_color";
static NSString * const kAlternateColor =  @"alternate_color";
static NSString * const kSmallLogo =  @"small_logo";
static NSString * const kNavbarLogo =  @"navbar_logo";
static NSString * const kNavbarLogoAlternate =  @"navbar_logo_alternate";
static NSString * const kMapOverlayLogo =  @"map_overlay_logo";

static NSString * const kSmallLogoPropertyKey =  @"smallLogo";
static NSString * const kNavbarLogoPropertyKey =  @"navbarLogo";
static NSString * const kNavbarLogoAlternatePropertyKey =  @"navbarLogoAlternate";
static NSString * const kMapOverlayLogoPropertyKey =  @"mapOverlayLogo";

@implementation TSJavelinAPITheme

- (id)initWithAttributes:(NSDictionary *)attributes {
    
    self = [super initWithAttributes:attributes];
    if (!self) {
        return self;
    }
    
    self.primaryColor = [TSColorPalette colorFromStringHex:[attributes nonNullObjectForKey:kPrimaryColor]];
    self.secondaryColor = [TSColorPalette colorFromStringHex:[attributes nonNullObjectForKey:kSecondaryColor]];
    self.alternateColor = [TSColorPalette colorFromStringHex:[attributes nonNullObjectForKey:kAlternateColor]];
    
    
    _smallLogoUrl = [attributes nonNullObjectForKey:kSmallLogo];
    [self setLogoKey:kSmallLogoPropertyKey fromPath:_smallLogoUrl];
    
    _navbarLogoUrl = [attributes nonNullObjectForKey:kNavbarLogo];
    [self setLogoKey:kNavbarLogoPropertyKey fromPath:_navbarLogoUrl];
    
    _navbarLogoAlternateUrl = [attributes nonNullObjectForKey:kNavbarLogoAlternate];
    [self setLogoKey:kNavbarLogoAlternatePropertyKey fromPath:_navbarLogoAlternateUrl];
    
    _mapOverlayLogoUrl = [attributes nonNullObjectForKey:kMapOverlayLogo];
    [self setLogoKey:kMapOverlayLogoPropertyKey fromPath:_mapOverlayLogoUrl];
    
    return self;
}

- (instancetype)updateWithAttributes:(NSDictionary *)attributes {
    
    self.primaryColor = [TSColorPalette colorFromStringHex:[attributes nonNullObjectForKey:kPrimaryColor]];
    self.secondaryColor = [TSColorPalette colorFromStringHex:[attributes nonNullObjectForKey:kSecondaryColor]];
    self.alternateColor = [TSColorPalette colorFromStringHex:[attributes nonNullObjectForKey:kAlternateColor]];
    
    if (![[attributes nonNullObjectForKey:kSmallLogo] isEqualToString:_smallLogoUrl] || !_smallLogo) {
        _smallLogoUrl = [attributes nonNullObjectForKey:kSmallLogo];
        [self setLogoKey:kSmallLogoPropertyKey fromPath:_smallLogoUrl];
    }
    
    if (![[attributes nonNullObjectForKey:kNavbarLogo] isEqualToString:_navbarLogoUrl] || !_navbarLogo) {
        _navbarLogoUrl = [attributes nonNullObjectForKey:kNavbarLogo];
        [self setLogoKey:kNavbarLogoPropertyKey fromPath:_navbarLogoUrl];
    }
    
    if (![[attributes nonNullObjectForKey:kNavbarLogoAlternate] isEqualToString:_navbarLogoAlternateUrl] || !_navbarLogoAlternate) {
        _navbarLogoAlternateUrl = [attributes nonNullObjectForKey:kNavbarLogoAlternate];
        [self setLogoKey:kNavbarLogoAlternatePropertyKey fromPath:_navbarLogoAlternateUrl];
    }
    
    if (![[attributes nonNullObjectForKey:kMapOverlayLogo] isEqualToString:_mapOverlayLogoUrl] || !_mapOverlayLogo) {
        _mapOverlayLogoUrl = [attributes nonNullObjectForKey:kMapOverlayLogo];
        [self setLogoKey:kMapOverlayLogoPropertyKey fromPath:_mapOverlayLogoUrl];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        self.primaryColor = [coder decodeObjectForKey:kPrimaryColor];
        self.secondaryColor = [coder decodeObjectForKey:kSecondaryColor];
        self.alternateColor = [coder decodeObjectForKey:kAlternateColor];
        
        self.smallLogo = [coder decodeObjectForKey:kSmallLogo];
        self.navbarLogo = [coder decodeObjectForKey:kNavbarLogo];
        self.navbarLogoAlternate = [coder decodeObjectForKey:kNavbarLogoAlternate];
        self.mapOverlayLogo = [coder decodeObjectForKey:kMapOverlayLogo];
        
        self.smallLogoUrl = [coder decodeObjectForKey:kSmallLogoPropertyKey];
        self.navbarLogoUrl = [coder decodeObjectForKey:kNavbarLogoPropertyKey];
        self.navbarLogoAlternateUrl = [coder decodeObjectForKey:kNavbarLogoAlternatePropertyKey];
        self.mapOverlayLogoUrl = [coder decodeObjectForKey:kMapOverlayLogoPropertyKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    
    [super encodeWithCoder:encoder];
    
    if (_primaryColor) {
        [encoder encodeObject:self.primaryColor forKey:kPrimaryColor];
    }
    
    if (_secondaryColor) {
        [encoder encodeObject:self.secondaryColor forKey:kSecondaryColor];
    }
    
    if (_alternateColor) {
        [encoder encodeObject:self.alternateColor forKey:kAlternateColor];
    }
    
    if (_smallLogoUrl) {
        [encoder encodeObject:self.smallLogoUrl forKey:kSmallLogoPropertyKey];
    }
    
    if (_navbarLogoUrl) {
        [encoder encodeObject:self.navbarLogoUrl forKey:kNavbarLogoPropertyKey];
    }
    
    if (_navbarLogoAlternateUrl) {
        [encoder encodeObject:self.navbarLogoAlternateUrl forKey:kNavbarLogoAlternatePropertyKey];
    }
    
    if (_mapOverlayLogoUrl) {
        [encoder encodeObject:self.mapOverlayLogoUrl forKey:kMapOverlayLogoPropertyKey];
    }
    
    
    if (_smallLogo) {
        [encoder encodeObject:self.smallLogo forKey:kSmallLogo];
    }
    
    if (_navbarLogo) {
        [encoder encodeObject:self.navbarLogo forKey:kNavbarLogo];
    }
    
    if (_navbarLogoAlternate) {
        [encoder encodeObject:self.navbarLogoAlternate forKey:kNavbarLogoAlternate];
    }
    
    if (_mapOverlayLogo) {
        [encoder encodeObject:self.mapOverlayLogo forKey:kMapOverlayLogo];
    }
}


- (void)setLogoKey:(NSString *)key fromPath:(NSString *)path {
    
    if (!path || !path.length) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    
    [self getImageWithURLRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [self setValue:image forKey:key];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}

- (void)setSmallLogo:(UIImage *)smallLogo {
    
    _smallLogo = smallLogo;
    
    
}


@end
