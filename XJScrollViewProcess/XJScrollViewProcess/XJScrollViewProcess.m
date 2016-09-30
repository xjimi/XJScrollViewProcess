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
@property (nonatomic, assign, getter=isDataFinish) BOOL dataFinish;
@property (nonatomic, strong) XJNetworkStatusMonitor *networkStatusMonitor;

@end

@implementation XJScrollViewProcess

+ (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    return [[XJScrollViewProcess alloc] initWithScrollView:scrollView];
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    self = [super init];
    if (self)
    {
        _baseScrollView = scrollView;
        __weak typeof(self)weakSelf = self;
        _baseContent = [XJScrollViewBaseContent
                        initWithScrollView:scrollView
                        addEmptyDataDidTapBlock:^
        {
            if (weakSelf.state == XJScrollViewStateNetworkError)
            {
                weakSelf.state = XJScrollViewStateRefreshLoadingData;
                if (weakSelf.pullToRefreshBlock) weakSelf.pullToRefreshBlock();
            }
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
                NSLog(@"%@", _baseScrollView.infiniteScrollingView);
                _baseScrollView.infiniteScrollingView.useOriginalLoadMore = NO;
            }
        }
        
        //NSLog(@"call back state : ---------- %ld", (unsigned long)weakSelf.state);
        if (block) block(status);
        
    }];
}

- (void)addPullToRefreshWithBlock:(void (^)(void))pullToRefreshBlock
{
    if (!pullToRefreshBlock) return;
    _pullToRefreshBlock = pullToRefreshBlock;
    __weak typeof(self) weakSelf = self;
    [_baseScrollView addPullToRefreshWithActionHandler:^{
        
        [_baseContent hideMessage];
        if ([weakSelf isLoadingData])
        {
            [weakSelf.baseScrollView.pullToRefreshView stopAnimating];
            [weakSelf.baseContent showMessage:@"is loading data"];
        }
        else
        {
            weakSelf.state = XJScrollViewStateRefreshLoadingData;
            if (weakSelf.pullToRefreshBlock) weakSelf.pullToRefreshBlock();
        }
        
    }];
    
    _baseScrollView.showsPullToRefresh = NO;
    [_baseScrollView.pullToRefreshView setActivityIndicatorViewStyle:_pullToRefreshIndicatorStyle];
    [_baseScrollView.pullToRefreshView setTitle:nil forState:SVPullToRefreshStateAll];
    [_baseScrollView.pullToRefreshView setSubtitle:nil forState:SVPullToRefreshStateAll];
}

- (void)addLoadMoreWithBlock:(void (^)(void))loadMoreBlock {
    _loadMoreBlock = loadMoreBlock;
}

- (void)addLoadMore
{
    if (_baseScrollView.infiniteScrollingView) return;
    __weak typeof(self)weakSelf = self;
    [_baseScrollView addInfiniteScrollingWithActionHandler:^{
        
        NSLog(@"--------------- trigger load more-----------------");

        [_baseContent hideMessage];
        if ([weakSelf isLoadingData])
        {
            [weakSelf.baseContent showMessage:@"資料讀取中...請稍候"];
        }
        else
        {
            weakSelf.state = XJScrollViewStateLoadMoreLoadingData;
            if (weakSelf.isDataFinish)
            {
                NSLog(@"load more 已經沒資料了 把剩下的資料顯示完");
                weakSelf.dataModel = [XJTableViewDataModel modelWithSection:nil rows:[NSMutableArray array]];
                return;
            }
            
            if (weakSelf.loadMoreBlock) weakSelf.loadMoreBlock();
        }
        
    }];

    _baseScrollView.infiniteScrollingView.useOriginalLoadMore = NO;
    [_baseScrollView.infiniteScrollingView setActivityIndicatorViewStyle:_loadMoreIndicatorStyle];
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
            _dataOffset = 0;
            _dataFinish = NO;
            [_baseContent hideMessage];
            [_dataTemp removeAllObjects];
            [_baseScrollView.pullToRefreshView stopAnimating];
        }
            break;
        case XJScrollViewStateLoadMoreShow:
        {
            NSLog(@"XJScrollViewStateLoadMore -- Show ");
            [self addLoadMore];
            [_baseContent hideMessage];
            [_baseScrollView.infiniteScrollingView stopAnimating];
            [_baseScrollView.infiniteScrollingView showIndicatorView];
            //[_baseScrollView.infiniteScrollingView disableInfiniteScrolling];
            _baseScrollView.showsInfiniteScrolling = YES;
        }
            break;
        case XJScrollViewStateLoadMoreLoadingData:
        {
            [_baseContent hideMessage];
        }
            break;
        case XJScrollViewStateLoadMoreDisable:
        {
            [_baseContent hideMessage];
            _baseScrollView.showsInfiniteScrolling = NO;
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
    if (!dataModel)
    {
        self.state = XJScrollViewStateNetworkError;
        return;
    }
    
    if (!_baseScrollView.showsPullToRefresh) {
        _baseScrollView.showsPullToRefresh = YES;
    }
    
    self.state = XJScrollViewStatePullToRefreshFinish;
    self.dataModel = dataModel;
}

- (void)setDataModel:(id)dataModel
{
    if (!dataModel) {
        self.state = XJScrollViewStateNetworkError;
        return;
    }
    dataModel = [self processTableViewDataModel:dataModel];
    [self setTableViewDataModel:dataModel];
}

- (XJTableViewDataModel *)processTableViewDataModel:(XJTableViewDataModel *)dataModel
{
    if (self.isDataFinish && _dataTemp.count == 0)
    {
        [_dataTemp removeAllObjects];
    }
    else
    {
        NSLog(@"%ld ==== %ld", (long)dataModel.rows.count , (long)self.dataLimit);
        if (dataModel.rows.count < self.dataLimit) {
            _dataFinish = YES;
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
