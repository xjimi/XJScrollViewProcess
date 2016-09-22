//
//  XJCollectionViewCell.h
//  Vidol
//
//  Created by XJIMI on 2015/10/6.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XJCollectionViewCell : UICollectionViewCell

+ (NSString *)identifier;

+ (UINib *)nib;

- (void)reloadData:(id)data;

@end
