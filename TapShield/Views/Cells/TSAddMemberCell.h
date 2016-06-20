//
//  TSAddMemberCell.h
//  TapShield
//
//  Created by Adam Share on 4/23/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSAddMemberCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *button;

- (void)addButtonTarget:(id)target action:(SEL)selector ;

@end
