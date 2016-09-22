//
//  XJCollectionViewDataModel.h
//  Vidol
//
//  Created by XJIMI on 2015/10/6.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XJCollectionViewHeaderModel.h"
#import "XJCollectionViewCellModel.h"

@interface XJCollectionViewDataModel : NSObject

@property (nonatomic, strong) XJCollectionReusableModel *section;
@property (nonatomic, strong) NSMutableArray *rows;

+ (XJCollectionViewDataModel *)modelWithSection:(XJCollectionReusableModel *)reusableModel rows:(NSArray *)rows;

@end
