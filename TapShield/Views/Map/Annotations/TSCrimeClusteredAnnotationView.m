//
//  TSClusterAnnotationView.m
//  TapShield
//
//  Created by Adam Share on 7/9/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSCrimeClusteredAnnotationView.h"
#import "TSSpotCrimeAnnotation.h"
#import "ADClusterAnnotation.h"
#import "TSColorPalette.h"

@implementation TSCrimeClusteredAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.accessibilityValue = @"";
        self.accessibilityLabel = @"Map Annotation";
        
        self.image = [UIImage imageNamed:@"pins_cluster_red"];
        
        self.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
        CGRect frame = CGRectMake(0, 8, self.image.size.width, self.image.size.height/3);
        self.label = [[UILabel alloc] initWithFrame:frame];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [TSColorPalette alertRed];
        self.label.font = [UIFont systemFontOfSize:10];
        
        self.centerOffset = CGPointMake(0, -self.frame.size.height/2);
        
        
        self.canShowCallout = YES;
        
        [self addSubview:self.label];
        
        [self clusteringAnimation];
    }
    return self;
}

- (void)clusteringAnimation {
    
    ADClusterAnnotation *clusterAnnotation = (ADClusterAnnotation *)self.annotation;
    
    NSUInteger count = clusterAnnotation.clusterCount;
    self.label.text = [self numberLabelText:count];
}

- (NSString *)numberLabelText:(float)count {
    
    if (!count) {
        return nil;
    }
    
    if (count > 1000) {
        float rounded;
        if (count < 10000) {
            rounded = ceilf(count/100)/10;
            return [NSString stringWithFormat:@"%.1fk", rounded];
        }
        else {
            rounded = roundf(count/1000);
            return [NSString stringWithFormat:@"%luk", (unsigned long)rounded];
        }
    }
    
    return [NSString stringWithFormat:@"%lu", (unsigned long)count];
}

//- (void)clusteringAnimation {
//    
//    ADClusterAnnotation *clusterAnnotation = (ADClusterAnnotation *)self.annotation;
//    
//    NSUInteger count = 0;
//    if (clusterAnnotation.cluster) {
//        count = clusterAnnotation.originalAnnotations.count;
//    }
//    // set title
//    clusterAnnotation.title = [NSString stringWithFormat:@"Contains %lu annotations", (unsigned long)count];
////    clusterAnnotation.subtitle = [NSString stringWithFormat:@"Containing annotations: %zd", count];
//    
//    // change pin image for group
////    if ([clusterAnnotation. isEqualToString:kTYPESpotCrime]) {
////        self.layer.borderColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.7].CGColor;
////    }
////    else if([clusterAnnotation.groupTag isEqualToString:kTYPESocialReport]){
////        self.layer.borderColor = [[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.7].CGColor;
////    }
//    
////    dispatch_async(dispatch_get_main_queue(), ^{
////        CATransition *animation = [CATransition animation];
////        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
////        animation.type = kCATransitionFade;
////        animation.duration = 0.5;
////        [self.label.layer addAnimation:animation forKey:@"kCATransitionFade"];
//    
//        self.label.text = [NSString stringWithFormat:@"%lu", (unsigned long)count];
////    });
//    
////    clusterAnnotation.title = clusterAnnotation.groupTag;
//}

- (NSString *)accessibilityValue {
    
    return self.annotation.title;
}

@end
