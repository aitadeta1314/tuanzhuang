//
//  CompanyCollectionViewCell.h
//  tuanzhuang
//
//  Created by Fenly on 2017/12/4.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
#import "CustomButton.h"

typedef void (^configurationBlockClick)(void);
typedef void (^deleteBlockClick)(void);
typedef void (^syncMethodBlockClick)(void);
typedef void (^uploadMethodBlockClick)(void);
typedef void (^tapOnShadeViewBlock)(void);


@interface CompanyCollectionViewCell : UICollectionViewCell

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

// 遮罩层
@property (weak, nonatomic) IBOutlet UIView *shadeTopView;
// 删除图片imgView
@property (weak, nonatomic) IBOutlet UIImageView *deleteImgView;
// 锁图片
@property (weak, nonatomic) IBOutlet UIImageView *lockImgView;
// 锁的遮罩层
@property (weak, nonatomic) IBOutlet UIView *lockShadeView;

// HomeModel
@property (nonatomic, strong) HomeModel *homeModel;

// cell按钮
/**
 配置按钮
 */
@property (weak, nonatomic) IBOutlet CustomButton *configurationBtn;
/**
 删除按钮
 */
@property (weak, nonatomic) IBOutlet CustomButton *deleteBtn;
/**
 同步按钮
 */
@property (weak, nonatomic) IBOutlet CustomButton *syncBtn;
/**
 上传按钮
 */
@property (weak, nonatomic) IBOutlet CustomButton *uploadBtn;


/**
 *  配置block
 */
@property (nonatomic, copy) configurationBlockClick configurationBlock;
@property (nonatomic, copy) deleteBlockClick deleteBlock;
@property (nonatomic, copy) syncMethodBlockClick syncMethodBlock;
@property (nonatomic, copy) uploadMethodBlockClick uploadMethodBlock;
@property (nonatomic, copy) tapOnShadeViewBlock tapOnShadeViewBlock;

@end
