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
        CGRect frame = CGRectMake(0, 0, self.image.size.width/2, self.image.size.height/2);
        self.label = [[UILabel alloc] initWithFrame:frame];
    }
    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    
    [super setAnnotation:annotation];
    
    ((ADClusterAnnotation *)annotation).annotationView = self;
    
//    ADClusterAnnotation *clusterAnnotation = (ADClusterAnnotation *)annotation;
    
//    // set title
//    clusterAnnotation.title = @"Cluster";
//    clusterAnnotation.subtitle = [NSString stringWithFormat:@"Containing annotations: %zd", [clusterAnnotation.annotationsInCluster count]];
    
    // change pin image for group
//    if ([clusterAnnotation. isEqualToString:kTYPESpotCrime]) {
//        self.layer.borderColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.7].CGColor;
//    }
//    else if([clusterAnnotation.groupTag isEqualToString:kTYPESocialReport]){
//        self.layer.borderColor = [[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.7].CGColor;
//    }
    
//    self.label.text = [NSString stringWithFormat:@"%i", clusterAnnotation.originalAnnotations.count];
//    
//    clusterAnnotation.title = clusterAnnotation.groupTag;
}

@end
