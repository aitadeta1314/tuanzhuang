//
//  Cell.h
//  tuanzhuang
//
//  Created by zhuang on 2017/12/8.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZCircleProgress.h"

@interface UploadCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *leftImg;
@property (weak, nonatomic) IBOutlet UIImageView *rightImg;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
//
@property (strong, nonatomic) UIActivityIndicatorView *loadingImg;
@property (strong, nonatomic) UIView *lineView;
@property (strong, nonatomic) ZZCircleProgress *progressView;

-(void)loadData:(CGFloat)i;

@end
