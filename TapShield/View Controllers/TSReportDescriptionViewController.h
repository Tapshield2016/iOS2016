//
//  TSReportDescriptionViewController.h
//  TapShield
//
//  Created by Adam Share on 5/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"

@interface TSReportDescriptionViewController : TSNavigationViewController

@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;

@end
