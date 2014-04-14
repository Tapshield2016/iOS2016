//
//  TSUserAnnotationView.m
//  TapShield
//
//  Created by Adam Share on 4/3/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSUserAnnotationView.h"
#import "TSJavelinAPIClient.h"
#import "UIImage+Resize.h"

@implementation TSUserAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.image = [UIImage imageNamed:@"user_icon"];
        
        UIImage *image = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].userProfile.profileImage;
        if (image) {
            self.image = [image resizeToSize:self.image.size];
            self.layer.cornerRadius = self.image.size.height/2;
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.layer.borderWidth = 2.0f;
        }
        
        [self setCanShowCallout:YES];
    }
    return self;
    
}

@end
