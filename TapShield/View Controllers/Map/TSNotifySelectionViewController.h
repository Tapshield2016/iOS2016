//
//  TSNotifySelectionViewController.h
//  TapShield
//
//  Created by Adam Share on 4/6/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TSHomeViewController.h"

@interface TSNotifySelectionViewController : TSNavigationViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *routeInfoView;

@property (nonatomic, strong) TSHomeViewController *homeViewController;
@property (strong, nonatomic) NSString *addressString;
@property (strong, nonatomic) NSString *etaString;
@property (strong, nonatomic) TSBaseLabel *addressLabel;
@property (strong, nonatomic) TSBaseLabel *etaLabel;
@property (strong, nonatomic) UIView *containerView;

@end
