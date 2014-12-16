//
//  TSMapOverlayCircle.m
//  TapShield
//
//  Created by Adam Share on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSMapOverlayCircle.h"
#import "UIView+FirstResponder.h"
#import "TSColorPalette.h"

#define MAX_RATIO 1.0
#define MIN_RATIO 0.01

#define ANIMATION_DURATION 3

//repeat forever
#define ANIMATION_REPEAT HUGE_VALF

@interface TSMapOverlayCircle ()

@property (nonatomic, assign) BOOL shouldRefresh;
@property (nonatomic, assign) BOOL shouldStop;

@property (nonatomic, assign) float ratio;
@property (nonatomic, strong) UIImage *nextImage;

@end

@implementation TSMapOverlayCircle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _shouldStop = YES;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    
    self.center = self.superview.contentCenter;
}

- (UIImage *)createImageWithColor:(UIColor *)color andFrame:(CGRect)frame {
    
    UIImage *image = [UIImage imageNamed:@"circle"];
    
    //image color change
    
    CGRect rect = CGRectMake(0, 0, frame.size.width, frame.size.width);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (context) {
        CGContextClipToMask(context, rect, image.CGImage);
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        image = [UIImage imageWithCGImage:img.CGImage
                                    scale:1.0
                              orientation: UIImageOrientationDownMirrored];
    }
    
    return image;
}

- (void)startAnimatingWithColor:(UIColor *)color andFrame:(CGRect)frame{
    
    frame = CGRectMake(0, 0, frame.size.width*1.3, frame.size.width*1.3);
    _nextImage = [self createImageWithColor:color andFrame:frame];
    
    if (_shouldStop) {
        _shouldStop = NO;
        [self refreshImage];
    }
    else {
        _shouldRefresh = YES;
    }
}

- (void)refreshImage {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _shouldRefresh = NO;
        self.image = _nextImage;
        self.frame = CGRectMake(0, 0, _nextImage.size.width, _nextImage.size.height);
        [self repeatingAnimation];
    }];
}

- (void)repeatingAnimation {
    
    self.alpha = 1.0;
    self.transform = CGAffineTransformMakeScale(MIN_RATIO, MIN_RATIO);
    
    [UIView animateWithDuration:ANIMATION_DURATION delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 0.0;
        self.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        if (_shouldRefresh) {
            [self refreshImage];
        }
        else if (!_shouldStop) {
            [self repeatingAnimation];
        }
    }];
}

-(void)stopAnimating {
    
    _shouldStop = YES;
    [self.layer removeAllAnimations];
}


@end
