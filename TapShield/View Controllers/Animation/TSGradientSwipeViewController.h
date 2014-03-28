//
//
//  TSSlideUpControlCenterViewController
//

#import "TSBaseViewController.h"
#import "TSBaseLabel.h"

@interface TSGradientSwipeViewController : TSBaseViewController
{
    CGFloat gradientLocations[3];
}

@property (nonatomic) BOOL enabled;

// Access the UILabel, e.g. to change text or color
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) TSBaseLabel *label;
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, strong) NSString *titleText;
@property (nonatomic) int animationTimerCount;

- (id)initWithTitleText:(NSString *)titleText;
- (void)startAnimation;
- (void)stopAnimation;

@end


