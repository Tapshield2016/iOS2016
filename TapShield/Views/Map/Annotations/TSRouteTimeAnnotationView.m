//
//  TSRouteTimeAnnotationView.m
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRouteTimeAnnotationView.h"
#import "TSRouteTimeAnnotation.h"

@implementation TSRouteTimeAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.font = [TSRalewayFont fontWithName:kFontRalewayRegular size:10.0f];
        self.label.textColor = [TSColorPalette whiteColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.label];
        [self setCanShowCallout:NO];
    }
    return self;
    
}

- (void)setupViewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[TSRouteTimeAnnotation class]]) {
        TSRouteTimeAnnotation *etaAnnotation = (TSRouteTimeAnnotation *)annotation;
        self.image = [etaAnnotation imageForAnnotationViewDirection];
        self.centerOffset = etaAnnotation.viewCenterOffset;
        self.label.text = etaAnnotation.title;
        self.label.frame = self.bounds;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
