//
//  TSUserLocationButton.m
//  TapShield
//
//  Created by Adam Share on 2/12/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSUserLocationButton.h"
#import "TSColorPalette.h"

@implementation TSUserLocationButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        UIImage *selectedImage = [UIImage imageNamed:@"location1"];
        
        
        //image color change
        
        CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClipToMask(context, rect, selectedImage.CGImage);
        CGContextSetFillColorWithColor(context, [[TSColorPalette tapshieldBlue] CGColor]);
        CGContextFillRect(context, rect);
        selectedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self setBackgroundImage:selectedImage forState:UIControlStateSelected];
        
        
        
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 1.0;
        self.clipsToBounds = NO;
        
    }
    return self;
}


@end
