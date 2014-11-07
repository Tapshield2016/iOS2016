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
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.0f;
    
    _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:type]];
    _iconView.frame = CGRectMake(0, 0, 60, self.frame.size.height);
    _iconView.contentMode = UIViewContentModeCenter;
    [self addSubview:_iconView];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, self.frame.size.width - 60, self.frame.size.height)];
    _label.text = title;
    _label.font = [UIFont fontWithName:kFontWeightLight size:16];
    _label.textColor = [UIColor whiteColor];
    [self addSubview:_label];
    
    if (type == k911Icon) {
        [self setBackgroundImage:[UIImage imageFromColor:[TSColorPalette alertRed]] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageFromColor:[[TSColorPalette alertRed] colorWithAlphaComponent:0.5]] forState:UIControlStateHighlighted];
        self.layer.borderColor = [[TSColorPalette alertRed]  CGColor];
    }
    else {
        [self setBackgroundImage:[UIImage imageFromColor:[[TSColorPalette blackColor] colorWithAlphaComponent:0.5]] forState:UIControlStateHighlighted];
    }
}

@end
