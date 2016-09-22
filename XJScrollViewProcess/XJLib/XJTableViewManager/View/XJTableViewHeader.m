//
//  XJTableViewHeader.m
//  Vidol
//
//  Created by XJIMI on 2015/10/5.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import "XJTableViewHeader.h"

@implementation XJTableViewHeader

+ (NSString *)identifier {
    return NSStringFromClass([self class]);
}

+ (UINib *)nib {
    return [UINib nibWithNibName:[self identifier] bundle:nil];
}

- (void)reloadData:(id)data {
}

@end
