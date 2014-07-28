//
//  TSClusterAnnotationView.m
//  TapShield
//
//  Created by Adam Share on 7/9/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSClusterAnnotationView.h"
#import "TSSpotCrimeAnnotation.h"
#import "ADClusterAnnotation.h"

@implementation TSClusterAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.image = [UIImage imageNamed:@"pins_cluster_red"];
        self.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
        CGRect frame = CGRectMake(0, 8, self.image.size.width, self.image.size.height/3);
        self.label = [[UILabel alloc] initWithFrame:frame];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [TSColorPalette alertRed];
        self.label.font = [UIFont systemFontOfSize:10];
        
        [self addSubview:self.label];
    }
    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    
    [super setAnnotation:annotation];
    
    ((ADClusterAnnotation *)annotation).annotationView = self;
    
    [self refreshView];
}

- (void)refreshView {
    
    ADClusterAnnotation *clusterAnnotation = (ADClusterAnnotation *)self.annotation;
    
    int count = 0;
    if (clusterAnnotation.cluster) {
        count = clusterAnnotation.originalAnnotations.count;
    }
    // set title
    clusterAnnotation.title = [NSString stringWithFormat:@"Contains %i annotations", count];
//    clusterAnnotation.subtitle = [NSString stringWithFormat:@"Containing annotations: %zd", count];
    
    // change pin image for group
//    if ([clusterAnnotation. isEqualToString:kTYPESpotCrime]) {
//        self.layer.borderColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.7].CGColor;
//    }
//    else if([clusterAnnotation.groupTag isEqualToString:kTYPESocialReport]){
//        self.layer.borderColor = [[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.7].CGColor;
//    }
    
//    dispatch_async(dispatch_get_main_queue(), ^{
        CATransition *animation = [CATransition animation];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = kCATransitionFade;
        animation.duration = 0.5;
        [self.label.layer addAnimation:animation forKey:@"kCATransitionFade"];
        
        self.label.text = [NSString stringWithFormat:@"%i", count];
//    });
    
//    clusterAnnotation.title = clusterAnnotation.groupTag;
    
    self.accessibilityLabel = @"Map annotation cluster";
}

@end
