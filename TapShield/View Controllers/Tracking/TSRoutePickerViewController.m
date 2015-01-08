//
//  TSRoutePickerViewController.m
//  TapShield
//
//  Created by Adam Share on 3/27/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRoutePickerViewController.h"
#import "TSNotifySelectionViewController.h"
#import "TSUtilities.h"
#import <KVOController/FBKVOController.h>
#import "CLLocation+Utilities.h"
#import "TSDestinationSearchViewController.h"

#define TUTORIAL_TITLE @"Walking or Driving?"
#define TUTORIAL_MESSAGE @"Find your destination and adjust the marker. Your entourage will tag along until you reach that point."


#define TUTORIAL_TITLE_2 @"Set Your ETA"
#define TUTORIAL_MESSAGE_2 @"Choose your route or tap the ETA above to adjust the time."

static NSString * const TSRoutePickerViewControllerDestinationTutorial = @"TSRoutePickerViewControllerDestinationTutorial";
static NSString * const TSRoutePickerViewControllerRouteTutorial = @"TSRoutePickerViewControllerRouteTutorial";
static NSString * const TSRoutePickerViewControllerTravelType = @"TSRouteTravelType";

@interface TSRoutePickerViewController ()

@property (nonatomic, strong) TSPopUpWindow *tutorialWindow;

@property (nonatomic, strong) UIImageView *centerPin;

@property (nonatomic, strong) UIButton *timeButton;

@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) CLPlacemark *latestPlacemark;

@property (strong, nonatomic) FBShimmeringView *shimmeringView;

@property (nonatomic, strong) TSTopDownTransitioningDelegate *topDownTransitioningDelegate;

@property (nonatomic, assign) BOOL routePickingMode;

@property (nonatomic, strong) FBKVOController *kvoController;


@end

@implementation TSRoutePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [TSEntourageSessionManager sharedManager].routeManager.shouldCancel = NO;
    
    [TSEntourageSessionManager sharedManager].routeManager.destinationPickerVC = self;
    
    self.removeNavigationShadow = YES;
    
    _routePickingMode = NO;
    
    [TSEntourageSessionManager sharedManager].routeManager.destinationMapItem = nil;
    
    _hitTestView.sendToView = _homeViewController.view;
    
    _directionsTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[[UIImage imageNamed:@"Walk"], [UIImage imageNamed:@"Car"]]];
    _directionsTypeSegmentedControl.frame = CGRectMake(0, 0, self.view.frame.size.width/3, self.navigationController.navigationBar.frame.size.height - 10);
    [_directionsTypeSegmentedControl setApportionsSegmentWidthsByContent:NO];
    _directionsTypeSegmentedControl.tintColor = [TSColorPalette tapshieldBlue];
    
    
    [TSEntourageSessionManager sharedManager].routeManager.destinationTransportType = [[NSUserDefaults standardUserDefaults] integerForKey:TSRoutePickerViewControllerTravelType];
    
    if ([self directionsTransportType] == MKDirectionsTransportTypeWalking) {
        [_directionsTypeSegmentedControl setSelectedSegmentIndex:0];
    }
    else {
        [_directionsTypeSegmentedControl setSelectedSegmentIndex:1];
    }
    
    [_directionsTypeSegmentedControl addTarget:self
                                        action:@selector(transportTypeSegmentedControlValueChanged:)
                              forControlEvents:UIControlEventValueChanged];
    
    [self.navigationItem setTitleView:_directionsTypeSegmentedControl];
    
    _etaLabel.textColor = [TSColorPalette tapshieldBlue];
    _addressLabel.textColor = [TSColorPalette tapshieldBlue];
    [_addressLabel setAdjustsFontSizeToFitWidth:YES];
    [_etaLabel setAdjustsFontSizeToFitWidth:YES];
    
    [self showTutorial];
    [self setCenterPinType:self.directionsTransportType];
    
    [self monitorSelectedRoute];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTimeAdjustViewController)];
    [_routeInfoView addGestureRecognizer:tap];
    
    
    if (!_homeViewController.isTrackingUser) {
        [self didChangeRegion];
    }
    
    [_homeViewController setIsTrackingUser:NO animateToUser:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeRegion) name:TSMapViewDidChangeRegion object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeRegion) name:TSMapViewWillChangeRegion object:nil];
}


- (void)setCenterPinType:(MKDirectionsTransportType)type {
    
    UIImage *image;
    
    if (type == MKDirectionsTransportTypeWalking) {
        image = [UIImage imageNamed:@"WalkEndPoint"];
    }
    else {
        image = [UIImage imageNamed:@"CarEndPoint"];
    }
    
    if (!_centerPin) {
        
        _centerPin = [[UIImageView alloc] initWithImage:image];
        _centerPin.center = CGPointMake(_homeViewController.mapView.contentCenter.x, _homeViewController.mapView.contentCenter.y+12);
        
        if (!_shimmeringView) {
            _shimmeringView = [[FBShimmeringView alloc] initWithFrame:_centerPin.frame];
            _shimmeringView.shimmeringSpeed = 100;
        }
        
        _centerPin.frame = _shimmeringView.bounds;
        _shimmeringView.contentView = _centerPin;
        _shimmeringView.shimmering = NO;
        
        [self.view addSubview:_shimmeringView];
    }
    else {
        _centerPin.image = image;
    }
}

- (MKDirectionsTransportType)directionsTransportType {
    
    return [TSEntourageSessionManager sharedManager].routeManager.destinationTransportType;
}

- (void)setDirectionsTransportType:(MKDirectionsTransportType) type {
    
    [TSEntourageSessionManager sharedManager].routeManager.destinationTransportType = type;
    [self setCenterPinType:type];
}

- (void)showCenterPin:(BOOL)show {
    
    [_centerPin setHidden:!show];
}

- (void)setDestinationMapItem:(MKMapItem *)destinationMapItem {
    
    _destinationMapItem = destinationMapItem;
    
    [[TSEntourageSessionManager sharedManager].routeManager userSelectedDestination:_destinationMapItem forTransportType:self.directionsTransportType];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self drawerCanDragForMenu:NO];
    [self drawerCanDragForContacts:NO];
    
    [self timeAdjusted];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.5 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        _routeInfoView.transform = CGAffineTransformIdentity;
    } completion:nil];
}


- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showTutorial {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:TSRoutePickerViewControllerDestinationTutorial]) {
        return;
    }
    
    _tutorialWindow = [[TSPopUpWindow alloc] initWithRepeatCheckBox:TSRoutePickerViewControllerDestinationTutorial
                                                              title:TUTORIAL_TITLE
                                                            message:TUTORIAL_MESSAGE];
    [_tutorialWindow show];
}


#pragma mark - UISegmentedControl event handlers

- (void)transportTypeSegmentedControlValueChanged:(id)sender {
    
    [_etaLabel setText:@"Re-calculating" withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
    [[TSEntourageSessionManager sharedManager].routeManager deselectTempAnnotation];
    
    switch ([_directionsTypeSegmentedControl selectedSegmentIndex]) {
            
        case 0:
            [self setDirectionsTransportType:MKDirectionsTransportTypeWalking];
            break;
            
        case 1:
            [self setDirectionsTransportType:MKDirectionsTransportTypeAutomobile];
            break;
            
        default:
            [self setDirectionsTransportType:MKDirectionsTransportTypeAny];
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.directionsTransportType forKey:TSRoutePickerViewControllerTravelType];
    
    [self updateRoutes];
    [[TSEntourageSessionManager sharedManager].routeManager updateTempMapItemTransportType];
}



- (IBAction)presentSearchViewController:(id)sender {
    
    if (!_topDownTransitioningDelegate) {
        _topDownTransitioningDelegate = [[TSTopDownTransitioningDelegate alloc] init];
    }
    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        _routeInfoView.transform = CGAffineTransformMakeTranslation(0, -110);
    } completion:nil];
    
    [self presentViewControllerWithClass:[TSDestinationSearchViewController class] transitionDelegate:_topDownTransitioningDelegate animated:YES];
}


- (IBAction)dismissViewController:(id)sender {
    
    [TSEntourageSessionManager sharedManager].routeManager.shouldCancel = YES;
    
    [_geocoder cancelGeocode];
    [[TSEntourageSessionManager sharedManager].routeManager cancelSearch];
    
    [self drawerCanDragForMenu:YES];
    [self drawerCanDragForContacts:YES];
    
    [_centerPin setHidden:YES];
    
    [[TSEntourageSessionManager sharedManager].routeManager clearRouteAndMapData];
    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        _routeInfoView.transform = CGAffineTransformMakeTranslation(0, -110);
    } completion:nil];
    
    [_homeViewController beginAppearanceTransition:YES animated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        [_homeViewController endAppearanceTransition];
    }];
}


#pragma mark - Region changes

- (void)willChangeRegion {
    
    if (self.presentedViewController) {
        
        return;
    }
    
    if (_routePickingMode) {
        return;
    }
    
    [[TSEntourageSessionManager sharedManager].routeManager deselectTempAnnotation];
    [_geocoder cancelGeocode];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)didChangeRegion {
    
    if (self.presentedViewController) {
        
        return;
    }
    
    if (_routePickingMode) {
        return;
    }
    
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    [_geocoder cancelGeocode];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:_homeViewController.mapView.centerCoordinate.latitude longitude:_homeViewController.mapView.centerCoordinate.longitude];
    
    if ([location distanceFromLocation:[TSEntourageSessionManager sharedManager].routeManager.destinationMapItem.placemark.location] < 20 && [TSEntourageSessionManager sharedManager].routeManager.destinationMapItem.placemark.location) {
        [[TSEntourageSessionManager sharedManager].routeManager updateTempMapItemLocation:location];
        [[TSEntourageSessionManager sharedManager].routeManager selectTempAnnotation];
        return;
    }
    
    [self performSelector:@selector(routeLocation:) withObject:location afterDelay:1.0];
}


#pragma mark - Route management and display methods

- (void)routeLocation:(CLLocation *)location {
    
    [_addressLabel setText:@"Searching" withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
    
    NSString *oldString = _etaLabel.text;
    
    [_etaLabel setText:@"" withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
    
    [[TSEntourageSessionManager sharedManager].routeManager cancelSearch];
    
    _shimmeringView.shimmering = YES;
    
    [_geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude] completionHandler:^(NSArray *placemarks, NSError *error){
        
        _shimmeringView.shimmering = NO;
        
        if (placemarks.count) {
            CLPlacemark *placemark = placemarks[0];
            
            [TSEntourageSessionManager sharedManager].routeManager.destinationMapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary:placemark.addressDictionary]];
            [_addressLabel setText:[TSEntourageSessionManager sharedManager].routeManager.destinationMapItem.name withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
            
            if (CLLocationCoordinate2DIsApproxEqual(placemark.location.coordinate, _latestPlacemark.location.coordinate, 0.0000001) && _latestPlacemark) {
                [_etaLabel setText:oldString withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
                [[TSEntourageSessionManager sharedManager].routeManager updateTempMapItemLocation:location];
                [[TSEntourageSessionManager sharedManager].routeManager selectTempAnnotation];
            }
            else {
                [_etaLabel setText:@"Routing..." withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
                [self updateRoutes];
            }
            _latestPlacemark = placemark;
        }
        else {
            if (error) {
                [_addressLabel setText:error.localizedFailureReason withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
                [_etaLabel setText:error.localizedRecoverySuggestion withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
            }
            else {
                [_addressLabel setText:@"Try again" withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
                [_etaLabel setText:@"Could not find address for this location" withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
            }
        }
    }];
}

- (void)updateRoutes {
    
    _shimmeringView.shimmering = YES;
    
    [[TSEntourageSessionManager sharedManager].routeManager getRoutesForDestination:^(TSRouteOption *bestRoute, NSError *error) {
        
        _shimmeringView.shimmering = NO;
        
        if (bestRoute) {
            NSString *formattedText = [NSString stringWithFormat:@"%@ - %@", [TSUtilities formattedDescriptiveStringForDuration:bestRoute.expectedTravelTime], [TSUtilities formattedStringForDistanceInUSStandard:bestRoute.distance]];
            [_etaLabel setText:formattedText withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
        }
        else {
            if (error) {
                [_etaLabel setText:error.localizedFailureReason withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
            }
            else {
                [_etaLabel setText:@"Could not find a route" withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
            }
            
            [[TSEntourageSessionManager sharedManager].routeManager deselectTempAnnotation];
        }
        
    }];
}

- (void)searchSelectedMapItem:(MKMapItem *)item {
    
    [TSEntourageSessionManager sharedManager].routeManager.destinationMapItem = item;
    [_addressLabel setText:[TSEntourageSessionManager sharedManager].routeManager.destinationMapItem.name withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
    
    if (![TSEntourageSessionManager sharedManager].routeManager.destinationAnnotation) {
        [[TSEntourageSessionManager sharedManager].routeManager showTempDestinationAnnotationSelected:NO];
    }
    [[TSEntourageSessionManager sharedManager].routeManager centerMapOnSelectedDestination];
    
    if (CLLocationCoordinate2DIsApproxEqual(item.placemark.location.coordinate, _latestPlacemark.location.coordinate, 0.0000001) &&
        _latestPlacemark &&
        [TSEntourageSessionManager sharedManager].routeManager.selectedRoute) {
        [[TSEntourageSessionManager sharedManager].routeManager updateTempMapItemLocation:item.placemark.location];
        [[TSEntourageSessionManager sharedManager].routeManager selectTempAnnotation];
    }
    else {
        [_etaLabel setText:@"Routing..." withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
        [self updateRoutes];
    }
    
    _latestPlacemark = item.placemark;
}


- (void)calloutTapped:(UITapGestureRecognizer *)sender
{
    NSLog(@"Callout was tapped");
    
    if (!_routePickingMode) {
        [self transitionToRoutePicking];
    }
}


- (void)transitionToRoutePicking {
    
    if (![TSEntourageSessionManager sharedManager].routeManager.routeOptions.count) {
        [[TSEntourageSessionManager sharedManager].routeManager deselectTempAnnotation];
        return;
    }
    
    [self showRouteTutorial];
    
    if (!_timeButton) {
        _timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_timeButton addTarget:self action:@selector(showTimeAdjustViewController) forControlEvents:UIControlEventTouchUpInside];
        _timeButton.titleLabel.font = [UIFont fontWithName:kFontWeightThin size:28];
        [_timeButton setTitleColor:[TSColorPalette tapshieldBlue] forState:UIControlStateNormal];
        [_timeButton setTitleColor:[[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    }
    
    [self timeAdjusted];
    
    _routePickingMode = YES;
    _centerPin.hidden = YES;
    
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStyleDone target:self action:@selector(go)];
    [self.navigationItem setRightBarButtonItem:barItem animated:YES];
    
    barItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleDone target:self action:@selector(transitionBack)];
    [self.navigationItem setLeftBarButtonItem:barItem animated:YES];
    
    [self.navigationItem setTitleView:_timeButton];
    
    [[TSEntourageSessionManager sharedManager].routeManager addRouteOverlaysAndAnnotations];
    [[TSEntourageSessionManager sharedManager].routeManager showAllRouteAnnotations];
}


- (void)transitionBack {
    
    [[TSEntourageSessionManager sharedManager].routeManager centerMapOnSelectedDestination];
    
    [self.navigationItem setRightBarButtonItem:_nextButton animated:YES];
    [self.navigationItem setLeftBarButtonItem:_cancelButton animated:YES];
    [self.navigationItem setTitleView:_directionsTypeSegmentedControl];
    
    [[TSEntourageSessionManager sharedManager].routeManager showTempDestinationAnnotationSelected:YES];
    [[TSEntourageSessionManager sharedManager].routeManager addOnlySelectedRouteOverlaysToMapView];
    
    _centerPin.hidden = NO;
    _routePickingMode = NO;
    
    if (![_addressLabel.text isEqualToString:[TSEntourageSessionManager sharedManager].routeManager.destinationMapItem.name]) {
        [_addressLabel setText:[TSEntourageSessionManager sharedManager].routeManager.destinationMapItem.name withAnimationType:kCATransitionPush direction:kCATransitionFromLeft duration:0.3];
    }
}


- (void)timeAdjusted {
    
    [_timeButton setTitle:[TSUtilities formattedStringForTime:[TSEntourageSessionManager sharedManager].routeManager.selectedTravelTime] forState:UIControlStateNormal];
    [_timeButton sizeToFit];
    [_timeButton setNeedsDisplay];
}

- (void)showTimeAdjustViewController {
    
    if (!_routePickingMode) {
        return;
    }
    
    if (!_topDownTransitioningDelegate) {
        _topDownTransitioningDelegate = [[TSTopDownTransitioningDelegate alloc] init];
    }
    
    [self presentViewControllerWithClass:[TSNotifySelectionViewController class] transitionDelegate:_topDownTransitioningDelegate animated:YES navigationBarHidden:NO];
}

- (void)go {
    
    [[TSEntourageSessionManager sharedManager] startTrackingWithETA:[TSEntourageSessionManager sharedManager].routeManager.selectedTravelTime completion:nil];
    
    [self drawerCanDragForContacts:YES];
    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        _routeInfoView.transform = CGAffineTransformMakeTranslation(0, -110);
    } completion:nil];
    
    [_homeViewController beginAppearanceTransition:YES animated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        [_homeViewController endAppearanceTransition];
    }];
}



- (void)monitorSelectedRoute {

    _kvoController = [FBKVOController controllerWithObserver:self];

    [_kvoController observe:[TSEntourageSessionManager sharedManager].routeManager keyPath:@"selectedRoute" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(TSRoutePickerViewController *weakSelf, TSRouteManager *routeManager, NSDictionary *change) {

        if (!routeManager.selectedRoute) {
            return;
        }
        
        if (!weakSelf.routePickingMode) {
            return;
        }
        
        [weakSelf timeAdjusted];

        NSString *formattedText = [NSString stringWithFormat:@"%@ - %@", [TSUtilities formattedDescriptiveStringForDuration:routeManager.selectedRoute.expectedTravelTime], [TSUtilities formattedStringForDistanceInUSStandard:routeManager.selectedRoute.distance]];

        [weakSelf.addressLabel setText:[NSString stringWithFormat:@"via %@", routeManager.selectedRoute.name] withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
        [weakSelf.etaLabel setText:formattedText withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
    }];
}


- (void)showRouteTutorial {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:TSRoutePickerViewControllerRouteTutorial]) {
        return;
    }
    
    _tutorialWindow = [[TSPopUpWindow alloc] initWithRepeatCheckBox:TSRoutePickerViewControllerRouteTutorial
                                                              title:TUTORIAL_TITLE_2
                                                            message:TUTORIAL_MESSAGE_2];
    [_tutorialWindow show];
}

@end
