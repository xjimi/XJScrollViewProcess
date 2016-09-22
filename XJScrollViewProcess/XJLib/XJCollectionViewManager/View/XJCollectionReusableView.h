//
//  XJCollectionViewReusableView.h
//  Vidol
//
//  Created by XJIMI on 2015/10/19.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XJCollectionReusableView : UICollectionReusableView

+ (NSString *)identifier;

+ (UINib *)nib;

- (void)reloadData:(id)data;

@end
