//
//  TSViewReportDetailsViewController.m
//  TapShield
//
//  Created by Adam Share on 6/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSViewReportDetailsViewController.h"
#import "TSReportTypeTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

static NSString * const kDefaultMediaImage = @"image_deafult";

@interface TSViewReportDetailsViewController ()

@property (strong, nonatomic) MPMoviePlayerController *player;
@property (strong, nonatomic) UIToolbar *imageBackground;
@property (strong, nonatomic) UIView *tapView;
@property (assign, nonatomic) CGRect previousRect;

@end

@implementation TSViewReportDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Details";
    self.view.backgroundColor = [TSColorPalette listBackgroundColor];
    
    _detailsTextView.layer.cornerRadius = 5;
    [_detailsTextView setEditable:NO];
    
    CLLocation *location;
    if (_spotCrimeAnnotation.socialReport) {
        _imageView.image = [TSReportTypeTableViewCell imageForType:_spotCrimeAnnotation.socialReport.reportType];
        _typeLabel.text = [[NSArray arrayWithObjects:kSocialCrimeReportLongArray] objectAtIndex:_spotCrimeAnnotation.socialReport.reportType];
        _timeLabel.text = [_spotCrimeAnnotation.socialReport.creationDate mediumString];
        _detailsTextView.text = _spotCrimeAnnotation.socialReport.body;
        
        location = _spotCrimeAnnotation.socialReport.location;
        
        if ([_spotCrimeAnnotation.socialReport.user isEqualToString:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].url]) {
            [self showDeleteSocialCrime];
            _submittedByLabel.text = @"Your report";
        }
    }
    else {
        _imageView.image = [TSSpotCrimeLocation imageForSpotCrimeType:_spotCrimeAnnotation.spotCrime.type];
        _typeLabel.text = _spotCrimeAnnotation.spotCrime.type;
        _timeLabel.text = [_spotCrimeAnnotation.spotCrime.date mediumString];
        
        if (!_spotCrimeAnnotation.spotCrime.eventDescription) {
            [[TSSpotCrimeAPIClient sharedClient] getSpotCrimeDescription:_spotCrimeAnnotation.spotCrime completion:^(TSSpotCrimeLocation *location) {
                _spotCrimeAnnotation.spotCrime = location;
                _detailsTextView.text = location.eventDescription;
            }];
        }
        else {
            _detailsTextView.text = _spotCrimeAnnotation.spotCrime.eventDescription;
        }
        _submittedByLabel.text = @"Data Powered by SpotCrime.com";
        
        location = _spotCrimeAnnotation.spotCrime;
    }
    
    _addressLabel.text = [NSString stringWithFormat:@"%f, %f", location.coordinate.latitude, location.coordinate.longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks) {
            CLPlacemark *placemark = [placemarks firstObject];
            NSString *title = @"";
            NSString *subtitle = @"";
            if (placemark.subThoroughfare) {
                title = placemark.subThoroughfare;
            }
            if (placemark.thoroughfare) {
                title = [NSString stringWithFormat:@"%@ %@", title, placemark.thoroughfare];
            }
            if (placemark.locality) {
                subtitle = placemark.locality;
            }
            if (placemark.administrativeArea) {
                if (placemark.locality) {
                    subtitle = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
                }
                else {
                    subtitle = placemark.administrativeArea;
                }
            }
            if (placemark.postalCode) {
                subtitle = [NSString stringWithFormat:@"%@ %@", subtitle, placemark.postalCode];
            }
            
            if (!title) {
                title = subtitle;
            }
            
            _addressLabel.text = title;
        }
    }];
    
    _mediaImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kDefaultMediaImage]];
    _mediaImageView.contentMode = UIViewContentModeCenter;
    _mediaImageView.hidden = YES;
                       
    _shimmeringView.contentView = _mediaImageView;
    
    _descriptionLabel.textColor = [TSColorPalette registrationButtonTextColor];
    _submittedByLabel.textColor = [TSColorPalette registrationButtonTextColor];
    
    _imageView.layer.cornerRadius = _imageView.frame.size.height/2;
    _imageView.layer.borderColor = [TSColorPalette tapshieldBlue].CGColor;
    _imageView.layer.borderWidth = 1.0f;
    
    [self getImageFromSocialReport];
    [self getVideoFromSocialReport];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showDeleteSocialCrime {
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Delete"
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(deleteSocialReport)];
    item.tintColor = [TSColorPalette tapshieldBlue];
    [self.navigationItem setLeftBarButtonItem:item];
}

- (void)deleteSocialReport {
    
    [[TSJavelinAPIClient sharedClient] removeUrl:_spotCrimeAnnotation.socialReport.url completion:^(BOOL finished) {
        if (finished) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [_reportManager removeUserSocialReport:_spotCrimeAnnotation];
        }
    }];
}

- (void)enlargeContent {
    
//    if (_shimmeringView.superview == self.view) {
//        [self shrinkContent];
//    }
    
    if (!_imageBackground) {
        _imageBackground = [[UIToolbar alloc] initWithFrame:AVMakeRectWithAspectRatioInsideRect(_mediaImageView.image.size, _mediaImageView.bounds)];
        _imageBackground.barStyle = UIBarStyleBlack;
        _imageBackground.center = _mediaImageView.center;
        [_shimmeringView insertSubview:_imageBackground belowSubview:_mediaImageView];
    }
    
    [self.view addSubview:_imageBackground];
    [self.view addSubview:_mediaImageView];
    _imageBackground.frame = _shimmeringView.frame;
    _mediaImageView.frame = _shimmeringView.frame;
    
    _mediaImageView.userInteractionEnabled = YES;
    [UIView transitionWithView: self.view
                      duration: 1.0
                       options: UIViewAnimationOptionAllowAnimatedContent
                    animations:^{
                        
                        _imageBackground.frame = self.view.bounds;
                        
                        _mediaImageView.frame = self.view.bounds;
                        
                    } completion:^(BOOL finished) {
                        
                        UITapGestureRecognizer* tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
                        [_mediaImageView addGestureRecognizer: tgr];
                    }];
    
//    _previousRect = _shimmeringView.frame;
//    
//    [self.view addSubview:_shimmeringView];
//    [self.view addSubview:_tapView];
//    
//    [UIView animateWithDuration:0.2 animations:^{
//        _shimmeringView.frame = self.view.frame;
////        _mediaImageView.frame = self.view.frame;
////        _imageBackground.frame = self.view.frame;
//        _tapView.frame = self.view.frame;
//    } completion:^(BOOL finished) {
//        [_tapView setUserInteractionEnabled:YES];
//    }];
}

- (void) onTap: (UITapGestureRecognizer*) tgr
{
    [_mediaImageView removeGestureRecognizer:tgr];
    
    [UIView transitionWithView: _shimmeringView
                      duration: 1.0
                       options: UIViewAnimationOptionAllowAnimatedContent
                    animations:^{
                        [_shimmeringView addSubview:_imageBackground];
                        _imageBackground.frame = _shimmeringView.bounds;
                        [_shimmeringView addSubview:_mediaImageView];
                        _mediaImageView.frame = _shimmeringView.bounds;
                        
                    } completion:^(BOOL finished) {
                        [_scrollView bringSubviewToFront:_tapView];
                    }];
}

- (void)shrinkContent {
    
    [_tapView setUserInteractionEnabled:NO];
    
    [_scrollView addSubview:_shimmeringView];
    [_scrollView addSubview:_tapView];
    
    [UIView animateWithDuration:0.2 animations:^{
        _shimmeringView.frame = _previousRect;
        _mediaImageView.frame = _shimmeringView.bounds;
        _imageBackground.frame = AVMakeRectWithAspectRatioInsideRect(_mediaImageView.image.size, _mediaImageView.bounds);
    } completion:^(BOOL finished) {
        [_tapView setUserInteractionEnabled:YES];
        [_tapView setFrame:_shimmeringView.frame];
    }];
}

- (void)getVideoFromSocialReport {
    if (!_spotCrimeAnnotation.socialReport.reportVideoUrl) {
        return;
    }
    
    _mediaImageView.hidden = NO;
    _shimmeringView.shimmering = YES;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    toolbar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                          target:self
                                                                          action:@selector(playVideo)];
    [toolbar setItems:@[item]];
    toolbar.center = _shimmeringView.center;
    
    NSURL *videoUrl = [NSURL URLWithString:_spotCrimeAnnotation.socialReport.reportVideoUrl];
    dispatch_queue_t queue = dispatch_queue_create("async", NULL);
    dispatch_async(queue, ^{
        //code to be executed in the background
        UIImage *image = [TSUtilities videoThumbnail:videoUrl];
        dispatch_async(dispatch_get_main_queue(), ^{
            //code to be executed on the main thread when background task is finished
            _shimmeringView.shimmering = NO;
            _mediaImageView.image = image;
            _mediaImageView.contentMode = UIViewContentModeScaleAspectFit;
            [_scrollView addSubview:toolbar];
        });
    });
    
    _player = [[MPMoviePlayerController alloc] initWithContentURL:videoUrl];
    _player.shouldAutoplay = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doneButtonClick:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
    [_player prepareToPlay];
    _player.view.alpha = 0.0;
    _player.view.frame = AVMakeRectWithAspectRatioInsideRect(_mediaImageView.image.size, _mediaImageView.frame);
    _player.view.center = _shimmeringView.center;
}

- (void)playVideo {
    
    [_scrollView addSubview: _player.view];
    [_player play];
    [_player setFullscreen:YES animated:YES];
    [UIView animateWithDuration:0.2 animations:^{
        _player.view.alpha = 1.0;
    } completion:nil];
}

- (void)doneButtonClick:(NSNotification*)notification{
    NSNumber *reason = [notification.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    if ([reason intValue] == MPMovieFinishReasonUserExited) {
        // Your done button action here
        
    }
    
    [_player setFullscreen:NO animated:YES];
    [UIView animateWithDuration:0.2 animations:^{
        _player.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_player.view removeFromSuperview];
    }];
}

- (void) moviePlayBackDidFinish:(NSNotification *)notification {
    
    NSNumber *reason = [notification.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    if ([reason intValue] == MPMovieFinishReasonUserExited) {
        // Your done button action here
        
    }
    
    if ([_player respondsToSelector:@selector(setFullscreen:animated:)]) {
        [_player setFullscreen:NO animated:YES];
        [UIView animateWithDuration:0.2 animations:^{
            _player.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [_player.view removeFromSuperview];
        }];
    }
}

- (void)getImageFromSocialReport {
    if (!_spotCrimeAnnotation.socialReport.reportImageUrl) {
        return;
    }
    
    _mediaImageView.hidden = NO;
    _shimmeringView.shimmering = YES;
    
    NSURL *url = [NSURL URLWithString:_spotCrimeAnnotation.socialReport.reportImageUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    __weak typeof(self) weakSelf = self;
    [_mediaImageView setImageWithURLRequest:request
                     placeholderImage:_mediaImageView.image
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  
                                  [weakSelf setThumbnail:image];
                                  
                              } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                  
                                  if ([[TSJavelinAPIClient sharedClient] shouldRetry:error]) {
                                      dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
                                      dispatch_after(popTime, dispatch_get_main_queue(), ^{
                                          [weakSelf getImageFromSocialReport];
                                      });
                                  }
                                  else {
                                      weakSelf.shimmeringView.shimmering = NO;
                                  }
                              }];
}

- (void)setThumbnail:(UIImage *)image {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _shimmeringView.shimmering = NO;
        _mediaImageView.image = image;
        _mediaImageView.contentMode = UIViewContentModeScaleAspectFit;
    });
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(enlargeContent)];
    _tapView = [[UIView alloc] initWithFrame:_mediaImageView.frame];
    _tapView.backgroundColor = [UIColor clearColor];
    _tapView.center = _shimmeringView.center;
    [_tapView addGestureRecognizer:tap];
    [_scrollView addSubview:_tapView];
}

- (IBAction)done:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (TSViewReportDetailsViewController *)presentDetails:(TSSpotCrimeAnnotation *)annotation from:(TSBaseViewController *)controller {
    
    TSViewReportDetailsViewController *detailsController = (TSViewReportDetailsViewController *)[controller presentViewControllerWithClass:[TSViewReportDetailsViewController class] transitionDelegate:nil animated:YES];
    detailsController.spotCrimeAnnotation = annotation;
    return detailsController;
}

@end
