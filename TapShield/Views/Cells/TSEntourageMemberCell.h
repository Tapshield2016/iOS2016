//
//  TSEntourageMemberCell.h
//  TapShield
//
//  Created by Adam Share on 4/23/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSJavelinAPIEntourageMember.h"
#import "TSBaseLabel.h"

@interface TSEntourageMemberCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet TSBaseLabel *label;

@property (strong, nonatomic) id target;
@property (strong, nonatomic) TSJavelinAPIEntourageMember *member;

- (void)addButtonTarget:(id)target action:(SEL)selector;

@end
