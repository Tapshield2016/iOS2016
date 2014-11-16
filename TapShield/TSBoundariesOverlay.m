//
//  TSBoundariesOverlay.m
//  TapShield
//
//  Created by Adam Share on 7/15/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBoundariesOverlay.h"
#import "UIImage+Resize.h"
#import "TSColorPalette.h"

@implementation TSBoundariesOverlay

- (instancetype)initWithPolygon:(MKPolygon *)polygon agency:(TSJavelinAPIAgency *)agency region:(TSJavelinAPIRegion *)region
{
    self = [super initWithPolygon:polygon];
    if (self) {
        self.alpha = 0.5;
        self.lineWidth = 2.0;
        self.image = agency.theme.mapOverlayLogo;
        
        UIColor *color = agency.theme.secondaryColor;
        if (!color) {
            color = [TSColorPalette randomColor];
        }
        
        if (region) {
            if (![region openCenterToReceive:[agency openDispatchCenters]]) {
                color = [TSColorPalette darkGrayColor];
            }
        }
        
        self.strokeColor = [TSColorPalette colorByAdjustingColor:color Alpha:1.0f];
        self.fillColor = [TSColorPalette colorByAdjustingColor:color Alpha:0.5f];
    }
    return self;
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    
    [super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
    
    if (_image) {
        CGImageRef imageReference = _image.CGImage;
        
        MKMapRect theMapRect = [self.overlay boundingMapRect];
        
        MKMapPoint point = MKMapPointMake(MKMapRectGetMidX(theMapRect), MKMapRectGetMidY(theMapRect));
        float widthByHeight = _image.size.width/_image.size.height;
        float heightByWidth = _image.size.height/_image.size.width;
        
        
        float newHeight = theMapRect.size.height/2;
        if (newHeight > 3000) {
            newHeight = 3000;
        }
        float newWidth = newHeight*widthByHeight;
        
        if (newWidth > theMapRect.size.width/2) {
            newWidth = theMapRect.size.width/2;
            newHeight = newWidth * heightByWidth;
        }
        
        theMapRect = MKMapRectMake(point.x - newWidth/2, point.y - newHeight/2, newWidth, newHeight);
        
        CGRect theRect = [self rectForMapRect:theMapRect];
        CGRect orignalRect = [self rectForMapRect:[self.overlay boundingMapRect]];
        
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextTranslateCTM(context, 0.0, -orignalRect.size.height);
        
        CGContextDrawImage(context, theRect, imageReference);
    }
}

@end
