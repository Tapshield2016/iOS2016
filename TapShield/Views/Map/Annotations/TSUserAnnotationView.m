//
//  TSUserAnnotationView.m
//  TapShield
//
//  Created by Adam Share on 4/3/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSUserAnnotationView.h"
#import "TSJavelinAPIClient.h"
#import "TSJavelinAPIAuthenticationManager.h"
#import "UIImage+Resize.h"
#import "UIImage+Color.h"
#import "TSAlertManager.h"
#import "TSAnimatedAccuracyCircle.h"

@interface TSUserAnnotationView ()

@property (strong, nonatomic) UIImageView *imageView;

@property (assign) BOOL isBlueColor;
@property (assign) BOOL isUserImage;

@end

@implementation TSUserAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.image = [UIImage imageNamed:@"user_icon"];
        self.accessibilityLabel = @"Your Location";
        
        [self setCanShowCallout:YES];
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 1.0f;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowOffset = CGSizeZero;
        
        self.isBlueColor = YES;
        self.isUserImage = YES;
        
        _animatedOverlay = [[TSAnimatedAccuracyCircle alloc] initWithFrame:CGRectZero];
        [_animatedOverlay setUserInteractionEnabled:NO];
        
        [self insertSubview:_animatedOverlay atIndex:0];
    }
    return self;
    
}

- (void)setAnnotation:(TSUserLocationAnnotation *)annotation {
    
    [super setAnnotation:annotation];
    
    annotation.annotationView = self;
    
    [self updateImage];
    
    [self updateAnimatedViewAt:annotation.location];
}

- (void)updateImage {
    
    UIImage *image = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].userProfile.profileImage;
    
    CGSize size = self.image.size;
    
    
    if (!image) {
        self.isUserImage = NO;
        if ([TSJavelinAPIClient sharedClient].isStillActiveAlert && [TSAlertManager sharedManager].type != kAlertTypeChat) {
            image = [UIImage imageFromColor:[TSColorPalette alertRed]];
            self.isBlueColor = NO;
        }
        else {
            image = [UIImage imageFromColor:[TSColorPalette tapshieldBlue]];
            self.isBlueColor = YES;
        }
    }
    else {
        size.height = size.height * 1.5;
        size.width = size.height;
    }
    
    if (image) {
        self.isUserImage = YES;
        
        [_imageView removeFromSuperview];
        _imageView = [[UIImageView alloc] initWithImage:[[image imageWithRoundedCornersRadius:image.size.height/2] resizeToSize:size]];
        _imageView.layer.cornerRadius = _imageView.frame.size.height/2;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        self.frame = _imageView.bounds;
        self.layer.cornerRadius = _imageView.frame.size.height/2;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 2.0f;
    }
    
    [self insertSubview:_animatedOverlay atIndex:0];
}

#pragma mark Animated Overlay

- (void)updateAnimatedUserAnnotation {
    
    [self updateAnimatedViewAt:[(TSUserLocationAnnotation *)self.annotation location]];
}

- (void)updateAnimatedViewAt:(CLLocation *)location {
    
    BOOL isBlueColor = YES;
    
    float radius = location.horizontalAccuracy;
    if (radius > 500) {
        radius = 500;
    }
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, radius*2, radius*2);
    UIColor *color = [[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.35f];
    
    if ([TSJavelinAPIClient sharedClient].isStillActiveAlert && [TSAlertManager sharedManager].type != kAlertTypeChat) {
        color = [[TSColorPalette alertRed] colorWithAlphaComponent:0.15f];
        region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000);
        isBlueColor = NO;
    }
    
    if (self.isBlueColor != isBlueColor && !self.isUserImage) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self updateImage];
        }];
        
    }
    
    CGRect rect = [self.mapView  convertRegion:region toRectToView:self.mapView];
    //set up the animated overlay
    rect.size.width = rect.size.height;
    
    if (ceilf(_animatedOverlay.frame.size.width)  == ceilf(rect.size.width) &&
        _animatedOverlay.isBlueColor == isBlueColor) {
        return;
    }
    
    _animatedOverlay.isBlueColor = isBlueColor;
    
    [_animatedOverlay startAnimatingWithColor:color
                                     andFrame:rect];
}

@end
