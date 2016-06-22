//
//  TSBasicInfoViewController.h
//  TapShield
//
//  Created by Adam Share on 4/15/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"

@interface TSBasicInfoViewController : TSBaseViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) TSJavelinAPIUserProfile *userProfile;

@end
