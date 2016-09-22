//
//  XJScrollViewBaseContent.h
//  XJScrollViewProcess
//
//  Created by XJIMI on 2016/9/21.
//  Copyright © 2016年 XJIMI. All rights reserved.
//

#define fontHelveticaNeueLight(fontSize)   [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize]
#define fontHelveticaNeueRegular(fontSize) [UIFont fontWithName:@"HelveticaNeue" size:fontSize]

#import <Foundation/Foundation.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <Masonry/Masonry.h>

@interface EmptyDataModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, strong) UIView *customView;

+ (instancetype)modelWithTitle:(NSString *)title
                          desc:(NSString *)desc
                     imageName:(NSString *)imageName
                    customView:(UIView *)customView;
@end

typedef void (^XJScrollViewEmptyDataDidTapBlock)(void);

@interface XJScrollViewBaseContent : NSObject <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, assign) UIScrollView *baseScrollView;
@property (nonatomic, strong) EmptyDataModel *emptyData;
@property (nonatomic, strong) EmptyDataModel *networkErrorData;
@property (nonatomic, strong) UIColor *emptyDataTextColor;

+ (instancetype)initWithScrollView:(UIScrollView *)scrollView addEmptyDataDidTapBlock:(XJScrollViewEmptyDataDidTapBlock)emptyDataDidTapBlock;

- (void)showLoading;

- (void)showEmpty;

- (void)showNetwrokError;

- (void)showMessage:(NSString *)message;

- (void)hideMessage;

- (BOOL)isEmptyData;

@end
