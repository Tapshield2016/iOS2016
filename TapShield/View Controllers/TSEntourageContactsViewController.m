//
//  TSEntourageContactsViewController.m
//  TapShield
//
//  Created by Adam Share on 10/24/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEntourageContactsViewController.h"
#import "TSJavelinAPIEntourageMember.h"
#import "TSEntourageContactTableViewCell.h"

@interface TSEntourageContactsViewController ()

@end

@implementation TSEntourageContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self checkStatus];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self checkStatus];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    
}

- (ABAuthorizationStatus)checkStatus {
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    
    switch (status) {
        case kABAuthorizationStatusAuthorized:
            
            _permissionsView.hidden = YES;
            
            if (!_tableViewController) {
                _tableViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSEntourageContactsTableViewController class])];
                _tableViewController.view.frame = CGRectMake(53, 0, self.view.frame.size.width-53, self.view.frame.size.height);
                [self.view addSubview:_tableViewController.view];
                [self addChildViewController:_tableViewController];
                [_tableViewController didMoveToParentViewController:self];
            }
            
            _tableViewController.view.hidden = NO;
            
            break;
            
        case kABAuthorizationStatusRestricted:
            //The app is not authorized to access address book data. The user cannot change this access, possibly due to restrictions such as parental controls.
            _permissionsView.hidden = NO;
            _tableViewController.view.hidden = YES;
            
            [_permissionsButton setTitle:@"Change Settings" forState:UIControlStateNormal];
            _descriptionLabel.text = @"Sorry it seems access to your address book is unavailable, , possibly due to restrictions such as parental controls.";
            
            break;
            
        case kABAuthorizationStatusDenied:
            //The user explicitly denied access to address book data for this app.
            
            [_permissionsButton setTitle:@"Change Settings" forState:UIControlStateNormal];
            
            break;
            
        case kABAuthorizationStatusNotDetermined:
            //No authorization status could be determined.
            
            
            
            [_permissionsButton setTitle:@"Get Started" forState:UIControlStateNormal];
            
        default:
            _permissionsView.hidden = NO;
            _tableViewController.view.hidden = YES;
            
            _descriptionLabel.text = @"Entourage requires access to your contacts. Tap the button below to give TapShield permission.";
            
            break;
    }
    
    return status;
}


- (IBAction)getPermission:(id)sender {
    
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    if (error) {
        NSLog(@"error");
    }
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        
        ABAuthorizationStatus status = [self checkStatus];
        if (status == kABAuthorizationStatusDenied ||
            status == kABAuthorizationStatusRestricted) {
            [TSAppDelegate openSettings];
        }
    });
    
}


@end
