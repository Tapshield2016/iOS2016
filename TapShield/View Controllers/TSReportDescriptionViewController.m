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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.navigationItem.title = @"Description";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [TSColorPalette listBackgroundColor];
    _imageView.image = _image;
    _typeLabel.text = _type;
    _timeLabel.text = [TSUtilities formattedViewableDate:[NSDate date]];
    _addressLabel.text = @"";
    _location = [TSLocationController sharedLocationController].location;
    
    _detailsTextView.layer.cornerRadius = 5;
    _detailsTextView.placeholder = @"Enter your non-emergency tip details here (call 911 if this is an emergency)";
    
    
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
    
    NSArray *array = [NSArray arrayWithObjects:kSocialCrimeReportLongArray];
    int index = [array indexOfObject:_type];
    NSArray *shortArray = [NSArray arrayWithObjects:kSocialCrimeReportShortArray];
    
    if (!_detailsTextView.text || !_detailsTextView.text.length) {
        _detailsTextView.text = _type;
    }
    
    [[TSJavelinAPIClient sharedClient] postSocialCrimeReport:_detailsTextView.text type:shortArray[index] location:_location completion:^(TSJavelinAPISocialCrimeReport *report) {
        
        if (report) {
            report.address = _addressLabel.text;
            
            UINavigationController *parentNavigationController;
            if ([[self.presentingViewController.childViewControllers firstObject] isKindOfClass:[UINavigationController class]]) {
                parentNavigationController = (UINavigationController *)[self.presentingViewController.childViewControllers firstObject];
            }
            else if ([self.presentingViewController isKindOfClass:[UINavigationController class]]) {
                parentNavigationController = (UINavigationController *)self.presentingViewController;
            }
            
            [self dismissViewControllerAnimated:YES completion:^{
                [_mapView addSocialReports:@[report]];
                [parentNavigationController.topViewController viewWillAppear:NO];
                [parentNavigationController.topViewController viewDidAppear:NO];
            }];
        }
    }];
}



#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardBounds.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0f, keyboardBounds.size.height, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect rect = [[self.view findFirstResponder] convertRect:[self.view findFirstResponder].superview.frame toView:self.view];
    
    if (!CGRectContainsPoint(aRect, rect.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, rect.origin.y - keyboardBounds.size.height);
        [_scrollView setContentOffset:scrollPoint];
    }
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
}

@end
