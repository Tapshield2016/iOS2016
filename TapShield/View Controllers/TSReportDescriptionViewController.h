//
//  TSReportDescriptionViewController.h
//  TapShield
//
//  Created by Adam Share on 5/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TSBaseTextView.h"
#import "TSReportAnnotationManager.h"
#import "TSRegistrationButton.h"
#import <MediaPlayer/MediaPlayer.h>


@interface TSReportDescriptionViewController : TSNavigationViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, MPMediaPickerControllerDelegate>

@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) TSReportAnnotationManager *reportManager;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet TSBaseTextView *detailsTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet FBShimmeringView *shimmeringView;
@property (weak, nonatomic) IBOutlet TSRegistrationButton *addMediaButton;
@property (weak, nonatomic) IBOutlet UIImageView *mediaImageView;

- (IBAction)chooseMedia:(id)sender;

@end
