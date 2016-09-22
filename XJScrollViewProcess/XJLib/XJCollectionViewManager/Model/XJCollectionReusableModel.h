//
//  XJCollectionViewReusableModel.h
//  Vidol
//
//  Created by XJIMI on 2015/10/19.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XJCollectionReusableModel : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) id data;

+ (XJCollectionReusableModel *)modelWithReuseIdentifier:(NSString *)identifier size:(CGSize)size data:(id)data;

@end
