//
//  XJScrollViewProcess.h
//  XJScrollViewProcess
//
//  Created by XJIMI on 2016/9/21.
//  Copyright © 2016年 XJIMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "XJTableViewManager.h"
#import "XJNetworkStatusMonitor.h"

typedef NS_ENUM(NSInteger, XJScrollViewState) {
    XJScrollViewStateInit = 0,
    XJScrollViewStateRefreshLoadingData = 1,
    XJScrollViewStateEmptyData,
    XJScrollViewStateNetworkError,
    
    XJScrollViewStatePullToRefreshFinish,
    
    XJScrollViewStateLoadMoreShow,
    XJScrollViewStateLoadMoreLoadingData,
    XJScrollViewStateLoadMoreDisable
};

@interface XJScrollViewProcess : NSObject

@property (nonatomic, strong) id refreshDataModel;
@property (nonatomic, strong) id dataModel;
@property (nonatomic, assign) UIActivityIndicatorViewStyle pullToRefreshIndicatorStyle;
@property (nonatomic, assign) UIActivityIndicatorViewStyle loadMoreIndicatorStyle;
@property (nonatomic, assign) NSInteger dataOffset;
@property (nonatomic, assign) NSInteger dataLimit;
@property (nonatomic, assign) NSInteger dataLimitDisplay;
@property (nonatomic, strong) NSMutableArray *dataTemp;

+ (instancetype)initWithScrollView:(UIScrollView *)scrollView;

- (void)addPullToRefreshWithBlock:(void (^)(void))pullToRefreshBlock;

- (void)addLoadMoreWithBlock:(void (^)(void))loadMoreBlock;

- (void)addNetworkStatusChangeBlock:(void (^)(NetworkStatus netStatus))block;

@end
