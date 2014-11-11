//
//  TSEntourageContactTableViewCell.h
//  TapShield
//
//  Created by Adam Share on 10/25/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSJavelinAPIEntourageMember.h"

@interface TSEntourageContactTableViewCell : UITableViewCell

@property (nonatomic, strong) TSJavelinAPIEntourageMember *contact;

@property (assign, nonatomic) NSUInteger originalWidth;

@property (nonatomic, strong) UIImageView *contactImageView;
@property (nonatomic, strong) UILabel *contactNameLabel;

- (void)emptyCell;
+ (CGFloat)selectedHeight;
+ (CGFloat)height;

@end
