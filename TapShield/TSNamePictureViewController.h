//
//  TSNamePictureViewController.h
//  TapShield
//
//  Created by Adam Share on 5/12/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TSRegistrationTextField.h"
#import "TSRoundImageView.h"

@interface TSNamePictureViewController : TSNavigationViewController <UIAlertViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet TSRoundImageView *imageView;
@property (weak, nonatomic) IBOutlet TSRegistrationTextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet TSRegistrationTextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)dismissRegistration:(id)sender;

@end
