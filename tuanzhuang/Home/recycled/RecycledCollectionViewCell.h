//
//  CompanyCollectionViewCell.h
//  tuanzhuang
//
//  Created by Fenly on 2017/12/4.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface RecycledCollectionViewCell : UICollectionViewCell

// 显示内容的view
@property (weak, nonatomic) IBOutlet UIView *showView;

// 公司名字
@property (weak, nonatomic) IBOutlet UILabel *companyNameLb;
// 创建时间
@property (weak, nonatomic) IBOutlet UILabel *createTimeLb;
// 人员数量
@property (weak, nonatomic) IBOutlet UILabel *numberOfPersonLb;
// 待量体数量
@property (weak, nonatomic) IBOutlet UILabel *waitNumLb;
// 进行中数量
@property (weak, nonatomic) IBOutlet UILabel *beingNumLb;
// 已完成数量
@property (weak, nonatomic) IBOutlet UILabel *doneNumLb;
// 同步次数
@property (weak, nonatomic) IBOutlet UILabel *syncTimesLb;
// 最近同步时间
@property (weak, nonatomic) IBOutlet UILabel *syncRecentTimeLb;
// 上传次数
@property (weak, nonatomic) IBOutlet UILabel *uploadTimesLb;
// 最近上传时间
@property (weak, nonatomic) IBOutlet UILabel *uploadRecentTimeLb;
/**
 cell顶部的背景view（遮罩）
 */
@property (weak, nonatomic) IBOutlet UIImageView *topBgImgView;
/**
 右上角选择imgview
 */
@property (weak, nonatomic) IBOutlet UIImageView *selectImgView;
/**
 锁imgView
 */
@property (weak, nonatomic) IBOutlet UIImageView *lockImgView;

// 删除时间
@property (weak, nonatomic) IBOutlet UILabel *deleteTime;


// HomeModel
@property (nonatomic, strong) HomeModel *homeModel;

@end
