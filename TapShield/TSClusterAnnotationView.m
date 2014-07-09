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
        self.centerOffset = CGPointMake(0, -self.image.size.height / 2);
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
        self.image = [UIImage imageNamed:@"pins_highfever_red"];
    }
    else if([clusterAnnotation.groupTag isEqualToString:kTYPESocialReport]){
        self.image = [UIImage imageNamed:@"pins_highfever_blue"];
    }
    clusterAnnotation.title = clusterAnnotation.groupTag;
}

@end
