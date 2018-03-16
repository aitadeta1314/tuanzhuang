//
//  SearchTableViewCell.h
//  tuanzhuang
//
//  Created by Fenly on 2017/12/7.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeModel;

@interface SearchTableViewCell : UITableViewCell
// 公司名字
@property (weak, nonatomic) IBOutlet UILabel *companyNameLb;
// 人员数量
@property (weak, nonatomic) IBOutlet UILabel *totalNumLb;
// 待量体
@property (weak, nonatomic) IBOutlet UILabel *waitNumLb;
// 进行中
@property (weak, nonatomic) IBOutlet UILabel *beingNumLb;
// 已完成
@property (weak, nonatomic) IBOutlet UILabel *doneNumLb;



-(void)cellWithData:(HomeModel *)model searchKeyWords:(NSString *)keywords;
@end
