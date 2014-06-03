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

@interface TSViewReportDetailsViewController : TSNavigationViewController

@property (strong, nonatomic) TSSpotCrimeAnnotation *spotCrimeAnnotation;
@property (strong, nonatomic) UIImageView *mediaImageView;
@property (strong, nonatomic) TSReportAnnotationManager *reportManager;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet FBShimmeringView *shimmeringView;
@property (weak, nonatomic) IBOutlet TSBaseLabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet TSBaseLabel *submittedByLabel;

- (IBAction)done:(id)sender;

+ (TSViewReportDetailsViewController *)presentDetails:(TSSpotCrimeAnnotation *)annotation from:(TSBaseViewController *)controller;

@end
