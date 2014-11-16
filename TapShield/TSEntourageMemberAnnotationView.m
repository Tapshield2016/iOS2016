//
//  TSEntourageMemberAnnotationView.m
//  
//
//  Created by Adam Share on 11/14/14.
//
//

#import "TSEntourageMemberAnnotationView.h"
#import "TSEntourageMemberAnnotation.h"
#import "UIImage+Resize.h"

@interface TSEntourageMemberAnnotationView ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *nameLabel;

@end

@implementation TSEntourageMemberAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.image = [UIImage imageNamed:@"user_icon"];
        self.accessibilityLabel = @"Entourage member location";
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 1.0f;
        self.layer.shadowOpacity = 1;
        self.layer.shadowOffset = CGSizeZero;
        
        [self setCanShowCallout:YES];
    }
    return self;
    
}

- (void)setAnnotation:(TSEntourageMemberAnnotation *)annotation {
    
    [super setAnnotation:annotation];
    
    UIImage *image = annotation.member.image;
    self.accessibilityLabel = [NSString stringWithFormat:@"%@'s current location", annotation.member.name];
    if (image) {
        CGSize size = self.image.size;
        size.height = size.height;
        size.width = size.height;
        
        [_imageView removeFromSuperview];
        _imageView = [[UIImageView alloc] initWithImage:[[image imageWithRoundedCornersRadius:image.size.height/2] resizeToSize:size]];
        _imageView.layer.cornerRadius = _imageView.frame.size.height/2;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        self.frame = _imageView.bounds;
        self.layer.cornerRadius = _imageView.frame.size.height/2;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 2.0f;
    }
    else {
        
        if (!_nameLabel) {
            _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _nameLabel.font = [UIFont fontWithName:kFontWeightLight size:12];
            _nameLabel.textColor = [UIColor whiteColor];
            _nameLabel.textAlignment = NSTextAlignmentCenter;
            _nameLabel.layer.shadowColor = [UIColor blackColor].CGColor;
            _nameLabel.layer.shadowRadius = 1.0f;
            _nameLabel.layer.shadowOpacity = 0.5;
            _nameLabel.layer.shadowOffset = CGSizeZero;
        }
        
        NSString *initials;
        
        if (annotation.member.first && annotation.member.last) {
            NSString *firstInitial = [annotation.member.first substringToIndex:1];
            NSString *lastInital = [annotation.member.last substringToIndex:1];
            initials = [NSString stringWithFormat:@"%@%@", [firstInitial uppercaseString], [lastInital uppercaseString]];
        }
        else {
            initials = [[annotation.member.name substringToIndex:1] uppercaseString];
        }
        
        _nameLabel.text = initials;
        _nameLabel.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
        
        if (!_nameLabel.superview) {
            [self addSubview:_nameLabel];
        }
    }
}
@end
