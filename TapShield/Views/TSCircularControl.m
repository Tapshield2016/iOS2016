//
//  TSCircularControl.m
//  TapShield
//
//  Created by Adam Share on 4/24/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSCircularControl.h"
#import "TSColorPalette.h"

/** Helper Functions **/
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

/** Parameters **/
#define TB_SAFEAREA_PADDING 40


#pragma mark - Private -

@interface TSCircularControl ()

@property (assign, nonatomic) int radius;

@end


#pragma mark - Implementation -

@implementation TSCircularControl

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self){
        self.opaque = NO;
        
        //Define the circle radius taking into account the safe area
        _radius = self.frame.size.width/2 - TB_SAFEAREA_PADDING;
        
        //Initialize the Angle at 0
        self.angle = 270;
        
        [self initVibrantCircle];
    }
    
    return self;
}

- (void)initVibrantCircle {
    
    float circlePadding = 10;
    CGRect circleframe = CGRectMake(0.0, 0.0, self.frame.size.width - TB_SAFEAREA_PADDING*2, self.frame.size.width - TB_SAFEAREA_PADDING*2);
    CGRect vibrancyFrame = circleframe;
    vibrancyFrame.size.height += circlePadding;
    vibrancyFrame.size.width += circlePadding;
    
    UIVisualEffectView *vibrancyView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]]];
    vibrancyView.frame = vibrancyFrame;
    vibrancyView.userInteractionEnabled = NO;
    vibrancyView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    UIView *insideView = [[UIView alloc] initWithFrame:circleframe];
    insideView.center = CGPointMake(vibrancyView.frame.size.width/2, vibrancyView.frame.size.height/2);
    [insideView.layer addSublayer:[self circleLayerWithFill:[UIColor clearColor] stroke:[UIColor whiteColor] bounds:insideView.bounds]];
    
    [vibrancyView.contentView addSubview:insideView];
    
    [self insertSubview:vibrancyView atIndex:0];
}

- (CAShapeLayer *)circleLayerWithFill:(UIColor *)fillColor stroke:(UIColor *)strokeColor bounds:(CGRect)bounds {
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    
    [circleLayer setBounds:bounds];
    [circleLayer setPosition:CGPointMake(CGRectGetMidX(bounds),CGRectGetMidY(bounds))];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:bounds];
    
    [circleLayer setPath:[path CGPath]];
    
    [circleLayer setStrokeColor:[strokeColor CGColor]];
    
    [circleLayer setLineWidth:LINE_WIDTH];
    
    [circleLayer setFillColor:[fillColor CGColor]];
    
    return circleLayer;
}

#pragma mark - Time Adjust

- (void)setDegreeForStartTime:(NSTimeInterval)startTime currentTime:(NSTimeInterval)currentTime {
    
    float percentDone = currentTime/startTime;
    float rawAngle = percentDone * 180;
    self.angle = [self relativeAngle:rawAngle];;
    
    [self setNeedsDisplay];
}


#pragma mark - UIControl Override -

/** Tracking is started **/
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super beginTrackingWithTouch:touch withEvent:event];
    
    //We need to track continuously
    return YES;
}

/** Track continuos touch event (like drag) **/
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super continueTrackingWithTouch:touch withEvent:event];
    
    //Get touch location
    CGPoint lastPoint = [touch locationInView:self];
    
    //Use the location to design the Handle
    [self movehandle:lastPoint];
    
    //Control value has changed, let's notify that
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

/** Track is finished **/
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    
}

- (float)relativeAngle:(float)angle {
    
    if (angle <= 90) {
        return 90 - angle;
    }
    else {
        return 360 - angle + 90;
    }
}

#pragma mark - Drawing Functions -

//Use the draw rect to draw the Background, the Circle and the Handle
-(void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    
    float adjustedAngle = [self relativeAngle:self.angle];
    
    
    float plusMinus = adjustedAngle - 180;
    float absPlusMinus = fabsf(plusMinus);
    float plusMinusRatio = absPlusMinus/180;
    
    float red = 0;
    float green = 0;
    if (plusMinus < 0) {
        red = plusMinusRatio;
    }
    else {
        green = plusMinusRatio;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    /** Draw the Background **/
    
//    //Create the path
//    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, _radius, 0, M_PI *2, 0);
//    
//    //Set the stroke color to black
//    [[[UIColor whiteColor] colorWithAlphaComponent:0.2] setStroke];
//    
//    //Define line width and cap
//    CGContextSetLineWidth(ctx, LINE_WIDTH);
//    CGContextSetLineCap(ctx, kCGLineCapButt);
//    
//    //draw it!
//    CGContextDrawPath(ctx, kCGPathStroke);
    
    
    //** Draw the circle (using a clipped gradient) **/
    
    
    /** Create THE MASK Image **/
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef imageCtx = UIGraphicsGetCurrentContext();
    
    CGContextAddArc(imageCtx, self.frame.size.width/2  , self.frame.size.height/2, _radius, M_PI_2, ToRad(self.angle), 1);
    
    [[UIColor blueColor]set];
    
    //Use shadow to create the Blur effect
    CGContextSetShadowWithColor(imageCtx, CGSizeMake(0, 0), adjustedAngle/20 , [UIColor blackColor].CGColor);
    
    //define the path
    CGContextSetLineWidth(imageCtx, LINE_WIDTH + 1);
    CGContextDrawPath(imageCtx, kCGPathStroke);
    
    //save the context content into the image mask
    CGImageRef mask = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    
    
    
    /** Clip Context to the mask **/
    CGContextSaveGState(ctx);
    
    CGContextClipToMask(ctx, self.bounds, mask);
    CGImageRelease(mask);
    
    
    
    /** THE GRADIENT **/
    const CGFloat *tapshieldBlue = CGColorGetComponents(UIColorFromRGB(0x07304b).CGColor);
    const CGFloat *tapshieldDarkBlue = CGColorGetComponents(UIColorFromRGB(0x07304b).CGColor);
    
    //list of components
    CGFloat components[8] = {
        tapshieldDarkBlue[0] + red,
        tapshieldDarkBlue[1] - red,
        tapshieldDarkBlue[2] - red,
        tapshieldDarkBlue[3],
        tapshieldBlue[0],
        tapshieldBlue[1] + green,
        tapshieldBlue[2],
        tapshieldBlue[3]};
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    //Gradient direction
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    //Draw the gradient
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    
    CGContextRestoreGState(ctx);
    
    
    /** Add some light reflection effects on the background circle**/
    
    CGContextSetLineWidth(ctx, 1);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    //Draw the outside light
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, self.frame.size.width/2  , self.frame.size.height/2, _radius+BACKGROUND_WIDTH/2, M_PI_2, ToRad(self.angle), 1);
    [[UIColor colorWithWhite:1.0 alpha:0.05]set];
    CGContextDrawPath(ctx, kCGPathStroke);
    
    //draw the inner light
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, self.frame.size.width/2  , self.frame.size.height/2, _radius-BACKGROUND_WIDTH/2, M_PI_2, ToRad(self.angle), 1);
    [[UIColor colorWithWhite:1.0 alpha:0.05]set];
    CGContextDrawPath(ctx, kCGPathStroke);
    
    
    /** Draw the handle **/
    [self drawTheHandle:ctx];
    
}

/** Draw a white knob over the circle **/
- (void) drawTheHandle:(CGContextRef)ctx{
    
    CGContextSaveGState(ctx);
    
    //I Love shadows
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 3, [UIColor blackColor].CGColor);
    
    //Get the handle position
    CGPoint handleCenter =  [self originPointFromAngle: self.angle];
    
    //Draw It!
    [[UIColor colorWithWhite:1.0 alpha:1.0]set];
    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x, handleCenter.y, SELECTOR_SIZE, SELECTOR_SIZE));
    
    CGContextRestoreGState(ctx);
}


#pragma mark - Math -

/** Move the Handle **/
- (void)movehandle:(CGPoint)lastPoint{
    
    //Get the center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    //Calculate the direction from a center point and a arbitrary position.
    float currentAngle = AngleFromNorth(centerPoint, lastPoint, NO);
    int angleInt = floor(currentAngle);
    
    //Store the new angle
    self.angle = 360 - angleInt;
    
    //Redraw
    [self setNeedsDisplay];
}

/** Given the angle, get the point position on circumference **/
- (CGPoint)originPointFromAngle:(float)angleInt{
    
    //Circle bounds origin
    CGPoint originPoint = CGPointMake(self.frame.size.width/2  - SELECTOR_SIZE/2 + LINE_WIDTH/2, self.frame.size.height/2 - SELECTOR_SIZE/2 + LINE_WIDTH/2);
    
    //The point position on the circumference
    CGPoint result;
    result.y = round(originPoint.y + _radius * sin(ToRad(-angleInt))) ;
    result.x = round(originPoint.x + _radius * cos(ToRad(-angleInt)));
    
    return result;
}

//Sourcecode from Apple example clockControl
//Calculate the direction in degrees from a center point to an arbitrary position.
static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}

@end
