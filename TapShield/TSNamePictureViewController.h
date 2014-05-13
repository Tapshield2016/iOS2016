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

@interface TSNamePictureViewController : TSNavigationViewController <UIAlertViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet TSRoundImageView *imageView;
@property (weak, nonatomic) IBOutlet TSRegistrationTextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet TSRegistrationTextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *showAgreement;
@property (weak, nonatomic) IBOutlet UIButton *checkBox;

- (IBAction)done:(id)sender;
- (IBAction)displayAgreement:(id)sender;
- (IBAction)selectBox:(id)sender;

@end
