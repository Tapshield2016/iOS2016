//
//  TSBaseLabel.h
//  TapShield
//
//  Created by Adam Share on 3/20/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSFont.h"
#import "TSColorPalette.h"

@interface TSBaseLabel : UILabel

- (void)setText:(NSString *)text withAnimationType:(NSString *)type direction:(NSString *)direction duration:(float)duration;

@end
