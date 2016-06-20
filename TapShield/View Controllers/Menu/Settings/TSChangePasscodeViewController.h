//
//  TSChangePasscodeViewController.h
//  TapShield
//
//  Created by Adam Share on 5/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"

@interface TSChangePasscodeViewController : TSNavigationViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)forgotPassword:(id)sender;

@end
