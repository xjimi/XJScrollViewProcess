//
//  XJScrollViewProcess.m
//  XJScrollViewProcess
//
//  Created by XJIMI on 2016/9/21.
//  Copyright © 2016年 XJIMI. All rights reserved.
//

#import "XJScrollViewProcess.h"
#import "XJScrollViewBaseContent.h"
#import "SVPullToRefresh.h"

@interface XJScrollViewProcess ()

@property (nonatomic, assign) XJScrollViewState state;
@property (nonatomic, assign) UIScrollView *baseScrollView;
@property (nonatomic, strong) XJScrollViewBaseContent *baseContent;
@property (nonatomic, copy)   void (^refreshBlock)(void);
@property (nonatomic, copy)   void (^pullToRefreshBlock)(void);
@property (nonatomic, copy)   void (^loadMoreBlock)(void);
@property (nonatomic, assign, getter=isDataLoaded) BOOL dataLoaded;
@property (nonatomic, strong) XJNetworkStatusMonitor *networkStatusMonitor;

@end

@implementation XJScrollViewProcess

+ (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    return [[XJScrollViewProcess alloc] initWithScrollView:scrollView
                                 addPullToRefreshWithBlock:nil
                                      addLoadMoreWithBlock:nil];
}

+ (instancetype)initWithScrollView:(UIScrollView *)scrollView
         addPullToRefreshWithBlock:(void (^)(void))pullToRefreshBlock
              addLoadMoreWithBlock:(void (^)(void))loadMoreBlock
{
    return [[XJScrollViewProcess alloc] initWithScrollView:scrollView
                                 addPullToRefreshWithBlock:pullToRefreshBlock
                                      addLoadMoreWithBlock:loadMoreBlock];
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView
         addPullToRefreshWithBlock:(void (^)(void))pullToRefreshBlock
              addLoadMoreWithBlock:(void (^)(void))loadMoreBlock
{
    self = [super init];
    if (self)
    {
        _baseScrollView = scrollView;
        _baseContent = [XJScrollViewBaseContent initWithScrollView:scrollView addEmptyDataDidTapBlock:^{
            
        }];
        self.state = XJScrollViewStateInit;
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.dataLimitDisplay = 10;
    _dataTemp = [NSMutableArray array];
    _state = XJScrollViewStateInit;
    _pullToRefreshIndicatorStyle = UIActivityIndicatorViewStyleGray;
    _loadMoreIndicatorStyle = UIActivityIndicatorViewStyleGray;
}

- (void)setPullToRefreshIndicatorStyle:(UIActivityIndicatorViewStyle)pullToRefreshIndicatorStyle {
    _pullToRefreshIndicatorStyle = pullToRefreshIndicatorStyle;
    [_baseScrollView.pullToRefreshView setActivityIndicatorViewStyle:_pullToRefreshIndicatorStyle];
}

- (void)setLoadMoreIndicatorStyle:(UIActivityIndicatorViewStyle)loadMoreIndicatorStyle {
    _loadMoreIndicatorStyle = loadMoreIndicatorStyle;
    [_baseScrollView.infiniteScrollingView setActivityIndicatorViewStyle:_loadMoreIndicatorStyle];
}

- (void)addNetworkStatusChangeBlock:(void (^)(NetworkStatus netStatus))block
{
    if (_networkStatusMonitor) return;
    __weak typeof(self)weakSelf = self;
    _networkStatusMonitor = [XJNetworkStatusMonitor monitorWithNetworkStatusChange:^(NetworkStatus status) {
        
        if (status == NotReachable)
        {
            weakSelf.state = XJScrollViewStateNetworkError;
        }
        else
        {
            if (![_baseContent isEmptyData])
            {
                [_baseContent hideMessage];
                _baseScrollView.infiniteScrollingView.needDragToLoadMore = NO;
            }
        }
        
        //NSLog(@"call back state : ---------- %ld", (unsigned long)weakSelf.state);
        if (block) block(status);
        
    }];
}

- (void)addPullToRefreshWithBlock:(void (^)(void))pullToRefreshBlock
{
    if (!pullToRefreshBlock || _baseScrollView.pullToRefreshView) return;
    
    _pullToRefreshBlock = pullToRefreshBlock;
    __weak typeof(self) weakSelf = self;
    [_baseScrollView addPullToRefreshWithActionHandler:^{
        
        weakSelf.state = XJScrollViewStateLoadMoreLoadingData;
        if (weakSelf.pullToRefreshBlock) weakSelf.pullToRefreshBlock();
        
    }];
    
    _baseScrollView.showsPullToRefresh = NO;
    [_baseScrollView.pullToRefreshView setActivityIndicatorViewStyle:_pullToRefreshIndicatorStyle];
    [_baseScrollView.pullToRefreshView setTitle:nil forState:SVPullToRefreshStateAll];
    [_baseScrollView.pullToRefreshView setSubtitle:nil forState:SVPullToRefreshStateAll];
}

- (void)addLoadMoreWithBlock:(void (^)(void))loadMoreBlock
{
    if (!loadMoreBlock || _baseScrollView.infiniteScrollingView) return;
    
    _loadMoreBlock = loadMoreBlock;
    __weak typeof(self)weakSelf = self;
    [_baseScrollView addInfiniteScrollingWithActionHandler:^{
        
        weakSelf.state = XJScrollViewStateLoadMoreLoadingData;
        
        if (weakSelf.dataLoaded)
        {
            NSLog(@"最後資料了~~~");
            weakSelf.dataModel = weakSelf.dataTemp.lastObject;
            return;
        }

        if (weakSelf.loadMoreBlock) weakSelf.loadMoreBlock();
        
    }];
    weakSelf.baseScrollView.showsInfiniteScrolling = NO;
    [weakSelf.baseScrollView.infiniteScrollingView setActivityIndicatorViewStyle:_loadMoreIndicatorStyle];
}

- (BOOL)isLoadingData
{
    return (_state == XJScrollViewStateRefreshLoadingData ||
            _state == XJScrollViewStateLoadMoreLoadingData);
}

- (void)setState:(XJScrollViewState)state
{
    _state = state;
    switch (state)
    {
        case XJScrollViewStateInit:
        {
            [_baseContent showLoading];
        }
            break;
        case XJScrollViewStateRefreshLoadingData:
        {
            [_baseContent showLoading];
        }
            break;
        case XJScrollViewStateEmptyData:
        {
            [_baseContent showEmpty];
        }
            break;
        case XJScrollViewStateNetworkError:
        {
            [_baseContent showNetwrokError];
        }
            break;
        case XJScrollViewStatePullToRefreshFinish:
        {
            [_baseScrollView.pullToRefreshView stopAnimating];
        }
            break;
        case XJScrollViewStateLoadMoreShow:
        {
            _baseScrollView.showsInfiniteScrolling = YES;
            [_baseScrollView.infiniteScrollingView showIndicatorView];
        }
            break;
        case XJScrollViewStateLoadMoreLoadingData:
        {
        }
            break;
        case XJScrollViewStateLoadMoreDisable:
        {
            [_baseScrollView.infiniteScrollingView disableInfiniteScrolling];
        }
            break;
    }
}

- (void)setDataLimitDisplay:(NSInteger)dataLimitDisplay
{
    _dataLimitDisplay = dataLimitDisplay;
    _dataLimit = dataLimitDisplay;
}

- (NSInteger)dataLimit {
    return (_dataOffset) ? _dataLimit : (_dataLimit * 2);
}

- (void)setRefreshDataModel:(id)dataModel
{
    self.state = XJScrollViewStatePullToRefreshFinish;
    self.dataModel = dataModel;
}

- (void)setDataModel:(id)dataModel
{
    dataModel = [self processTableViewDataModel:dataModel];
    [self setTableViewDataModel:dataModel];
}

- (XJTableViewDataModel *)processTableViewDataModel:(XJTableViewDataModel *)dataModel
{
    if (!self.isDataLoaded)
    {
        NSLog(@" rows.count : %ld  dataLimit : %ld", (long)dataModel.rows.count, (long)self.dataLimit);
        if (dataModel.rows.count < self.dataLimit) {
            _dataLoaded = YES;
        }
        
        XJTableViewDataModel *dataModel_temps = _dataTemp.lastObject;
        NSArray *items;
        if (dataModel_temps.rows.count) {
            items = [dataModel_temps.rows arrayByAddingObjectsFromArray:dataModel.rows];
        } else {
            items = [dataModel.rows copy];
        }
        [dataModel.rows removeAllObjects];
        [_dataTemp removeAllObjects];
        
        NSMutableArray *rows_temp = [NSMutableArray array];
        for (XJTableViewCellModel *cellModel in items)
        {
            if (dataModel.rows.count < _dataLimitDisplay) {
                [dataModel.rows addObject:cellModel];
            } else {
                [rows_temp addObject:cellModel];
            }
        }
        
        if (rows_temp.count)
        {
            XJTableViewDataModel *dataModel_end = [XJTableViewDataModel
                                                   modelWithSection:dataModel.section
                                                   rows:rows_temp];
            [_dataTemp addObject:dataModel_end];
        }
    }
    else
    {
        [_dataTemp removeAllObjects];
    }
    
    return dataModel;
}

- (void)setTableViewDataModel:(XJTableViewDataModel *)dataModel
{
    XJTableViewManager *tableView = (XJTableViewManager *)self.baseScrollView;
    if (!tableView.data.count && !dataModel.rows.count)
    {
        [_baseContent showEmpty];
        return;
    }
    else if (tableView.data.count == 1)
    {
        XJTableViewDataModel *cur_dataModel = tableView.data[0];
        if (!cur_dataModel.rows.count && !dataModel.rows.count)
        {
            [_baseContent showEmpty];
            return;
        }
    }
    
    if (_state == XJScrollViewStatePullToRefreshFinish)
    {
        _dataOffset = 0;
        tableView.data = @[dataModel].mutableCopy;
    }
    else
    {
        [tableView insertData:@[dataModel]];
    }
    
    NSLog(@"loaded : %ld  dataLimit display: %ld  dataTemp.count: %ld", (long)dataModel.rows.count, (long)_dataLimitDisplay, (long)_dataTemp.count);
    if (dataModel.rows.count == _dataLimitDisplay && _dataTemp.count)
    {
        _dataOffset += self.dataLimit;
        self.state = XJScrollViewStateLoadMoreShow;
    }
    else
    {
        NSLog(@"load more end");
        self.state = XJScrollViewStateLoadMoreDisable;
    }
    
}


@end
