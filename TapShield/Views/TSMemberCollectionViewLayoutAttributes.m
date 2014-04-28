//
//  TSMemberCollectionViewLayoutAttributes.m
//  TapShield
//
//  Created by Adam Share on 4/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSMemberCollectionViewLayoutAttributes.h"

@implementation TSMemberCollectionViewLayoutAttributes

+ (instancetype)layoutAttributesForCellWithIndexPath:(NSIndexPath *)indexPath {
    
    TSMemberCollectionViewLayoutAttributes *attributes = [[TSMemberCollectionViewLayoutAttributes alloc] init];
    attributes.frame = CGRectMake(0, 0, 100, 97);
    
    return attributes;
}

//+ (instancetype)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind withIndexPath:(NSIndexPath *)indexPath {
//    
//}
//
//+ (instancetype)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind withIndexPath:(NSIndexPath *)indexPath {
//    
//    
//}

@end
