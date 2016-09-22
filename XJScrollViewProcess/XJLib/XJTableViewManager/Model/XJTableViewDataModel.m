//
//  XJTableViewDataModel.m
//  Vidol
//
//  Created by XJIMI on 2015/10/4.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import "XJTableViewDataModel.h"

@implementation XJTableViewDataModel

+ (XJTableViewDataModel *)modelWithSection:(XJTableViewHeaderModel *)headerModel rows:(NSArray *)rows
{
    XJTableViewDataModel *dataModel = [[XJTableViewDataModel alloc] init];
    dataModel.section = headerModel;
    dataModel.rows = rows.mutableCopy;
    return dataModel;
}

@end
