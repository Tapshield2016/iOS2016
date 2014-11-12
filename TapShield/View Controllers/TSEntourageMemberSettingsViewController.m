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
    
    [self initBarViews];
    
    [self initInviteView];
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

- (void)initInviteView {
    
    if (_member.matchedUser) {
        return;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 56, self.view.frame.size.width, 127)];
    view.backgroundColor = [UIColor clearColor];
    
    
    UIVisualEffectView *visualEffect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEffect.frame = view.bounds;
    
    [view addSubview:visualEffect];
    [self.tableView addSubview:view];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, view.frame.size.width-40, view.frame.size.height/2)];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.textColor = [UIColor darkTextColor];
    label.font = [TSFont fontWithName:kFontWeightThin size:16];
    
    NSString *emailOrPhone;
    if (_member.phoneNumber) {
        emailOrPhone = [NSString stringWithFormat:@"phone number %@", _member.phoneNumber];
    }
    else {
        emailOrPhone = [NSString stringWithFormat:@"email %@", _member.email];
    }
    
    label.text = [NSString stringWithFormat:@"No users with %@ could be found.", emailOrPhone];
    
    [view addSubview:label];
}

- (void)initBarViews {
    
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
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:contactImageView];
    self.navigationItem.leftBarButtonItem = item;
    self.navigationItem.titleView = contactNameLabel;
}

- (void)setMember:(TSJavelinAPIEntourageMember *)member {
    
    _member = member;
    
    _alert911Switch.on = member.notifyCalled911;
    _alertArrivalSwitch.on = member.notifyArrival;
    _alertNonArrivalSwitch.on = member.notifyNonArrival;
    _alertYankSwitch.on = member.notifyYank;
    
    if (member.matchedUser) {
        _alwaysVisibleSwitch.on = member.alwaysVisible;
        _trackSessionSwitch.on = member.trackRoute;
        
        if (_alwaysVisibleSwitch.isOn) {
            [_trackSessionSwitch setOn:YES];
            [_trackSessionSwitch setEnabled:NO];
        }
        else {
            [_trackSessionSwitch setEnabled:YES];
        }
    }
    else {
        _alwaysVisibleSwitch.enabled = NO;
        _trackSessionSwitch.enabled = NO;
        _alwaysVisibleSwitch.on = YES;
        _trackSessionSwitch.on = YES;
    }
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

        if (!_member.matchedUser && i == 4) {
            break;
        }
        
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
        
        if (_member.matchedUser) {
            _member.alwaysVisible = _alwaysVisibleSwitch.on;
            _member.trackRoute = _trackSessionSwitch.on;
        }
        
        [[TSJavelinAPIClient loggedInUser] updateEntourageMember:_member];
        [[[TSJavelinAPIClient sharedClient] authenticationManager] archiveLoggedInUser];
        [[TSJavelinAPIClient sharedClient] syncEntourageMembers:[TSJavelinAPIClient loggedInUser].entourageMembers completion:nil];
    }
    
    TSAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate shiftStatusBarToPane:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)visibleSwitched:(UISwitch *)sender {
    
    if (sender.isOn) {
        [_trackSessionSwitch setOn:YES animated:YES];
        [_trackSessionSwitch setEnabled:NO];
    }
    else {
        [_trackSessionSwitch setEnabled:YES];
    }
}
@end
