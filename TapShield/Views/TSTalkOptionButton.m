//
//  TSTalkOptionButton.m
//  
//
//  Created by Adam Share on 11/6/14.
//
//

#import "UIImage+Color.h"
#import "TSTalkOptionButton.h"

NSString * const kChatIcon = @"alert_chat_icon";
NSString * const kPhoneIcon = @"phone_call";
NSString * const k911Icon = @"call_911";

@interface TSTalkOptionButton ()

@property (strong, nonatomic) UIVisualEffectView *vibrancyView;
@property (strong, nonatomic) UIView *insideView;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *label;


@end

@implementation TSTalkOptionButton

- (id)initWithFrame:(CGRect)frame imageType:(NSString *)type title:(NSString *)title
{
    self = [TSTalkOptionButton buttonWithType:UIButtonTypeCustom];
    if (self) {
        // Initialization code
        self.frame = frame;
        [self customizeButtonWithImageType:type title:title];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customizeButtonWithImageType:nil title:nil];
    }
    return self;
}


- (void)customizeButtonWithImageType:(NSString *)type title:(NSString *)title {
    
    float imageSize = 60;
    
    _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:type]];
    _iconView.frame = CGRectMake(0, 0, imageSize, self.frame.size.height);
    _iconView.contentMode = UIViewContentModeCenter;
    [self addSubview:_iconView];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(imageSize, 0, self.frame.size.width - imageSize*2, self.frame.size.height)];
    _label.text = title;
    _label.font = [UIFont fontWithName:kFontWeightLight size:16];
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.numberOfLines = 0;
    [self addSubview:_label];
    
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
    
    if (type == k911Icon) {
        [self setBackgroundImage:[UIImage imageFromColor:[TSColorPalette alertRed]] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageFromColor:[[TSColorPalette alertRed] colorWithAlphaComponent:0.5]] forState:UIControlStateHighlighted];
    }
    else {
        
        _vibrancyView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]]];
        _vibrancyView.frame = self.bounds;
        _vibrancyView.userInteractionEnabled = NO;
        _insideView = [[UIView alloc] initWithFrame:_vibrancyView.bounds];
        [_vibrancyView.contentView addSubview:_insideView];
        [self insertSubview:_vibrancyView atIndex:0];
        
        _insideView.layer.borderColor = [[UIColor whiteColor] CGColor];
        _insideView.layer.cornerRadius = 5.0f;
        _insideView.layer.masksToBounds = YES;
        _insideView.layer.borderWidth = 1.0f;
        
//        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(imageSize, 0, 1.0, self.frame.size.height)];
//        lineView.backgroundColor = [UIColor whiteColor];
//        [_vibrancyView.contentView addSubview:lineView];
        
        [self setBackgroundImage:[UIImage imageFromColor:[[TSColorPalette whiteColor] colorWithAlphaComponent:0.5]] forState:UIControlStateHighlighted];
    }
}

@end
