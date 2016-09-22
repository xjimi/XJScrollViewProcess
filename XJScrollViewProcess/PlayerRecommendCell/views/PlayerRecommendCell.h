//
//  PlayerRecommendCell.h
//  Vidol
//
//  Created by XJIMI on 2015/10/4.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import "XJTableViewCell.h"
#import "PlayerRecommendModel.h"

@interface PlayerRecommendCell : XJTableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *titleImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtitleLabel;

@end
