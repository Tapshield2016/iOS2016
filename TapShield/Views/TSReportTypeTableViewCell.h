//
//  TSReportTypeTableViewCell.h
//  TapShield
//
//  Created by Adam Share on 6/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseTableViewCell.h"
#import "TSTintedImageView.h"

@interface TSReportTypeTableViewCell : TSBaseTableViewCell

@property (weak, nonatomic) IBOutlet TSTintedImageView *typeImageView;
@property (weak, nonatomic) IBOutlet TSBaseLabel *typeLabel;

- (void)setTypeForRow:(int)row;
+ (UIImage *)imageForType:(SocialReportTypes)type;

@end
