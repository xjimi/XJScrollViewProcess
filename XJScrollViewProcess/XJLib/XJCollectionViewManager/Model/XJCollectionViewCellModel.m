//
//  XJCollectionViewCellModel.m
//  Vidol
//
//  Created by XJIMI on 2015/10/6.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import "XJCollectionViewCellModel.h"

@implementation XJCollectionViewCellModel

+ (XJCollectionViewCellModel *)modelWithReuseIdentifier:(NSString *)identifier size:(CGSize)size data:(id)data
{
    XJCollectionViewCellModel *cellModel = [[XJCollectionViewCellModel alloc] init];
    cellModel.identifier = identifier;
    cellModel.size = size;
    cellModel.data = data;
    return cellModel;
}

@end
