//
//  TSViewReportDetailsViewController.h
//  TapShield
//
//  Created by Adam Share on 6/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TSSpotCrimeAnnotationView.h"
#import "TSSpotCrimeAnnotation.h"
#import "TSReportAnnotationManager.h"
#import "TSRegistrationButton.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface TSViewReportDetailsViewController : TSNavigationViewController <AVAudioPlayerDelegate>

@property (strong, nonatomic) TSSpotCrimeAnnotation *spotCrimeAnnotation;
@property (strong, nonatomic) UIImageView *mediaImageView;

@property (weak, nonatomic) IBOutlet TSTintedImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet FBShimmeringView *shimmeringView;
@property (weak, nonatomic) IBOutlet TSBaseLabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet TSBaseLabel *submittedByLabel;
@property (weak, nonatomic) IBOutlet TSRegistrationButton *audioPlayButton;

- (IBAction)playAudio:(id)sender;

- (IBAction)done:(id)sender;

+ (TSViewReportDetailsViewController *)presentDetails:(TSSpotCrimeAnnotation *)annotation from:(TSBaseViewController *)controller;

@end
