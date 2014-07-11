//
//  TSClusterAnnotationView.m
//  TapShield
//
//  Created by Adam Share on 7/9/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSClusterAnnotationView.h"
#import "TSSpotCrimeAnnotation.h"
#import "OCAnnotation.h"

@implementation TSClusterAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
//        self.image = [UIImage imageNamed:@"red_bumper"];
//        self.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
//        CGRect frame = CGRectMake(0, 0, self.image.size.width/2, self.image.size.height/2);
//        self.label = [[UILabel alloc] initWithFrame:frame];
        
        self.frame = CGRectMake(0, 0, 40, 40);
        self.label = [[UILabel alloc] initWithFrame:self.frame];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [TSColorPalette listCellTextColor];
        self.label.center = self.center;
        self.label.font = [UIFont systemFontOfSize:10];
        [self addSubview:self.label];
        
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        self.layer.borderWidth = 2.0;
        self.layer.cornerRadius = self.frame.size.width/2;
//        self.layer.shadowRadius = 10.0f;
//        self.layer.shadowOpacity = 1.0;
//        self.layer.shadowOffset = CGSizeZero;
        
    }
    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    
    [super setAnnotation:annotation];
    
    OCAnnotation *clusterAnnotation = (OCAnnotation *)annotation;
    
    // set title
    clusterAnnotation.title = @"Cluster";
    clusterAnnotation.subtitle = [NSString stringWithFormat:@"Containing annotations: %zd", [clusterAnnotation.annotationsInCluster count]];
    
    // change pin image for group
    if ([clusterAnnotation.groupTag isEqualToString:kTYPESpotCrime]) {
        self.layer.borderColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.7].CGColor;
    }
    else if([clusterAnnotation.groupTag isEqualToString:kTYPESocialReport]){
        self.layer.borderColor = [[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.7].CGColor;
    }
    
    self.label.text = [NSString stringWithFormat:@"%i", clusterAnnotation.annotationsInCluster.count];
    
    clusterAnnotation.title = clusterAnnotation.groupTag;
}

@end
