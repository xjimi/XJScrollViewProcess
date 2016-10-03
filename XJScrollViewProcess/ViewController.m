//
//  ViewController.m
//  XJScrollViewProcess
//
//  Created by XJIMI on 2016/9/21.
//  Copyright © 2016年 XJIMI. All rights reserved.
//

#import "ViewController.h"
#import "XJTableViewManager.h"
#import "XJScrollViewProcess.h"
#import "PlayerRecommendCell.h"
#import "AFAppDotNetAPIClient.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet XJTableViewManager *tableView;
@property (nonatomic, strong) XJScrollViewProcess *scrollViewProcess;
@property (nonatomic, strong) XJTableViewDataModel *dataModel;
@property (nonatomic, strong) XJTableViewDataModel *dataModel2;
@property (nonatomic, strong) XJTableViewDataModel *dataModel3;

@property (nonatomic, assign) NSInteger dataLimitDisplay;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.dataLimitDisplay = 25;
    self.scrollViewProcess = [XJScrollViewProcess initWithScrollView:self.tableView];
    self.scrollViewProcess.dataLimitDisplay = self.dataLimitDisplay;
    __weak typeof(self)weakSelf = self;
    [self.scrollViewProcess addPullToRefreshWithBlock:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.scrollViewProcess.refreshDataModel = nil;
        });
        
    }];
    
    [self.scrollViewProcess addLoadMoreWithBlock:^{

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            /*
            NSInteger rows = [weakSelf.tableView numberOfRowsInSection:0];
            if (rows == self.dataLimitDisplay * 2) {
                [weakSelf create_dataModel3];
                weakSelf.scrollViewProcess.dataModel = weakSelf.dataModel3;

            } else {
            }
             /*/
            [weakSelf create_dataModel2];
            weakSelf.scrollViewProcess.dataModel = nil;
            
        });
            
    }];
    
    [weakSelf.scrollViewProcess addNetworkStatusChangeBlock:^(NetworkStatus netStatus) {
       
        if (netStatus != NotReachable) {
            weakSelf.scrollViewProcess.refreshDataModel = weakSelf.dataModel;
        } else {
            
        }
        
    }];

    
    
     //[ViewController globalTimelinePostsWithBlock:^(NSArray *posts, NSError *error) { }];

}







+ (NSURLSessionDataTask *)globalTimelinePostsWithBlock:(void (^)(NSArray *posts, NSError *error))block {
    return [[AFAppDotNetAPIClient sharedClient] GET:@"stream/0/posts/stream/global" parameters:nil progress:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"data"];
        NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
        NSLog(@"%@", postsFromResponse);
        
        
        if (block) {
            block([NSArray arrayWithArray:mutablePosts], nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}






- (XJTableViewDataModel *)dataModel
{
    NSMutableArray *rows = [NSMutableArray array];
    for (int i = 0; i < self.dataLimitDisplay*5 ; i++)
    {
        NSDictionary *obj = @{@"title":[NSString stringWithFormat:@"title : %d ", i ], @"subtitle":@"subtitle", @"imageName":@"pic"};
        PlayerRecommendModel *model = [PlayerRecommendModel new];
        model.title = obj[@"title"];
        model.subtitle = obj[@"subtitle"];
        model.imageName = obj[@"imageName"];
        XJTableViewCellModel *cellModel = [XJTableViewCellModel
                                           modelWithReuseIdentifier:[PlayerRecommendCell identifier]
                                           cellHeight:78.5f
                                           data:model];
        [rows addObject:cellModel];
    }
    
    return [XJTableViewDataModel modelWithSection:nil rows:rows];
}

- (void)create_dataModel2
{
    NSMutableArray *rows = [NSMutableArray array];
    for (int i = 0; i < 5 ; i++)
    {
        NSDictionary *obj = @{@"title":[NSString stringWithFormat:@"title 2 - : %d ", i ], @"subtitle":@"subtitle", @"imageName":@"pic"};
        PlayerRecommendModel *model = [PlayerRecommendModel new];
        model.title = obj[@"title"];
        model.subtitle = obj[@"subtitle"];
        model.imageName = obj[@"imageName"];
        XJTableViewCellModel *cellModel = [XJTableViewCellModel
                                           modelWithReuseIdentifier:[PlayerRecommendCell identifier]
                                           cellHeight:78.5f
                                           data:model];
        [rows addObject:cellModel];
    }
    
    self.dataModel2 = [XJTableViewDataModel modelWithSection:nil rows:rows];
}

- (void)create_dataModel3
{
    NSMutableArray *rows = [NSMutableArray array];
    for (int i = 0; i < 2 ; i++)
    {
        NSDictionary *obj = @{@"title":[NSString stringWithFormat:@"title 3 - : %d ", i ], @"subtitle":@"subtitle", @"imageName":@"pic"};
        PlayerRecommendModel *model = [PlayerRecommendModel new];
        model.title = obj[@"title"];
        model.subtitle = obj[@"subtitle"];
        model.imageName = obj[@"imageName"];
        XJTableViewCellModel *cellModel = [XJTableViewCellModel
                                           modelWithReuseIdentifier:[PlayerRecommendCell identifier]
                                           cellHeight:78.5f
                                           data:model];
        [rows addObject:cellModel];
    }
    
    self.dataModel3 = [XJTableViewDataModel modelWithSection:nil rows:rows];
}



@end
