//
//  TSChatMessageCell.h
//  TapShield
//
//  Created by Adam Share on 4/12/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseTableViewCell.h"

extern NSString * const TSChatMessageCellIdentifierUser;
extern NSString * const TSChatMessageCellIdentifierDispatcher;

@interface TSChatMessageCell : TSBaseTableViewCell

@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UILabel *sideTimeStampLabel;
@property (strong, nonatomic) UILabel *headerTimeStampLabel;
@property (strong, nonatomic) UIImageView *userImageView;
@property (strong, nonatomic) TSJavelinAPIChatMessage *chatMessage;

@property (strong, nonatomic) UIView *roundRectView;
@property (strong, nonatomic) UIView *triangleView;

+ (CGFloat)heightForChatCellAtIndexPath:(NSIndexPath *)indexPath;

@end
