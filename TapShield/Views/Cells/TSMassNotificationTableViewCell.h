//
//  TSMassNotificationTableViewCell.h
//  TapShield
//
//  Created by Adam Share on 5/27/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseTableViewCell.h"

@interface TSMassNotificationTableViewCell : TSBaseTableViewCell

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet TSBaseLabel *timestampLabel;

@end
