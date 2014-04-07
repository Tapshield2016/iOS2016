//
//  TSNotifySelectionViewController.h
//  TapShield
//
//  Created by Adam Share on 4/6/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"

@interface TSNotifySelectionViewController : TSNavigationViewController

@property (weak, nonatomic) IBOutlet UIView *routeInfoView;

@property (strong, nonatomic) NSString *addressString;
@property (strong, nonatomic) NSString *etaString;
@property (strong, nonatomic) TSBaseLabel *addressLabel;
@property (strong, nonatomic) TSBaseLabel *etaLabel;
@property (strong, nonatomic) UIView *containerView;

@end
