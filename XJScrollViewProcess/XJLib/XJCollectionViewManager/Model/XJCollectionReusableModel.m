//
//  XJCollectionViewReusableModel.m
//  Vidol
//
//  Created by XJIMI on 2015/10/19.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import "XJCollectionReusableModel.h"

@implementation XJCollectionReusableModel

+ (XJCollectionReusableModel *)modelWithReuseIdentifier:(NSString *)identifier size:(CGSize)size data:(id)data
{
    XJCollectionReusableModel *headerModel = [[XJCollectionReusableModel alloc] init];
    headerModel.identifier = identifier;
    headerModel.size = size;
    headerModel.data = data;
    return headerModel;
}

@end
