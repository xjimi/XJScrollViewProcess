//
//  XJCollectionViewManager.h
//  Vidol
//
//  Created by XJIMI on 2015/10/6.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJCollectionViewDataModel.h"
#import "XJCollectionViewHeaderModel.h"
#import "XJCollectionViewCellModel.h"
#import "XJCollectionViewHeader.h"
#import "XJCollectionViewCell.h"

typedef void (^XJCollectionViewForSupplementaryElementBlock) (NSString *kind, XJCollectionReusableModel *reusableModel, XJCollectionReusableView *reusableView, NSIndexPath *indexPath);

typedef void (^XJCollectionViewCellForItemBlock) (XJCollectionViewCellModel *cellModel, XJCollectionViewCell *cell, NSIndexPath *indexPath);

typedef void (^XJCollectionViewWillDisplayCellBlock) (XJCollectionViewCellModel *cellModel, XJCollectionViewCell *cell, NSIndexPath *indexPath);

typedef void (^XJCollectionViewDidSelectItemBlock) (XJCollectionViewCellModel *cellModel, NSIndexPath *indexPath);

@interface XJCollectionViewManager : UICollectionView

@property (nonatomic, strong) NSMutableArray *data;

+ (instancetype)managerWithCollectionViewLayout:(UICollectionViewLayout *)layout;

- (void)addViewForSupplementaryElementBlock:(XJCollectionViewForSupplementaryElementBlock)supplementaryElementBlock;
- (void)addCellForItemBlock:(XJCollectionViewCellForItemBlock)itemBlock;
- (void)addWillDisplayCellBlock:(XJCollectionViewWillDisplayCellBlock)cellBlock;
- (void)addDidSelectItemBlock:(XJCollectionViewDidSelectItemBlock)itemBlock;

- (void)insertData:(NSArray *)data;

@end
