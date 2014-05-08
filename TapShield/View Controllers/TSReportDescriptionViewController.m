//
//  TSReportDescriptionViewController.m
//  TapShield
//
//  Created by Adam Share on 5/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSReportDescriptionViewController.h"
#import "TSSpotCrimeAPIClient.h"
#import "TSSpotCrimeAnnotation.h"

@interface TSReportDescriptionViewController ()

@property (strong, nonatomic) CLLocation *location;

@end

@implementation TSReportDescriptionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Description";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [TSColorPalette listBackgroundColor];
    _imageView.image = _image;
    _typeLabel.text = _type;
    _timeLabel.text = [TSUtilities formattedViewableDate:[NSDate date]];
    _addressLabel.text = @"";
    _location = [TSLocationController sharedLocationController].location;
    
    _detailsTextView.layer.cornerRadius = 5;
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error) {
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
                
                _addressLabel.text = title;
            }
        }];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Report" style:UIBarButtonItemStyleBordered target:self action:@selector(reportEvent)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reportEvent {
    
    NSArray *array = [NSArray arrayWithObjects:kSpotCrimeTypesArray];
    int index = [array indexOfObject:_type];
    NSArray *shortArray = [NSArray arrayWithObjects:kSpotCrimeTypesShortArray];
    
    if (!_detailsTextView.text || !_detailsTextView.text.length) {
        _detailsTextView.text = _type;
    }
    
    [[TSJavelinAPIClient sharedClient] postSocialCrimeReport:_detailsTextView.text type:shortArray[index] location:_location completion:^(BOOL posted) {
        
        if (posted) {
            TSSpotCrimeLocation *location = [[TSSpotCrimeLocation alloc] initWithLatitude:_location.coordinate.latitude longitude:_location.coordinate.longitude];
            location.eventDescription = _detailsTextView.text;
            location.type = _type;
            location.date = [TSUtilities formattedDateTime:[NSDate date]];
            location.address = _addressLabel.text;
            TSSpotCrimeAnnotation *annotation = [[TSSpotCrimeAnnotation alloc] initWithSpotCrime:location];
            
            [self dismissViewControllerAnimated:YES completion:^{
                [_mapView addAnnotation:annotation];
            }];
        }
    }];
}

@end
