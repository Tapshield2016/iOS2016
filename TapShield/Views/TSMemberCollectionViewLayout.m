//
//  TSMemberCollectionViewLayout.m
//  TapShield
//
//  Created by Adam Share on 4/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSMemberCollectionViewLayout.h"
#import "TSMemberCollectionViewLayoutAttributes.h"
#import "TSNotifySelectionViewController.h"
#import "TSAddMemberCell.h"

@implementation TSMemberCollectionViewLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.minimumLineSpacing = 10;
        self.minimumInteritemSpacing = 5;
        self.itemSize = CGSizeMake(100, 97);
        self.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.minimumLineSpacing = 10;
        self.minimumInteritemSpacing = 5;
        self.itemSize = CGSizeMake(100, 97);
        self.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    }
    return self;
}

- (CGSize)collectionViewContentSize {
    
    CGSize size = [super collectionViewContentSize];
    
    return size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    return array;
}

//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
//    
//    return [self adjustAttributesforOffset:attributes atIndexPath:indexPath];
//}

- (void)finalizeCollectionViewUpdates {
    
    NSArray *array = [self.collectionView.visibleCells copy];
    for (UICollectionViewCell *cell in array) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        [self adjustAttributesForCellAtIndexPath:indexPath];
    }
}

- (void)adjustAttributesForCellAtIndexPath:(NSIndexPath *)indexPath{
    
    TSEntourageMemberCell *cell = (TSEntourageMemberCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    float cellHeight = 107;
    
    float offset = self.collectionView.contentOffset.y + INSET;
    int page = offset/cellHeight;
    
    offset -= cellHeight * page;
    float ratio = offset/cellHeight;
    float ratioChange = 1 - ratio;
    float acceleratedAlpha = 1 - (ratio * 1.5);
    
    if (offset < 0) {
        return;
    }
    
    if (cell.frame.origin.y < (page + 1) * cellHeight) {
        cell.alpha = acceleratedAlpha;
        cell.transform = CGAffineTransformMakeScale(ratioChange, ratioChange);
    }
    else {
        cell.alpha = 1.0;
        cell.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }
    
    if (cell.frame.origin.y < page * cellHeight) {
        cell.alpha = 0.0;
    }
}

@end
