//
//  XJCollectionViewManager.m
//  Vidol
//
//  Created by XJIMI on 2015/10/6.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import "XJCollectionViewManager.h"

@interface XJCollectionViewManager () < UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout >

@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) NSMutableArray *registeredCells;
@property (nonatomic, copy)   XJCollectionViewForSupplementaryElementBlock viewForSupplementaryElementBlock;
@property (nonatomic, copy)   XJCollectionViewCellForItemBlock cellForItemBlock;
@property (nonatomic, copy)   XJCollectionViewWillDisplayCellBlock willDisplayCellBlock;
@property (nonatomic, copy)   XJCollectionViewDidSelectItemBlock didSelectItemBlock;

@end

@implementation XJCollectionViewManager

+ (instancetype)managerWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    return [[self alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self)
    {
        self.delegate = self;
        self.dataSource = self;
        self.data = [NSMutableArray array];
        self.registeredCells = [NSMutableArray array];
    }
    return self;
}

- (void)addViewForSupplementaryElementBlock:(XJCollectionViewForSupplementaryElementBlock)supplementaryElementBlock
{
    self.viewForSupplementaryElementBlock = supplementaryElementBlock;
}

- (void)addCellForItemBlock:(XJCollectionViewCellForItemBlock)itemBlock {
    self.cellForItemBlock = itemBlock;
}

- (void)addWillDisplayCellBlock:(XJCollectionViewWillDisplayCellBlock)cellBlock {
    self.willDisplayCellBlock = cellBlock;
}

- (void)addDidSelectItemBlock:(XJCollectionViewDidSelectItemBlock)itemBlock {
    self.didSelectItemBlock = itemBlock;
}

- (void)setData:(NSMutableArray *)data
{
    if (!data) data = [NSMutableArray array];
    
    [self registerCellWithData:data];
    
    if (data.count < _data.count && data) {
        [self setContentOffset:self.contentOffset animated:NO];
    }
    _data = data;
    [self reloadData];
}

- (void)insertData:(NSArray *)data
{
    if (!_data) _data = [NSMutableArray array];

    [self registerCellWithData:data];
    
    for (XJCollectionViewDataModel *dataModel in data)
    {
        if (dataModel.section)
        {
            [_data addObject:dataModel];
            NSInteger sectionNum = _data.count-1;
            [self insertSections:[NSIndexSet indexSetWithIndex:sectionNum]];
        }
        else if (dataModel.rows.count)
        {
            XJCollectionViewDataModel *curDataModel = _data.lastObject;
            [curDataModel.rows addObjectsFromArray:dataModel.rows];
            NSInteger sectionNum = _data.count-1;
            NSInteger itemNum = curDataModel.rows.count;
            NSInteger numberOfItems = [self numberOfItemsInSection:sectionNum];
            
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (NSUInteger i = numberOfItems; i < itemNum; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:sectionNum]];
            }
            
            [self insertItemsAtIndexPaths:indexPaths];
        }
    }
}
- (void)registerCellWithData:(NSArray *)data
{
    for (XJCollectionViewDataModel *dataModel in data)
    {
        if (dataModel.section)
        {
            NSString *reusableId = dataModel.section.identifier;
            
            if (![self.registeredCells containsObject:reusableId])
            {
                [self.registeredCells addObject:reusableId];
                NSString *kind = UICollectionElementKindSectionHeader;
                if([[NSBundle mainBundle] pathForResource:reusableId ofType:@"nib"])
                {
                    UINib *nib = [UINib nibWithNibName:reusableId bundle:nil];
                    [self registerNib:nib forSupplementaryViewOfKind:kind withReuseIdentifier:reusableId];
                }
                else
                {
                    Class class = NSClassFromString(reusableId);
                    [self registerClass:class forSupplementaryViewOfKind:kind withReuseIdentifier:reusableId];
                }
            }
        }
        
        if (dataModel.rows)
        {
            for (XJCollectionViewCellModel *cellModel in dataModel.rows)
            {
                
                NSString *cellId = cellModel.identifier;
                if ([self.registeredCells containsObject:cellId]) continue;
                [self.registeredCells addObject:cellId];
                if([[NSBundle mainBundle] pathForResource:cellId ofType:@"nib"])
                {
                    UINib *nib = [UINib nibWithNibName:cellId bundle:nil];
                    [self registerNib:nib forCellWithReuseIdentifier:cellId];
                }
                else
                {
                    Class class = NSClassFromString(cellId);
                    [self registerClass:class forCellWithReuseIdentifier:cellId];
                }
                
            }
        }
    }
}

#pragma mark - collection delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.data.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    XJCollectionViewDataModel *dataModel = self.data[section];
    if (dataModel.section) {
        return dataModel.section.size;
    }
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    XJCollectionViewDataModel *dataModel = self.data[indexPath.section];
    if (dataModel.section.identifier)
    {
        if([kind isEqual:UICollectionElementKindSectionHeader])
        {
            XJCollectionViewHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:dataModel.section.identifier forIndexPath:indexPath];
            if ([headerView respondsToSelector:@selector(reloadData:)])  [headerView reloadData:dataModel.section.data];
            if (self.viewForSupplementaryElementBlock) {
                self.viewForSupplementaryElementBlock (kind, dataModel.section, headerView, indexPath);
            }
            
            return headerView;
        }
        else if ([kind isEqual:UICollectionElementKindSectionFooter])
        {
            XJCollectionViewHeader *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:dataModel.section.identifier forIndexPath:indexPath];
            if ([footerView respondsToSelector:@selector(reloadData:)]) [footerView reloadData:dataModel.section.data];
            if (self.viewForSupplementaryElementBlock) {
                self.viewForSupplementaryElementBlock (kind, dataModel.section, footerView, indexPath);
            }

            return footerView;
        }
    }
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    XJCollectionViewDataModel *dataModel = self.data[section];
    return dataModel.rows.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XJCollectionViewDataModel *dataModel = self.data[indexPath.section];
    XJCollectionViewCellModel *cellModel = dataModel.rows[indexPath.row];
    return cellModel.size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XJCollectionViewDataModel *dataModel = self.data[indexPath.section];
    XJCollectionViewCellModel *cellModel = dataModel.rows[indexPath.row];
    XJCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellModel.identifier forIndexPath:indexPath];
    [cell layoutIfNeeded];
    if ([cell respondsToSelector:@selector(reloadData:)]) [cell reloadData:cellModel.data];
    if (self.cellForItemBlock) self.cellForItemBlock(cellModel, cell, indexPath);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    XJCollectionViewDataModel *dataModel = self.data[indexPath.section];
    XJCollectionViewCellModel *cellModel = dataModel.rows[indexPath.row];
    if (self.willDisplayCellBlock) self.willDisplayCellBlock(cellModel, (XJCollectionViewCell *)cell, indexPath);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.didSelectItemBlock)
    {
        XJCollectionViewDataModel *dataModel = self.data[indexPath.section];
        XJCollectionViewCellModel *cellModel = dataModel.rows[indexPath.row];
        self.didSelectItemBlock(cellModel, indexPath);
    }
}

@end
