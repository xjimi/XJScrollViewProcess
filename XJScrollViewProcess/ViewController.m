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

@interface ViewController ()

@property (nonatomic, weak) IBOutlet XJTableViewManager *tableView;
@property (nonatomic, strong) XJScrollViewProcess *scrollViewProcess;
@property (nonatomic, strong) XJTableViewDataModel *dataModel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    __weak typeof(self)weakSelf = self;
    self.scrollViewProcess = [XJScrollViewProcess initWithScrollView:self.tableView];
    [self.scrollViewProcess addPullToRefreshWithBlock:^{
        weakSelf.scrollViewProcess.refreshDataModel = weakSelf.dataModel;
    }];
    
    [self.scrollViewProcess addLoadMoreWithBlock:^{
        NSLog(@"load moreeerere");
        weakSelf.scrollViewProcess.dataModel = [weakSelf dataModel2];
    }];
    
    [weakSelf.scrollViewProcess addNetworkStatusChangeBlock:^(NetworkStatus netStatus) {
       
        if (netStatus != NotReachable) {
            weakSelf.scrollViewProcess.refreshDataModel = weakSelf.dataModel;
        } else {
            
        }
        
    }];

}














- (XJTableViewDataModel *)dataModel
{
    NSArray *data = @[@{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"}
                      ];
    
    NSMutableArray *rows = [NSMutableArray array];
    for (NSDictionary *obj in data)
    {
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

- (XJTableViewDataModel *)dataModel2
{
    NSArray *data = @[@{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"},
                      @{@"title":@"title", @"subtitle":@"subtitle", @"imageName":@"pic"}
                      ];
    
    NSMutableArray *rows = [NSMutableArray array];
    for (NSDictionary *obj in data)
    {
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


@end
