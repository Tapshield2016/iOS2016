//
//  TSTalkOptionViewController.m
//  
//
//  Created by Adam Share on 11/6/14.
//
//

#import "TSTalkOptionViewController.h"
#import "TSLocationController.h"
#import "TSTalkOptionButton.h"
#import "TSHomeViewController.h"
#import "UIView+FirstResponder.h"

@interface TSTalkOptionViewController ()

@property (strong, nonatomic) TSTalkOptionButton *chatButton;
@property (strong, nonatomic) TSTalkOptionButton *callButton;
@property (strong, nonatomic) TSTalkOptionButton *emergencyButton;

@property (strong, nonatomic) UIView *buttonView;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIVisualEffectView *vibrancyView;

@end

@implementation TSTalkOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLeaveAgency:)
                                                 name:TSGeofenceUserDidLeaveAgency
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidEnterAgency:)
                                                 name:TSGeofenceUserDidEnterAgency
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)initTalkOptions {
    
    if (_callButton) {
        return;
    }
    float buttonHeight = 60;
    float buttonSpace = 20;
    
//    TSJavelinAPIAgency *currentAgency = [TSLocationController sharedLocationController].geofence.currentAgency;
    TSJavelinAPIAgency *userAgency = [TSJavelinAPIClient loggedInUser].agency;
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    _titleLabel = [[UILabel alloc] initWithFrame:frame];
    _titleLabel.font = [UIFont fontWithName:kFontWeightLight size:16];
    _titleLabel.text = @"Talk";
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_titleLabel];
    
    frame.origin.y += frame.size.height;
    frame.size.height = 1;
    _vibrancyView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]]];
    _vibrancyView.frame = frame;
    [self.view addSubview:_vibrancyView];
    
    UIView *borderView = [[UIView alloc] initWithFrame:_vibrancyView.bounds];
    borderView.backgroundColor = [UIColor whiteColor];
    [_vibrancyView.contentView addSubview:borderView];
    
    
    frame = CGRectMake(0, 0, self.view.frame.size.width, buttonHeight);
    
    _emergencyButton = [[TSTalkOptionButton alloc] initWithFrame:frame imageType:k911Icon title:@"Emergency"];
    
    if ([self.parentViewController respondsToSelector:@selector(callEmergencyNumber:)]) {
        [_emergencyButton addTarget:self.parentViewController action:@selector(callEmergencyNumber:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:_emergencyButton];
    
    frame.origin.y += frame.size.height + buttonSpace;
    _callButton = [[TSTalkOptionButton alloc] initWithFrame:frame imageType:kPhoneIcon title:userAgency.alertModeName];
    
    if ([self.parentViewController respondsToSelector:@selector(callAgencyDispatcher:)]) {
        [_callButton addTarget:self.parentViewController action:@selector(callAgencyDispatcher:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:_callButton];
    
    frame.origin.y += frame.size.height + buttonSpace;
    _chatButton = [[TSTalkOptionButton alloc] initWithFrame:frame imageType:kChatIcon title:@"Chat"];
    
    if ([self.parentViewController respondsToSelector:@selector(openChat:)]) {
        [_chatButton addTarget:self.parentViewController action:@selector(openChat:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:_chatButton];
    
    _buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _chatButton.frame.size.height*3+20*2)];
    _buttonView.backgroundColor = [UIColor clearColor];
    [_buttonView addSubview:_emergencyButton];
    [_buttonView addSubview:_callButton];
    [_buttonView addSubview:_chatButton];
    [self.view addSubview:_buttonView];
    CGPoint center = self.view.contentCenter;
    center.y += _titleLabel.frame.size.height/2;
    _buttonView.center = center;
    
    [self setButtonsHidden:YES];
    
    [self startPostition];
}

- (void)startPostition {
    
    float scale = 0.001;
    
    _chatButton.transform = CGAffineTransformMakeScale(scale, scale);
    _callButton.transform = CGAffineTransformMakeScale(scale, scale);
    _emergencyButton.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)setButtonsHidden:(BOOL)hidden {
    
    self.view.hidden = hidden;
    [_emergencyButton setHidden:hidden];
    [_callButton setHidden:hidden];
    [_chatButton setHidden:hidden];
    [_vibrancyView setHidden:hidden];
    [_titleLabel setHidden:hidden];
}

- (void)stopAnimations {
    
    [_callButton.layer removeAllAnimations];
    [_emergencyButton.layer removeAllAnimations];
    [_chatButton.layer removeAllAnimations];
}

- (void)showTalkButtons {
    
    if (![TSLocationController sharedLocationController].geofence.currentAgency) {
        [self setAgencyButtonsAlpha:0.5];
    }
    
    self.view.transform = CGAffineTransformIdentity;
    
    [self stopAnimations];
    
    [self setButtonsHidden:NO];
    
    [UIView animateKeyframesWithDuration:0.3 delay:0.0 options:UIViewKeyframeAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:.33 animations:^{
            _chatButton.transform = CGAffineTransformIdentity;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:.33 relativeDuration:.33 animations:^{
            _callButton.transform = CGAffineTransformIdentity;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:.66 relativeDuration:.33 animations:^{
            _emergencyButton.transform = CGAffineTransformIdentity;
        }];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideTalkButtons {
    
    _titleLabel.hidden = YES;
    _vibrancyView.hidden = YES;
    
    [self stopAnimations];
    
    [UIView animateKeyframesWithDuration:0.1 delay:0.0 options:UIViewKeyframeAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        float scale = 0.001;
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
            _chatButton.transform = CGAffineTransformMakeScale(scale, scale);
            _callButton.transform = CGAffineTransformMakeScale(scale, scale);
            _emergencyButton.transform = CGAffineTransformMakeScale(scale, scale);
        }];
        
    } completion:^(BOOL finished) {
        
        if (finished && _chatButton.transform.a != CGAffineTransformIdentity.a) {
            [self setButtonsHidden:YES];
        }
    }];
}


- (void)userDidLeaveAgency:(NSNotification *)notification {
    
    [self setAgencyButtonsAlpha:0.5];
    
    [_callButton setTitle:[TSJavelinAPIClient loggedInUser].agency.alertModeName forState:UIControlStateNormal];
}

- (void)userDidEnterAgency:(NSNotification *)notification {
    
    [self setAgencyButtonsAlpha:1.0];
    
    [_callButton setTitle:[TSJavelinAPIClient loggedInUser].agency.alertModeName forState:UIControlStateNormal];
}

- (void)setAgencyButtonsAlpha:(float)alpha {
    
    _chatButton.alpha = alpha;
}

@end
