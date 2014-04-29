//
//  TSIntroSlideViewController.h
//  TapShield
//
//  Created by Adam Share on 4/29/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"

#define INTRO_PAGECOUNT 5
#define INTRO_PAGESTART 2

@interface TSIntroSlideViewController : TSBaseViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet TSBaseLabel *label;

@property (assign, nonatomic) NSUInteger pageNumber;

@end
