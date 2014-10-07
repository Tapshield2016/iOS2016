//
//  TSBottomMapButton.h
//  TapShield
//
//  Created by Adam Share on 3/26/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSCircularButton.h"

@interface TSBottomMapButton : TSCircularButton

- (void)setLabelTitle:(NSString *)title;

@property (assign) UIEdgeInsets originalImageInsets;
@property (assign) UIEdgeInsets originalTitleInsets;
@property (strong, nonatomic) UILabel *label;
@property (assign, nonatomic) NSInteger labelYOffset;

@end
