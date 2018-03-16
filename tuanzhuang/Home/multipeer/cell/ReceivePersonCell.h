//
//  ReceivePersonCell.h
//  tuanzhuang
//
//  Created by Fenly on 2017/12/19.
//  Copyright © 2017年 red. All rights reserved.
//

#import <MGSwipeTableCell/MGSwipeTableCell.h>
#import "ReceiveInfoModel.h"


@interface ReceivePersonCell : MGSwipeTableCell
// 姓名
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
// 性别
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
// 短线
@property (weak, nonatomic) IBOutlet UILabel *stubLb;
// 部门
@property (weak, nonatomic) IBOutlet UILabel *departmentLb;
// 工号
@property (weak, nonatomic) IBOutlet UILabel *numberOfJobLb;
// 状态图片
@property (weak, nonatomic) IBOutlet UIImageView *statusImgView;
// 状态（1进行中、2已完成、0待量体）
@property (weak, nonatomic) IBOutlet UILabel *statusLb;

/**
 *  数据
 */
@property (nonatomic, strong) ReceiveInfoModel *model;
@end
