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

@interface TSTalkOptionViewController ()

@property (strong, nonatomic) TSTalkOptionButton *chatButton;
@property (strong, nonatomic) TSTalkOptionButton *callButton;
@property (strong, nonatomic) TSTalkOptionButton *emergencyButton;

@end

@implementation TSTalkOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
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
//    TSJavelinAPIAgency *currentAgency = [TSLocationController sharedLocationController].geofence.currentAgency;
    TSJavelinAPIAgency *userAgency = [TSJavelinAPIClient loggedInUser].agency;
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    
    _emergencyButton = [[TSTalkOptionButton alloc] initWithFrame:frame imageType:k911Icon title:@"Emergency"];
    _emergencyButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    if ([self.parentViewController respondsToSelector:@selector(callEmergencyNumber:)]) {
        [_emergencyButton addTarget:self.parentViewController action:@selector(callEmergencyNumber:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:_emergencyButton];
    
    frame.origin.y += frame.size.height + 20;
    _callButton = [[TSTalkOptionButton alloc] initWithFrame:frame imageType:kPhoneIcon title:userAgency.alertModeName];
    _callButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    if ([self.parentViewController respondsToSelector:@selector(callAgencyDispatcher:)]) {
        [_callButton addTarget:self.parentViewController action:@selector(callAgencyDispatcher:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:_callButton];
    
    frame.origin.y += frame.size.height + 20;
    _chatButton = [[TSTalkOptionButton alloc] initWithFrame:frame imageType:kChatIcon title:@"Chat"];
    _chatButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    if ([self.parentViewController respondsToSelector:@selector(openChat:)]) {
        [_chatButton addTarget:self.parentViewController action:@selector(openChat:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:_chatButton];
    
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
}

- (void)stopAnimations {
    
    [_callButton.layer removeAllAnimations];
    [_emergencyButton.layer removeAllAnimations];
    [_chatButton.layer removeAllAnimations];
}

- (void)showTalkButtons {
    
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
    
    [self stopAnimations];
    
    [UIView animateKeyframesWithDuration:0.3 delay:0.0 options:UIViewKeyframeAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        float scale = 0.001;
        [UIView addKeyframeWithRelativeStartTime:0.66 relativeDuration:.33 animations:^{
            _chatButton.transform = CGAffineTransformMakeScale(scale, scale);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.33 relativeDuration:.33 animations:^{
            _callButton.transform = CGAffineTransformMakeScale(scale, scale);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:.33 animations:^{
            _emergencyButton.transform = CGAffineTransformMakeScale(scale, scale);
        }];
        
    } completion:^(BOOL finished) {
        
        if (finished && _chatButton.transform.a != CGAffineTransformIdentity.a) {
            [self setButtonsHidden:YES];
        }
    }];
}

@end
