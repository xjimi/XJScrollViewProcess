//
//  XJTableViewCellModel.m
//  Vidol
//
//  Created by XJIMI on 2015/10/4.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import "XJTableViewCellModel.h"

@implementation XJTableViewCellModel

+ (XJTableViewCellModel *)modelWithReuseIdentifier:(NSString *)identifier cellHeight:(CGFloat)height data:(id)data
{
    XJTableViewCellModel *cellModel = [[XJTableViewCellModel alloc] init];
    cellModel.identifier = identifier;
    cellModel.height = height;
    cellModel.data = data;
    return cellModel;
}

@end
