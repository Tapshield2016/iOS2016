//
//  TSSlideUpControlCenterViewController
//  
//

#import <QuartzCore/QuartzCore.h>
#import "TSGradientSwipeViewController.h"
#import "TSRalewayFont.h"

static const CGFloat gradientWidth = 0.2;
static const CGFloat gradientDimAlpha = 0.3;
static const int animationFramesPerSec = 20;

@implementation TSGradientSwipeViewController

- (id)initWithTitleText:(NSString *)titleText {
    
    self = [super init];
    
    if (self) {
        self.titleText = titleText;
    }
    
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipe_arrows_icon"]];
    _imageView.contentMode = UIViewContentModeCenter;
    
    _label = [[TSBaseLabel alloc] initWithFrame:self.view.frame];
    _label.text = _titleText;
    _label.font = [UIFont fontWithName:kFontRalewayRegular size:18.0];
    
    _label.layer.delegate = self;
    _imageView.layer.delegate = self;
    
    [self.view addSubview:_label];
    [self.view addSubview:_imageView];
    
    self.enabled = YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
}


- (void)startAnimation {
    
    [self startTimer];
}

- (void)stopAnimation {
    
    [self stopTimer];
}


#pragma mark - Enabled

- (void) setEnabled:(BOOL)enabled {
    
    if (enabled) {
        [self startTimer];
    }
    else {
        [self stopTimer];
    }
}


#pragma mark - Timer

// animationTimer methods
- (void)animationTimerFired:(NSTimer*)theTimer
{
    // Let the timer run for 2 * FPS rate before resetting.
    // This gives one second of sliding the highlight off to the right, plus one
    // additional second of uniform dimness
    if (++_animationTimerCount == (2 * animationFramesPerSec)) {
        _animationTimerCount = 0;
    }
    
    // Update the gradient for the next frame
    [self setGradientLocations:((CGFloat)_animationTimerCount/(CGFloat)animationFramesPerSec)];
}

- (void) startTimer
{
    if (!_animationTimer) {
        
        _animationTimerCount = 0;
        [self setGradientLocations:0];
        _animationTimer = [NSTimer 
                           scheduledTimerWithTimeInterval:1.0/animationFramesPerSec
                           target:self 
                           selector:@selector(animationTimerFired:) 
                           userInfo:nil 
                           repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
    }
}

- (void) stopTimer
{
    if (_animationTimer) {
        [_animationTimer invalidate];
        _animationTimer = nil;
    }
}

#pragma mark - Gradient

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    
    if (layer == _label.layer) {
        UIGraphicsPushContext(context);
        
        // Set Text Matrix
        CGAffineTransform xform = CGAffineTransformMake(1.0,  0.0,
                                                        0.0, -1.0,
                                                        0.0,  0.0);
        CGContextSetTextMatrix(context, xform);
        
        CGContextSetTextDrawingMode(context, kCGTextFill); // This is the default
        [[UIColor whiteColor] setFill]; // This is the default
        
        CGContextSetTextDrawingMode (context, kCGTextClip);
        [_label.text drawAtPoint:CGPointMake(0.0f, 0.0f)
                  withAttributes:@{NSFontAttributeName:[UIFont fontWithName:_label.font.fontName
                                                                       size:_label.font.pointSize]
                                   }];
    }
    else {
        // Load image
        UIImage *image = _imageView.image;
        CGContextTranslateCTM(context, 0, image.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGContextSetBlendMode(context, kCGBlendModeMultiply);
        CGRect rect = CGRectMake(_label.frame.size.width - 35.0, -3.0f, image.size.width, image.size.height);
        CGContextClipToMask(context, rect, image.CGImage);
        CGContextSetFillColorWithColor(context, [[[UIColor whiteColor] colorWithAlphaComponent:0.0f] CGColor]);
        CGContextFillRect(context, rect);
    }
    
    
    // Get the foreground text color from the UILabel.
    // Note: UIColor color space may be either monochrome or RGB.
    // If monochrome, there are 2 components, including alpha.
    // If RGB, there are 4 components, including alpha.
    
    CGFloat r = (CGFloat) 1.0;
    CGFloat g = (CGFloat) 1.0;
    CGFloat b = (CGFloat) 1.0;
    CGFloat a = (CGFloat) 0.9;
    CGFloat comp[4] = {r,g,b,a};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef textColor = CGColorCreate(colorSpace, comp);
    CGColorSpaceRelease(colorSpace);
    const CGFloat *components = CGColorGetComponents(textColor);
    size_t numberOfComponents = CGColorGetNumberOfComponents(textColor);
    CGColorRelease(textColor);
    BOOL isRGB = (numberOfComponents == 4);
    CGFloat red = components[0];
    CGFloat green = isRGB ? components[1] : components[0];
    CGFloat blue = isRGB ? components[2] : components[0];
    CGFloat alpha = isRGB ? components[3] : components[1];
    size_t num_locations = 3;
    
    // The gradientComponents array is a 4 x 3 matrix. Each row of the matrix
    // defines the R, G, B, and alpha values to be used by the corresponding
    // element of the gradientLocations array
    CGFloat gradientComponents[12];
    for (int row = 0; row < num_locations; row++) {
        int index = 4 * row;
        gradientComponents[index++] = red;
        gradientComponents[index++] = green;
        gradientComponents[index++] = blue;
        gradientComponents[index] = gradientDimAlpha;
    }

    // If animating, set the center of the gradient to be bright (maximum alpha)
    // Otherwise it stays dim (as set above) leaving the text at uniform
    // dim brightness
    if (_animationTimer) {
        gradientComponents[7] = alpha;
    }
    
    // Load RGB Colorspace
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    // Create Gradient
    CGGradientRef gradient = CGGradientCreateWithColorComponents (colorspace, gradientComponents,
                                                                  gradientLocations, num_locations);
    // Draw the gradient (using label text as the clipping path)
    CGContextDrawLinearGradient (context, gradient, CGPointMake(_label.bounds.size.width, 0.0f), _label.bounds.origin, 0);
    
    // Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
}

- (void) setGradientLocations:(CGFloat) leftEdge
{
    // Subtract the gradient width to start the animation with the brightest 
    // part (center) of the gradient at left edge of the label text
    leftEdge -= gradientWidth;
    
    //position the bright segment of the gradient, keeping all segments within the range 0..1
    gradientLocations[0] = leftEdge < 0.0 ? 0.0 : (leftEdge > 1.0 ? 1.0 : leftEdge);
    gradientLocations[1] = MIN(leftEdge + gradientWidth, 1.0);
    gradientLocations[2] = MIN(gradientLocations[1] + gradientWidth, 1.0);
    
    // Re-render the label text
    [_label.layer setNeedsDisplay];
    [_imageView.layer setNeedsDisplay];
}


@end
