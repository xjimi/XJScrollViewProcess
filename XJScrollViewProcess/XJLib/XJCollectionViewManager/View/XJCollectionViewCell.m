//
//  XJCollectionViewCell.m
//  Vidol
//
//  Created by XJIMI on 2015/10/6.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import "XJCollectionViewCell.h"

@implementation XJCollectionViewCell

+ (NSString *)identifier {
    return NSStringFromClass([self class]);
}

+ (UINib *)nib {
    return [UINib nibWithNibName:[self identifier] bundle:nil];
}

- (void)reloadData:(id)data
{
    
}

@end
