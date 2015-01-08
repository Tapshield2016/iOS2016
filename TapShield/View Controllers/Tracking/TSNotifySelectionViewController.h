//
//  TSNotifySelectionViewController.h
//  TapShield
//
//  Created by Adam Share on 4/6/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TSHomeViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "TSPopUpWindow.h"

#define INSET 50

@interface TSNotifySelectionViewController : TSBaseViewController <TSPopUpWindowDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *circleContainerView;
@property (weak, nonatomic) IBOutlet UIView *insideView;

@property (assign, nonatomic) NSTimeInterval estimatedTimeInterval;
@property (assign, nonatomic) NSTimeInterval timeAdjusted;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *effectView;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@property (weak, nonatomic) IBOutlet UIView *roundedRect;
@property (strong, nonatomic) TSBaseLabel *addressLabel;
@property (strong, nonatomic) TSBaseLabel *etaLabel;
@property (strong, nonatomic) TSBaseLabel *timeAdjustLabel;
- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;

@end
