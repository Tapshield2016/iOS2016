//
//  TSDestinationAnnotation.m
//  TapShield
//
//  Created by Adam Share on 4/3/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSDestinationAnnotationView.h"
#import "TSSelectedDestinationLeftCalloutAccessoryView.h"
#import "TSSelectedDestinationAnnotation.h"
#import "TSEntourageSessionManager.h"
#import "TSRoutePickerViewController.h"

@interface TSDestinationAnnotationView ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation TSDestinationAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.centerOffset = CGPointMake(0, -self.image.size.height / 2);
        [self setCanShowCallout:YES];
        self.alpha = 0.9;
        self.accessibilityLabel = @"Destination";
        
        UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"entourage_icon"]];
        self.leftCalloutAccessoryView = imageview;
    }
    return self;

}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    
    [super setAnnotation:annotation];
    
    [self displayTransportationType:annotation];
}

- (void)displayTransportationType:(id<MKAnnotation>)annotation {
    
    self.image = [UIImage imageNamed:@"CarEndPoint"];
    
    if ([annotation isKindOfClass:[TSSelectedDestinationAnnotation class]]) {
        TSSelectedDestinationAnnotation *selectedAnnotation = (TSSelectedDestinationAnnotation *)annotation;
        
        
        if (selectedAnnotation.transportType == MKDirectionsTransportTypeWalking) {
            self.image = [UIImage imageNamed:@"WalkEndPoint"];
        }
        
        if (selectedAnnotation.temp) {
            
            [self removeGestureRecognizer:_tapGesture];
            _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:[TSEntourageSessionManager sharedManager].routeManager.destinationPickerVC  action:@selector(calloutTapped:)];
            [self addGestureRecognizer:_tapGesture];
            
            UIImage *image = [[UIImage imageNamed:@"chevron_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            button.frame = CGRectMake(0, 0, image.size.width, self.leftCalloutAccessoryView.frame.size.height);
            [button setImage:image forState:UIControlStateNormal];
            button.userInteractionEnabled = NO;
            self.rightCalloutAccessoryView = button;
            
            if (selectedAnnotation.transportType == MKDirectionsTransportTypeWalking) {
                self.image = [UIImage imageNamed:@"WalkEndPointGray"];
            }
            else {
                self.image = [UIImage imageNamed:@"CarEndPointGray"];
            }
        }
        else {
            self.rightCalloutAccessoryView = nil;
            [self removeGestureRecognizer:_tapGesture];
            _tapGesture = nil;
        }
    }
    
    
}

- (void)addLeftCalloutAccessoryView {
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"TSSelectedDestinationLeftCalloutAccessoryView" owner:self options:nil];
    TSSelectedDestinationLeftCalloutAccessoryView *leftCalloutAccessoryView = views[0];
    self.leftCalloutAccessoryView = leftCalloutAccessoryView;
}

@end
