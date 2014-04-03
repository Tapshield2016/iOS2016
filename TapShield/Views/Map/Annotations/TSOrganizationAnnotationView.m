//
//  TSOrganizationAnnotationView.m
//  TapShield
//
//  Created by Adam Share on 4/3/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSOrganizationAnnotationView.h"

@implementation TSOrganizationAnnotationView


- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/5)];
        self.label.font = [UIFont boldSystemFontOfSize:20];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 0;
        self.label.lineBreakMode = NSLineBreakByWordWrapping;
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor darkGrayColor];
        
        [self addSubview:self.label];
        self.frame = self.label.frame;
        self.alpha = 0.0f;
    }
    return self;
    
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
