//
//  XJScrollViewBaseContent.m
//  XJScrollViewProcess
//
//  Created by XJIMI on 2016/9/21.
//  Copyright © 2016年 XJIMI. All rights reserved.
//

#import "XJScrollViewBaseContent.h"
#import "XJMessageBar.h"

@implementation EmptyDataModel

+ (instancetype)modelWithTitle:(NSString *)title
                          desc:(NSString *)desc
                     imageName:(NSString *)imageName
                    customView:(UIView *)customView
{
    EmptyDataModel *emptyDataModel = [[EmptyDataModel alloc] init];
    emptyDataModel.title = title;
    emptyDataModel.desc = desc;
    emptyDataModel.imageName = imageName;
    emptyDataModel.customView = customView;
    return emptyDataModel;
}

@end

@interface XJScrollViewBaseContent ()

@property (nonatomic, strong) EmptyDataModel *displayData;
@property (nonatomic, strong) XJMessageBar *messageBar;
@property (nonatomic, copy)   XJScrollViewEmptyDataDidTapBlock emptyDataDidTapBlock;

@end

@implementation XJScrollViewBaseContent

+ (instancetype)initWithScrollView:(UIScrollView *)scrollView addEmptyDataDidTapBlock:(XJScrollViewEmptyDataDidTapBlock)emptyDataDidTapBlock
{
    XJScrollViewBaseContent *baseContent = [[XJScrollViewBaseContent alloc] initWithScrollView:scrollView];
    baseContent.emptyDataDidTapBlock = emptyDataDidTapBlock;
    return baseContent;
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    self = [super init];
    if (self)
    {
        _baseScrollView = scrollView;
        _baseScrollView.emptyDataSetSource = self;
        _baseScrollView.emptyDataSetDelegate = self;
        [self setup];
    }
    return self;
}

- (void)setup
{
    _emptyData = [EmptyDataModel modelWithTitle:@"No content yet" desc:nil imageName:nil customView:nil];
    _networkErrorData = [EmptyDataModel modelWithTitle:@"Network error" desc:nil imageName:nil customView:nil];
    [self createMessageBar];
}

- (void)createMessageBar
{
    _messageBar = [XJMessageBar messageBarType:XJMessageBarTypeTop dismissWhenTouch:YES showInView:self.baseScrollView.superview];
    _messageBar.verticalPadding = 10.0f;
    _messageBar.bgColor = [[UIColor darkGrayColor] colorWithAlphaComponent:.95];
}

- (void)showLoading
{
    _displayData = [EmptyDataModel modelWithTitle:nil desc:nil imageName:nil customView:[self loadingView]];
    [_baseScrollView reloadEmptyDataSet];
    [_messageBar hide];
}

- (void)showEmpty
{
    _displayData = _emptyData;
    [_baseScrollView reloadEmptyDataSet];
    [_messageBar hide];
}

- (void)showNetwrokError
{
    _displayData = _networkErrorData;
    [_baseScrollView reloadEmptyDataSet];
    [self showMessage:_displayData.title];
}

- (void)showMessage:(NSString *)message
{
    [_messageBar showMessage:message];
}

- (void)hideMessage
{
    [_messageBar hide];
}

#pragma mark - DZNEmptyDataSetSource Methods

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    return _displayData.customView;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:_displayData.imageName];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    return [self attributedStringWithString:_displayData.title];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    return [self attributedStringWithString:_displayData.desc];
}

#pragma mark - DZNEmptyDataSetDelegate Methods

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

- (void)emptyDataSetDidTapView:(UIScrollView *)scrollView
{
    if (self.emptyDataDidTapBlock) self.emptyDataDidTapBlock();
}

- (BOOL)isEmptyData
{
    return ![XJScrollViewBaseContent itemCountInScrollView:self.baseScrollView];
}

+ (NSInteger)itemCountInScrollView:(UIScrollView *)scrollView
{
    NSInteger items = 0;
    
    if (![scrollView respondsToSelector:@selector(dataSource)]) {
        return items;
    }
    
    if ([scrollView isKindOfClass:[UITableView class]])
    {
        id <UITableViewDataSource> dataSource = [scrollView performSelector:@selector(dataSource)];
        UITableView *tableView = (UITableView *)scrollView;
        
        NSInteger sections = 1;
        if ([dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }
        
        for (NSInteger i = 0; i < sections; i++) {
            items += [dataSource tableView:tableView numberOfRowsInSection:i];
        }
    }
    else if ([scrollView isKindOfClass:[UICollectionView class]])
    {
        id <UICollectionViewDataSource> dataSource = [scrollView performSelector:@selector(dataSource)];
        UICollectionView *collectionView = (UICollectionView *)scrollView;
        
        NSInteger sections = 1;
        if ([dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }
        
        for (NSInteger i = 0; i < sections; i++) {
            items += [dataSource collectionView:collectionView numberOfItemsInSection:i];
        }
    }
    
    return items;
}

#pragma mark - loadingView and NSAttributedString

- (UIView *)loadingView
{
    UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.tag = 101;
    activityView.translatesAutoresizingMaskIntoConstraints = NO;
    [activityView startAnimating];
    [loadingView addSubview:activityView];
    
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = activityView.color;
    label.font = [UIFont systemFontOfSize:14.0];
    label.text = @"";
    [loadingView addSubview:label];
    
    [activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(loadingView).centerOffset(CGPointMake(0, 0));
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(loadingView);
        make.height.equalTo(@(20));
        make.top.equalTo(activityView.mas_bottom);
    }];
    
    return loadingView;
}

- (NSAttributedString *)attributedStringWithString:(NSString *)string
{
    if (!string) return nil;
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    text = string;
    font = fontHelveticaNeueRegular(16);
    textColor = self.emptyDataTextColor;
    
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSMutableAttributedString *)mutableAttributedStringWithString:(NSString *)string
{
    if (!string) return nil;
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    text = string;
    font = fontHelveticaNeueRegular(14);
    textColor = self.emptyDataTextColor;
    
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    if (paragraph) [attributes setObject:paragraph forKey:NSParagraphStyleAttributeName];
    return [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
}

@end
