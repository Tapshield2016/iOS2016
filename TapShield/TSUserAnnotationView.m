//
//  TSUserAnnotationView.m
//  TapShield
//
//  Created by Adam Share on 4/3/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSUserAnnotationView.h"
#import "TSJavelinAPIClient.h"
#import "TSJavelinAPIAuthenticationManager.h"
#import "UIImage+Resize.h"

@interface TSUserAnnotationView ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation TSUserAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.image = [UIImage imageNamed:@"user_icon"];
        self.accessibilityLabel = @"Your Location";
        
        [self setCanShowCallout:YES];
    }
    return self;
    
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    
    [super setAnnotation:annotation];
    
    UIImage *image = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].userProfile.profileImage;
    if (image) {
        CGSize size = self.image.size;
        size.height = size.height * 1.5;
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
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 1.0f;
        self.layer.shadowOpacity = 1;
        self.layer.shadowOffset = CGSizeZero;
    }
}

@end
