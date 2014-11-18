//
//  TSEntourageMemberSettingsViewController.m
//  TapShield
//
//  Created by Adam Share on 11/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEntourageMemberSettingsViewController.h"

static NSString * const kDefaultImage = @"user_default_icon";
static NSString * const kNoUserFound = @"Real-time location sharing is only available to verified TapShield users";

@interface TSEntourageMemberSettingsViewController ()

@property (strong, nonatomic) UIButton *inviteButton;

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
    
    label.text = kNoUserFound;//[NSString stringWithFormat:@"No users with %@ could be found.", emailOrPhone];
    
    [view addSubview:label];
    
    
    _inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_inviteButton setBackgroundImage:[UIImage imageFromColor:[TSColorPalette tapshieldBlue]] forState:UIControlStateNormal];
    [_inviteButton setTitle:@"Invite" forState:UIControlStateNormal];
    _inviteButton.frame = CGRectMake(20, view.frame.size.height/2 + 10, view.frame.size.width-40, view.frame.size.height/2 - 20);
    _inviteButton.layer.cornerRadius = 5;
    _inviteButton.layer.masksToBounds = YES;
    [_inviteButton addTarget:self action:@selector(inviteMember) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:_inviteButton];
}

- (void)inviteMember {
    
    _inviteButton.enabled = NO;
    
    if (_member.phoneNumber && _member.email) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invite by" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self presentInvitationEmail];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Text" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self presentInvitationText];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            _inviteButton.enabled = YES;
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if (_member.phoneNumber) {
        [self presentInvitationText];
    }
    else if (_member.email) {
        [self presentInvitationEmail];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    _inviteButton.enabled = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    _inviteButton.enabled = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentInvitationEmail {
    
    NSString *emailTitle = @"Join me";
    // Email Content
    NSString *messageBody = @"Join my Entourage on TapShield - https://www.tapshield.com";
    // To address
    
    NSArray *toRecipents = @[_member.email];
    
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    [[UIView appearanceWhenContainedIn:[MFMailComposeViewController class], nil] setTintColor:[TSColorPalette tapshieldBlue]];
    mc.view.tintColor = [TSColorPalette tapshieldBlue];
    mc.navigationBar.tintColor = [TSColorPalette tapshieldBlue];
    [mc.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [mc.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    mc.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue], NSFontAttributeName : [UIFont fontWithName:kFontWeightNormal size:17.0f] };
    
    [self presentViewController:mc animated:YES completion:nil];
}

- (void)presentInvitationText {
    
    NSString *emailTitle = @"Join me";
    // Email Content
    NSString *messageBody = @"Join my Entourage on TapShield - https://www.tapshield.com";
    // To address
    
    NSArray *toRecipents = @[_member.phoneNumber];
    
    
    MFMessageComposeViewController *messageComposeVC = [[MFMessageComposeViewController alloc] init];
    messageComposeVC.messageComposeDelegate = self;
    [messageComposeVC setSubject:emailTitle];
    [messageComposeVC setBody:messageBody];
    [messageComposeVC setRecipients:toRecipents];
    // Present mail view controller on screen
    
    [[UIView appearanceWhenContainedIn:[MFMessageComposeViewController class], nil] setTintColor:[TSColorPalette tapshieldBlue]];
    messageComposeVC.view.tintColor = [TSColorPalette tapshieldBlue];
    messageComposeVC.navigationBar.tintColor = [TSColorPalette tapshieldBlue];
    [messageComposeVC.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [messageComposeVC.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    messageComposeVC.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue], NSFontAttributeName : [UIFont fontWithName:kFontWeightNormal size:17.0f] };
    
    [self presentViewController:messageComposeVC animated:YES completion:nil];
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
        [[TSJavelinAPIClient sharedClient] syncEntourageMembers:[TSJavelinAPIClient loggedInUser].entourageMembers.allValues completion:nil];
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
