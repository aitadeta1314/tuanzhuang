//
//  CompanyCollectionViewCell.m
//  tuanzhuang
//
//  Created by Fenly on 2017/12/4.
//  Copyright © 2017年 red. All rights reserved.
//

#import "RecycledCollectionViewCell.h"


@implementation RecycledCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}


- (void)setHomeModel:(HomeModel *)homeModel {
    _homeModel = homeModel;
    self.companyNameLb.text = homeModel.companyModel.missionname; // 显示任务名
    self.createTimeLb.text = [processingTime dateStringWithDate:homeModel.companyModel.addtime andFormatString:@"yyyy-MM-dd"];
    self.numberOfPersonLb.text = homeModel.numberOfPerson;
    self.waitNumLb.text = homeModel.waitNum;
    self.beingNumLb.text = homeModel.beingNum;
    self.doneNumLb.text = homeModel.doneNum;
    self.syncTimesLb.text = [NSString stringWithFormat:@"%d",homeModel.companyModel.tb_frequency];
    self.syncRecentTimeLb.text = [processingTime dateStringWithDate:homeModel.companyModel.tb_lasttime andFormatString:@"yyyy-MM-dd"];
    self.uploadTimesLb.text = [NSString stringWithFormat:@"%d",homeModel.companyModel.upload_frequency];
    self.uploadRecentTimeLb.text = [processingTime dateStringWithDate:homeModel.companyModel.upload_lasttime andFormatString:@"yyyy-MM-dd"];
    // 锁显示
    self.lockImgView.hidden = !homeModel.companyModel.lock_status;
    if (homeModel.companyModel.lock_status) {
        // 锁住
        self.topBgImgView.image = [UIImage imageNamed:@"recyclebin_lock_bg"];
    } else {
        // 未锁住
        self.topBgImgView.image = [UIImage imageNamed:@"recyclebin_normal_bg"];
    }
    
    // 是否选中
    self.selectImgView.hidden = !homeModel.isSelected;
    
    // 删除时间
    self.deleteTime.text = [processingTime dateStringWithDate:homeModel.companyModel.delTime andFormatString:@"yyyy-MM-dd HH:mm:ss"];
}



@end
