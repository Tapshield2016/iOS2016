//
//  TSHomeViewController.h
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMapView.h"
#import "TSUserLocationButton.h"
#import "TSBaseViewController.h"
#import "TSPageViewController.h"

@interface TSHomeViewController : TSBaseViewController <MKMapViewDelegate, TSLocationControllerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet TSMapView *mapView;
@property (weak, nonatomic) IBOutlet TSUserLocationButton *showUserLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *alertButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;

@property (nonatomic, strong) CLGeocoder *geocoder;

- (IBAction)displayVirtualEntourage:(id)sender;
- (IBAction)sendAlert:(id)sender;
- (IBAction)openChatWindow:(id)sender;

@end
