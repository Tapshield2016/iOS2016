//
//  TSEntourageMemberSettingsViewController.m
//  TapShield
//
//  Created by Adam Share on 11/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEntourageMemberSettingsViewController.h"

static NSString * const kDefaultImage = @"user_default_icon";

@interface TSEntourageMemberSettingsViewController ()

@end

@implementation TSEntourageMemberSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (_member) {
        [self setMember:_member];
    }
    
    CGRect viewFrame = CGRectMake(0, 0, self.view.frame.size.width, 44);
//    UIView *view = [[UIView alloc] initWithFrame:viewFrame];
//    view.backgroundColor = [UIColor clearColor];
    
    UIImageView *contactImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 3, 38, 38)];
    contactImageView.layer.cornerRadius = contactImageView.frame.size.width/2;
    contactImageView.layer.masksToBounds = YES;
    contactImageView.layer.borderWidth = 1.0;
    contactImageView.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    if (_member.image) {
        contactImageView.image = _member.image;
    }
    else {
        contactImageView.image = [UIImage imageNamed:kDefaultImage];
    }
    
    CGRect labelFrame = CGRectMake(48, 0, 200, 44);
    UILabel *contactNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    contactNameLabel.textColor = [UIColor darkTextColor];
    contactNameLabel.font = [TSFont fontWithName:kFontWeightThin size:18];
    contactNameLabel.text = _member.name;
    
    [contactNameLabel sizeToFit];
    labelFrame.size.width = contactNameLabel.frame.size.width;
    contactNameLabel.frame = labelFrame;
    
//    [view addSubview:contactImageView];
//    [view addSubview:contactNameLabel];
//    
//    viewFrame.size.width = contactNameLabel.frame.origin.x + contactNameLabel.frame.size.width;
//    view.frame = viewFrame;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:contactImageView];
    self.navigationItem.leftBarButtonItem = item;
    self.navigationItem.titleView = contactNameLabel;
    
//    [self.navigationItem setTitleView:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    TSAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    [delegate shiftStatusBarToPane:NO];
}

- (void)setMember:(TSJavelinAPIEntourageMember *)member {
    
    _member = member;
    
    _alert911Switch.on = member.notifyCalled911;
    _alertArrivalSwitch.on = member.notifyArrival;
    _alertNonArrivalSwitch.on = member.notifyNonArrival;
    _alertYankSwitch.on = member.notifyYank;
    _alwaysVisibleSwitch.on = member.alwaysVisible;
    _trackSessionSwitch.on = member.trackRoute;
}

- (BOOL)changesMade {
    
    NSArray *bools = @[@(_member.notifyCalled911),
                       @(_member.notifyArrival),
                       @(_member.notifyNonArrival),
                       @(_member.notifyYank),
                       @(_member.alwaysVisible),
                       @(_member.trackRoute)];
    
    NSArray *switches = @[@(_alert911Switch.on),
                       @(_alertArrivalSwitch.on),
                       @(_alertNonArrivalSwitch.on),
                       @(_alertYankSwitch.on),
                       @(_alwaysVisibleSwitch.on),
                       @(_trackSessionSwitch.on)];
    
    for (int i = 0; i < switches.count; i++) {
        if (bools[i] != switches[i]) {
            return YES;
        }
    }
    
    return NO;
}

- (IBAction)done:(id)sender {
    
    if ([self changesMade]) {
        _member.notifyCalled911 =_alert911Switch.on;
        _member.notifyArrival = _alertArrivalSwitch.on;
        _member.notifyNonArrival = _alertNonArrivalSwitch.on;
        _member.notifyYank = _alertYankSwitch.on;
        _member.alwaysVisible = _alwaysVisibleSwitch.on;
        _member.trackRoute = _trackSessionSwitch.on;
        
        [[TSJavelinAPIClient loggedInUser] updateEntourageMember:_member];
        [[[TSJavelinAPIClient sharedClient] authenticationManager] archiveLoggedInUser];
        [[TSJavelinAPIClient sharedClient] syncEntourageMembers:[TSJavelinAPIClient loggedInUser].entourageMembers completion:nil];
    }
    
    TSAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate shiftStatusBarToPane:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
