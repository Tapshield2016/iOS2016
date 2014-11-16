//
//  TSEntourageMemberAnnotation.h
//  TapShield
//
//  Created by Adam Share on 11/14/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseMapAnnotation.h"
#import "TSJavelinAPIEntourageMember.h"

@interface TSEntourageMemberAnnotation : TSBaseMapAnnotation

@property (weak, nonatomic) TSJavelinAPIEntourageMember *member;

@end
