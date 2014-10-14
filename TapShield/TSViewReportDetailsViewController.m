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
#import "TSSpotCrimeAnnotation.h"

static NSString * const kDefaultMediaImage = @"image_deafult";

@interface TSViewReportDetailsViewController ()

@property (strong, nonatomic) MPMoviePlayerController *player;
@property (strong, nonatomic) UIToolbar *imageBackground;
@property (strong, nonatomic) UIView *tapView;
@property (assign, nonatomic) CGRect previousRect;
@property (strong, nonatomic) UIImageView *largeImageView;
@property (strong, nonatomic) AVPlayer *audioPlayer;
@property (strong, nonatomic) UIView *volumeHolder;

@end

@implementation TSViewReportDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Details";
    self.view.backgroundColor = [TSColorPalette listBackgroundColor];
    
    _audioPlayButton.hidden = YES;
    
    _detailsTextView.layer.cornerRadius = 5;
    [_detailsTextView setEditable:NO];
    
    CLLocation *location;
    if (_spotCrimeAnnotation.socialReport) {
        _imageView.image = [TSReportTypeTableViewCell imageForType:_spotCrimeAnnotation.socialReport.reportType];
        _typeLabel.text = [[NSArray arrayWithObjects:kSocialCrimeReportLongArray] objectAtIndex:_spotCrimeAnnotation.socialReport.reportType];
        _timeLabel.text = [_spotCrimeAnnotation.socialReport.creationDate mediumString];
        _detailsTextView.text = _spotCrimeAnnotation.socialReport.body;
        
        location = _spotCrimeAnnotation.socialReport.location;
        _submittedByLabel.text = @"User-submitted report";
        
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
        _submittedByLabel.text = TSSpotCrimeAnnotationPoweredBy;
        
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
    _mediaImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _mediaImageView.layer.shadowOffset = CGSizeMake(0, 1);
    _mediaImageView.layer.shadowOpacity = .5;
    _mediaImageView.layer.shadowRadius = 2.0;
    _mediaImageView.clipsToBounds = NO;
    _mediaImageView.backgroundColor = [UIColor whiteColor];
    
    _descriptionLabel.textColor = [TSColorPalette registrationButtonTextColor];
    _submittedByLabel.textColor = [TSColorPalette registrationButtonTextColor];
    
    _imageView.layer.cornerRadius = _imageView.frame.size.height/2;
    _imageView.layer.borderColor = [TSColorPalette tapshieldBlue].CGColor;
    _imageView.layer.borderWidth = 1.0f;
    
    [self getImageFromSocialReport];
    [self getVideoFromSocialReport];
    [self getAudioFromSocialReport];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (TSViewReportDetailsViewController *)presentDetails:(TSSpotCrimeAnnotation *)annotation from:(TSBaseViewController *)controller {
    
    TSViewReportDetailsViewController *detailsController = (TSViewReportDetailsViewController *)[controller presentViewControllerWithClass:[TSViewReportDetailsViewController class] transitionDelegate:nil animated:YES];
    detailsController.spotCrimeAnnotation = annotation;
    return detailsController;
}

- (void)showDeleteSocialCrime {
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Delete"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(deleteSocialReport)];
    item.tintColor = [TSColorPalette tapshieldBlue];
    [self.navigationItem setLeftBarButtonItem:item];
}

- (void)deleteSocialReport {
    
    [[TSJavelinAPIClient sharedClient] removeUrl:_spotCrimeAnnotation.socialReport.url completion:^(BOOL finished) {
        if (finished) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [[TSReportAnnotationManager sharedManager] removeUserSocialReport:_spotCrimeAnnotation];
        }
    }];
}

#pragma mark - Display Picture

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
        _mediaImageView.backgroundColor = [UIColor clearColor];
    });
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(enlargeContent)];
    _tapView = [[UIView alloc] initWithFrame:_mediaImageView.frame];
    _tapView.backgroundColor = [UIColor clearColor];
    _tapView.center = _shimmeringView.center;
    [_tapView addGestureRecognizer:tap];
    [_scrollView addSubview:_tapView];
}


- (void)enlargeContent {
    
    [_mediaImageView setHidden:YES];
    
    CGRect largeFrame = AVMakeRectWithAspectRatioInsideRect(_mediaImageView.image.size, self.view.frame);
    CGRect smallframe = AVMakeRectWithAspectRatioInsideRect(_mediaImageView.image.size, _shimmeringView.frame);
    
    if (!_imageBackground) {
        
        _imageBackground = [[UIToolbar alloc] initWithFrame:smallframe];
        _imageBackground.barStyle = UIBarStyleDefault;
        _imageBackground.center = _shimmeringView.center;
        
        _largeImageView = [[UIImageView alloc] initWithImage:_mediaImageView.image];
        _largeImageView.contentMode = UIViewContentModeScaleAspectFit;
        _largeImageView.frame = largeFrame;
        _largeImageView.userInteractionEnabled = YES;
        _largeImageView.transform = [self scaledTransformUsingViewRect:smallframe fromRect:largeFrame];
        _largeImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        _largeImageView.layer.shadowOffset = CGSizeMake(0, 1);
        _largeImageView.layer.shadowOpacity = .5;
        _largeImageView.layer.shadowRadius = 2.0;
        _largeImageView.clipsToBounds = NO;
        
        [self.view addSubview:_imageBackground];
        [self.view addSubview:_largeImageView];
        
        UITapGestureRecognizer* tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [_largeImageView addGestureRecognizer: tgr];
        tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [_imageBackground addGestureRecognizer: tgr];
        
    }
    
    _imageBackground.frame = [self.view convertRect:_shimmeringView.frame fromView:_scrollView];
    _largeImageView.center = [self.view convertPoint:_shimmeringView.center fromView:_scrollView];
    
    [_largeImageView setHidden:NO];
    [_imageBackground setHidden:NO];
    _imageBackground.alpha = 1.0;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [UIView transitionWithView: self.view
                      duration: 0.2
                       options: UIViewAnimationOptionAllowAnimatedContent
                    animations:^{
                        
                        _largeImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                        _largeImageView.center = self.view.center;
                        _imageBackground.frame = self.view.bounds;
                        _largeImageView.layer.shadowRadius = 10.0;
                        _largeImageView.layer.shadowOffset = CGSizeMake(0, 5);
                    } completion:^(BOOL finished) {
                        
                    }];
}

- (void)onTap:(UITapGestureRecognizer*)tgr {
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [UIView transitionWithView:self.view
                      duration:0.2
                       options:UIViewAnimationOptionAllowAnimatedContent
                    animations:^{
                        
                        CGRect largeFrame = AVMakeRectWithAspectRatioInsideRect(_mediaImageView.image.size, self.view.frame);
                        CGRect smallframe = AVMakeRectWithAspectRatioInsideRect(_mediaImageView.image.size, [self.view convertRect:_shimmeringView.frame fromView:_scrollView]);
                        _largeImageView.transform = [self scaledTransformUsingViewRect:smallframe fromRect:largeFrame];
                        _largeImageView.center = [self.view convertPoint:_shimmeringView.center fromView:_scrollView];
                        
                        _imageBackground.frame = smallframe;
                        _imageBackground.alpha = 0.0;
                        _largeImageView.layer.shadowRadius = 2.0;
                        _largeImageView.layer.shadowOffset = CGSizeMake(0, 1);
                    } completion:^(BOOL finished) {
                        _imageBackground.frame = AVMakeRectWithAspectRatioInsideRect(_mediaImageView.image.size, _mediaImageView.frame);
                        _imageBackground.center = _shimmeringView.center;
                        [_largeImageView setHidden:YES];
                        [_imageBackground setHidden:YES];
                        [_mediaImageView setHidden:NO];
                    }];
}

- (CGAffineTransform)scaledTransformUsingViewRect:(CGRect)viewRect fromRect:(CGRect)fromRect {
    
    CGSize scales = CGSizeMake(viewRect.size.width/fromRect.size.width, viewRect.size.height/fromRect.size.height);
    return CGAffineTransformMakeScale(scales.width, scales.height);
}


#pragma mark - Display Video

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
    
    [TSUtilities videoThumbnailFromBeginning:videoUrl completion:^(UIImage *image) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_scrollView addSubview:toolbar];
            _mediaImageView.image = image;
            _shimmeringView.shimmering = NO;
            _mediaImageView.contentMode = UIViewContentModeScaleAspectFit;
            _mediaImageView.backgroundColor = [UIColor clearColor];
        });
    }];
    
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


#pragma mark - Play Audio

- (void)getAudioFromSocialReport {
    
    if (_spotCrimeAnnotation.socialReport.reportAudioUrl) {
        [_mediaImageView setHidden:YES];
        [_shimmeringView setHidden:YES];
        _audioPlayButton.hidden = NO;
        [_scrollView bringSubviewToFront:_audioPlayButton];
        [self initAudioPlayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itemDidFinishPlaying:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
    }
}

- (IBAction)playAudio:(id)sender {
    
    NSLog(@"%@", _audioPlayer.currentItem);
    NSLog(@"%lld - %lld", _audioPlayer.currentItem.duration.value , _audioPlayer.currentTime.value);
    
    if (_audioPlayer.status == AVPlayerStatusFailed) {
        [self initAudioPlayer];
    }
    
    if (_audioPlayer.currentItem.duration.value < _audioPlayer.currentTime.value) {
        [_audioPlayer seekToTime:CMTimeMake(0, 10)];
        [_audioPlayer pause];
    }
    
    if (_audioPlayer.rate == 0.0) {
        [_audioPlayer play];
        [_audioPlayButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
    else {
        [_audioPlayer pause];
        [_audioPlayButton setTitle:@"Play Audio" forState:UIControlStateNormal];
    }
    
}

- (void)initAudioPlayer {
    
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback
                        error:&error];
    
    [audioSession setActive:YES error:&error];
    _audioPlayer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:_spotCrimeAnnotation.socialReport.reportAudioUrl]];
    _audioPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [self createAndDisplayMPVolumeView];
    
}

- (void)itemDidFinishPlaying:(NSNotification *) notification {
    // Will be called when AVPlayer finishes playing playerItem
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_audioPlayButton setTitle:@"Play Audio" forState:UIControlStateNormal];
    });
}

- (void) createAndDisplayMPVolumeView {
    
    // Create a simple holding UIView and give it a frame
    CGRect frame = _audioPlayButton.frame;
    frame.origin.y += frame.size.height + 15;
    frame.size.width -= 40;
    frame.origin.x = (self.view.frame.size.width - frame.size.width)/2;
    _volumeHolder = [[UIView alloc] initWithFrame:frame];
    
    // set the UIView backgroundColor to clear.
    [_volumeHolder setBackgroundColor: [UIColor clearColor]];
    
    // add the holding view as a subView of the main view
    [_scrollView addSubview: _volumeHolder];
    
    // Create an instance of MPVolumeView and give it a frame
    MPVolumeView *myVolumeView = [[MPVolumeView alloc] initWithFrame: _volumeHolder.bounds];
    
    // Add myVolumeView as a subView of the volumeHolder
    [_volumeHolder addSubview: myVolumeView];
}

#pragma mark Audio Player Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_audioPlayButton setTitle:@"Play Audio" forState:UIControlStateNormal];
    });
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_audioPlayButton setTitle:@"Play Audio" forState:UIControlStateNormal];
    });
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    
    [player stop];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_audioPlayButton setTitle:@"Play Audio" forState:UIControlStateNormal];
    });
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_audioPlayButton setTitle:@"Play Audio" forState:UIControlStateNormal];
    });
}


@end
