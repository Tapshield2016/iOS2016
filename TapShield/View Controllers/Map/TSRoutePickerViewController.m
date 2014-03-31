//
//  TSRoutePickerViewController.m
//  TapShield
//
//  Created by Adam Share on 3/27/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRoutePickerViewController.h"

@interface TSRoutePickerViewController ()

@end

@implementation TSRoutePickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _directionsTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Car", @"Walk"]];
    _directionsTypeSegmentedControl.tintColor = [TSColorPalette tapshieldBlue];
    
    _directionsTransportType = MKDirectionsTransportTypeAutomobile;
    [_directionsTypeSegmentedControl addTarget:self
                                        action:@selector(transportTypeSegmentedControlValueChanged:)
                              forControlEvents:UIControlEventValueChanged];
    
    [self.navigationItem setTitleView:_directionsTypeSegmentedControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UISegmentedControl event handlers

- (void)transportTypeSegmentedControlValueChanged:(id)sender {
    switch ([_directionsTypeSegmentedControl selectedSegmentIndex]) {
            
        case 0:
            _directionsTransportType = MKDirectionsTransportTypeAutomobile;
            break;
            
        case 1:
            _directionsTransportType = MKDirectionsTransportTypeWalking;
            break;
            
        default:
            _directionsTransportType = MKDirectionsTransportTypeAny;
            break;
    }
}


@end
