//
//  PlayerRecommendCell.m
//  Vidol
//
//  Created by XJIMI on 2015/10/4.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import "PlayerRecommendCell.h"

@implementation PlayerRecommendCell

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor whiteColor];
    
    UIView *selectedBgView = [[UIView alloc] init];
    selectedBgView.backgroundColor = [UIColor colorWithWhite:0.9545 alpha:1.0000];
    self.selectedBackgroundView = selectedBgView;
}

- (void)reloadData:(PlayerRecommendModel *)data
{
    self.titleLabel.text = data.title;
    self.subtitleLabel.text = data.subtitle;
    self.titleImageView.image = [UIImage imageNamed:data.imageName];
}

@end
