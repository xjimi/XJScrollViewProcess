//
//  XJTableViewManager.m
//  Vidol
//
//  Created by XJIMI on 2015/10/4.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import "XJTableViewManager.h"

@interface XJTableViewManager () < UITableViewDataSource, UITableViewDelegate >

@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) NSMutableArray *registeredCells;
@property (nonatomic, copy)   XJTableViewCellForRowBlock cellForRowBlock;
@property (nonatomic, copy)   XJTableViewWillDisplayCellBlock willDisplayCellBlock;
@property (nonatomic, copy)   XJTableViewDidSelectRowBlock didSelectRowBlock;
@property (nonatomic, copy)   XJScrollViewDidScrollBlock scrollViewDidScrollBlock;
@property (nonatomic, copy)   XJScrollViewWillBeginDraggingBlock scrollViewWillBeginDraggingBlock;

@end

@implementation XJTableViewManager

+ (instancetype)manager {
    return [self managerWithStyle:UITableViewStylePlain];
}

+ (instancetype)managerWithStyle:(UITableViewStyle)style {
    return [[self alloc] initWithFrame:CGRectZero style:style];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.delegate = self;
    self.dataSource = self;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.delaysContentTouches = YES;
    // Remove touch delay (since iOS 8)
    /*
    UIView *wrapView = self.subviews.firstObject;
    // UITableViewWrapperView
    if (wrapView && [NSStringFromClass(wrapView.class) hasSuffix:@"WrapperView"]) {
        for (UIGestureRecognizer *gesture in wrapView.gestureRecognizers) {
            // UIScrollViewDelayedTouchesBeganGestureRecognizer
            if ([NSStringFromClass(gesture.class) containsString:@"DelayedTouchesBegan"] ) {
                gesture.enabled = NO;
                break;
            }
        }
    }
    */
    self.data = [NSMutableArray array];
    self.registeredCells = [NSMutableArray array];
}

- (void)addDidSelectRowBlock:(XJTableViewDidSelectRowBlock)rowBlock {
    self.didSelectRowBlock = rowBlock;
}

- (void)addCellForRowBlock:(XJTableViewCellForRowBlock)rowBlock {
    self.cellForRowBlock = rowBlock;
}

- (void)addWillDisplayCellBlock:(XJTableViewWillDisplayCellBlock)cellBlock {
    self.willDisplayCellBlock = cellBlock;
}

- (void)addScrollViewDidScrollBlock:(XJScrollViewDidScrollBlock)scrollViewDidScrollBlock {
    self.scrollViewDidScrollBlock = scrollViewDidScrollBlock;
}

- (void)addScrollViewWillBeginDraggingBlock:(XJScrollViewWillBeginDraggingBlock)scrollViewWillBeginDraggingBlock {
    self.scrollViewWillBeginDraggingBlock = scrollViewWillBeginDraggingBlock;
}

- (void)setData:(NSMutableArray *)data
{
    if (!data) data = [NSMutableArray array];
    [self registerCellWithData:data];
    _data = data;
    [self reloadData];
}

- (void)insertData:(NSArray *)data {
    [self insertData:data withRowAnimation:UITableViewRowAnimationNone];
}

- (void)insertData:(NSArray *)data withRowAnimation:(UITableViewRowAnimation)animation
{
    if (!_data) _data = [NSMutableArray array];
    
    [self registerCellWithData:data];
    
    for (XJTableViewDataModel *dataModel in data)
    {
        if (dataModel.section)
        {
            [_data addObject:dataModel];
            NSInteger sectionNum = _data.count - 1;
            if (animation != UITableViewRowAnimationNone) {
                [self beginUpdates];
                [self insertSections:[NSIndexSet indexSetWithIndex:sectionNum] withRowAnimation:UITableViewRowAnimationNone];
                [self endUpdates];
            } else {
                [self reloadData];
            }
        }
        else if (dataModel.rows.count)
        {
            XJTableViewDataModel *curDataModel = _data.lastObject;
            [curDataModel.rows addObjectsFromArray:dataModel.rows];
            NSInteger sectionNum = _data.count - 1;
            NSInteger itemNum = curDataModel.rows.count;
            NSInteger numberOfRows = [self numberOfRowsInSection:sectionNum];
            
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (NSUInteger i = numberOfRows; i < itemNum; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:sectionNum]];
            }
            
            if (animation != UITableViewRowAnimationNone) {
                [self beginUpdates];
                [self insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                [self endUpdates];
            } else {
                [self reloadData];
            }
        }
    }
}

- (void)registerCellWithData:(NSArray *)data
{
    for (XJTableViewDataModel *dataModel in data)
    {
        if (dataModel.section)
        {
            NSString *reusableId = dataModel.section.identifier;
            
            if (![self.registeredCells containsObject:reusableId])
            {
                [self.registeredCells addObject:reusableId];
                if([[NSBundle mainBundle] pathForResource:reusableId ofType:@"nib"])
                {
                    UINib *nib = [UINib nibWithNibName:reusableId bundle:nil];
                    [self registerNib:nib forHeaderFooterViewReuseIdentifier:reusableId];
                }
                else
                {
                    Class class = NSClassFromString(reusableId);
                    [self registerClass:class forHeaderFooterViewReuseIdentifier:reusableId];
                }
            }
        }
        
        if (dataModel.rows)
        {
            for (XJTableViewCellModel *cellModel in dataModel.rows)
            {
                NSString *cellId = cellModel.identifier;
                if ([self.registeredCells containsObject:cellId]) continue;
                [self.registeredCells addObject:cellId];
                if([[NSBundle mainBundle] pathForResource:cellId ofType:@"nib"])
                {
                    UINib *nib = [UINib nibWithNibName:cellId bundle:nil];
                    [self registerNib:nib forCellReuseIdentifier:cellId];
                }
                else
                {
                    Class class = NSClassFromString(cellId);
                    [self registerClass:class forCellReuseIdentifier:cellId];
                }
                
            }
        }
    }
}

#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    XJTableViewDataModel *dataModel = self.data[section];
    return dataModel.section.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    XJTableViewDataModel *dataModel = self.data[section];
    XJTableViewHeader *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:dataModel.section.identifier];
    [headerView reloadData:dataModel.section.data];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    XJTableViewDataModel *dataModel = self.data[section];
    return dataModel.rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XJTableViewDataModel *dataModel = self.data[indexPath.section];
    XJTableViewCellModel *cellModel = dataModel.rows[indexPath.row];
    return cellModel.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XJTableViewDataModel *dataModel = self.data[indexPath.section];
    XJTableViewCellModel *cellModel = dataModel.rows[indexPath.row];
    XJTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellModel.identifier forIndexPath:indexPath];
    [cell layoutIfNeeded];
    [cell reloadData:cellModel.data];
    if (self.cellForRowBlock) self.cellForRowBlock(cellModel, cell, indexPath);
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    XJTableViewDataModel *dataModel = self.data[indexPath.section];
    XJTableViewCellModel *cellModel = dataModel.rows[indexPath.row];
    if (self.willDisplayCellBlock) self.willDisplayCellBlock(cellModel, (XJTableViewCell *)cell, indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self deselectRowAtIndexPath:indexPath animated:YES];
    if (self.didSelectRowBlock)
    {
        XJTableViewDataModel *dataModel = self.data[indexPath.section];
        XJTableViewCellModel *cellModel = dataModel.rows[indexPath.row];
        self.didSelectRowBlock(cellModel, indexPath);
    }
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollViewDidScrollBlock) {
        self.scrollViewDidScrollBlock (scrollView);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.scrollViewWillBeginDraggingBlock) {
        self.scrollViewWillBeginDraggingBlock (scrollView);
    }
}

@end
