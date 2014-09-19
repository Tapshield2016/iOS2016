//
//  TSBaseTextView.m
//  TapShield
//
//  Created by Adam Share on 5/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseTextView.h"
#import "TSColorPalette.h"

@interface TSBaseTextView ()

@property (unsafe_unretained, nonatomic, readonly) NSString* realText;
@property (strong, nonatomic) UILabel *placeholderLabel;

@end

@implementation TSBaseTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self awakeFromNib];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}


- (void)awakeFromNib {
    
    self.layer.cornerRadius = 5;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = .5;
    self.tintColor = [TSColorPalette tapshieldBlue];
    
    _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _placeholderLabel.userInteractionEnabled = NO;
    _placeholderLabel.textColor = _placeholderColor;
    [self addSubview:_placeholderLabel];
    
    self.placeholderColor = [UIColor lightGrayColor];
}

#pragma mark - Setter/Getters

- (void) setPlaceholder:(NSString *)aPlaceholder {
    
    float offset = 6;
    CGRect frame = CGRectMake(self.textContainerInset.left+offset, self.textContainerInset.top, self.frame.size.width - (self.textContainerInset.left+offset) - (self.textContainerInset.right+offset), self.frame.size.height - self.textContainerInset.top - self.textContainerInset.bottom);
    _placeholderLabel.frame = frame;
    _placeholderLabel.text = aPlaceholder;
    _placeholderLabel.backgroundColor = [UIColor clearColor];
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.font = self.font;
    [_placeholderLabel sizeToFit];
    
    if (!self.delegate) {
        self.delegate = self;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    [self text];
}

- (void)setFont:(UIFont *)font {
    
    [super setFont:font];
    
    _placeholderLabel.font = font;
}

- (void)setPlaceholderColor:(UIColor *)aPlaceholderColor {
    _placeholderColor = aPlaceholderColor;
    
    _placeholderLabel.textColor = _placeholderColor;
}

- (NSString *)text {
    NSString *text = [super text];
    
    if ([text isEqualToString:@""] || !text) {
        _placeholderLabel.hidden = NO;
    }
    else {
        _placeholderLabel.hidden = YES;
    }
    
    return text;
}

- (void) setText:(NSString *)text {
    
    if ([text isEqualToString:@""] || !text) {
        _placeholderLabel.hidden = NO;
    }
    else {
        _placeholderLabel.hidden = YES;
    }
    
    super.text = text;
}

@end
