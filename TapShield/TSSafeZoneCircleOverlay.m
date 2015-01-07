//
//  TSSafeAreaCircle.m
//  TapShield
//
//  Created by Adam Share on 12/16/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSSafeZoneCircleOverlay.h"
#import "TSFont.h"
#import "TSColorPalette.h"

@implementation TSSafeZoneCircleOverlay

- (TSSafeCircleRenderer *)renderer {
    
    if (!_renderer) {
        _renderer = [[TSSafeCircleRenderer alloc] initWithCircle:self];
        
        _renderer.lineWidth = 2;
        
        _renderer.lineWidth = 1;
        
        if (!self.inside) {
            _renderer.fillColor = [[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.3];
            _renderer.strokeColor = [[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.6];
        }
        else {
            _renderer.fillColor = [[TSColorPalette TSGreenColor] colorWithAlphaComponent:0.3];
            _renderer.strokeColor = [[TSColorPalette TSDarkGreenColor] colorWithAlphaComponent:0.6];
        }
    }
    
    return _renderer;
}

- (void)setInside:(BOOL)inside {
    
    if (_inside == inside) {
        return;
    }
    
    _inside = inside;
    
    if (!self.inside) {
        [_timer invalidate];
        _timer = nil;
        
        _renderer.fillColor = [[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.3];
        _renderer.strokeColor = [[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.6];
    }
    else {
        _countdown = 10;
        _renderer.fillColor = [[TSColorPalette TSGreenColor] colorWithAlphaComponent:0.3];
        _renderer.strokeColor = [[TSColorPalette TSDarkGreenColor] colorWithAlphaComponent:0.6];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_timer invalidate];
            _timer = nil;
            
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(fire)
                                                    userInfo:nil
                                                     repeats:YES];
            _timer.tolerance = 0.1;
        }];
    }
    
    [_renderer setNeedsDisplay];
}

- (void)fire {
    
    if (_countdown) {
        _countdown--;
    }
    
    if (!_inside) {
        [_timer invalidate];
        _timer = nil;
    }
    
    [_renderer setNeedsDisplay];
}

@end


@implementation TSSafeCircleRenderer


-(void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    TSSafeZoneCircleOverlay *circle = (TSSafeZoneCircleOverlay *)self.circle;
    
    NSString *text = @"Safe Zone";
    if (circle.inside) {
        text = [NSString stringWithFormat:@"Arrived In: %lu", (unsigned long)circle.countdown];
        
        if (!circle.countdown) {
            text = @"Arrived";
        }
    }
    
    [super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
    
    
    
    
    UIGraphicsPushContext(context);
    CGContextSaveGState(context);
    [[UIColor blueColor] set];
    
    UIColor *fill;
    UIColor *stroke;
    
    if (circle.mapView.mapType == MKMapTypeStandard) {
        fill = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        stroke = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    }
    else {
        fill = [UIColor whiteColor];
        stroke = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    }
    
   
    
    NSDictionary *fontAttributes = @{NSFontAttributeName:[UIFont fontWithName:kFontWeightBold size:60],
                                     NSForegroundColorAttributeName:fill,
                                     NSStrokeWidthAttributeName: [NSNumber numberWithFloat:-6.0],
                                     NSStrokeColorAttributeName:stroke,
                                     };
    
    CGSize size = [text sizeWithAttributes:fontAttributes];
    CGFloat height = ceilf(size.height);
    CGFloat width  = ceilf(size.width);
    
    CGRect circleRect = [self rectForMapRect:[self.overlay boundingMapRect]];
    CGPoint center = CGPointMake(circleRect.origin.x + circleRect.size.width /2, circleRect.origin.y + circleRect.size.height /2);
    CGPoint textstart = CGPointMake(center.x - width/2, center.y + center.y/4 - height /2 );
    
    [text drawAtPoint:textstart withAttributes:fontAttributes];
    
    CGContextRestoreGState(context);
    UIGraphicsPopContext();
}

@end
