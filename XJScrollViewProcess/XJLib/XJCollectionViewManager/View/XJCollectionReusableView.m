//
//  XJCollectionViewReusableView.m
//  Vidol
//
//  Created by XJIMI on 2015/10/19.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import "XJCollectionReusableView.h"

@implementation XJCollectionReusableView

+ (NSString *)identifier {
    return NSStringFromClass([self class]);
}

+ (UINib *)nib {
    return [UINib nibWithNibName:[self identifier] bundle:nil];
}

- (void)reloadData:(id)data {
}

@end
