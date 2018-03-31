//
//  CompanyCollectionViewCell.m
//  tuanzhuang
//
//  Created by Fenly on 2017/12/4.
//  Copyright © 2017年 red. All rights reserved.
//

#import "CompanyCollectionViewCell.h"


@implementation CompanyCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    // 给遮罩层添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnShadeView)];
    [self.shadeTopView addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tapOnLock = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnShadeView)];
    [self.lockShadeView addGestureRecognizer:tapOnLock];
}



// 点击遮罩层
- (void)tapOnShadeView {
    if (self.tapOnShadeViewBlock) {
        self.tapOnShadeViewBlock();
    }
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
    self.syncRecentTimeLb.text = [processingTime dateStringWithDate:homeModel.companyModel.tb_lasttime andFormatString:@"yyyy-MM-dd HH:mm"];
    self.uploadTimesLb.text = [NSString stringWithFormat:@"%d",homeModel.companyModel.upload_frequency];
    self.uploadRecentTimeLb.text = [processingTime dateStringWithDate:homeModel.companyModel.upload_lasttime andFormatString:@"yyyy-MM-dd HH:mm"];
    if (homeModel.isSelected) {
        // 长按选中
        [self.deleteImgView setImage:[UIImage imageNamed:@"selected"]];
    }
    else {
        [self.deleteImgView setImage:[UIImage imageNamed:@"unselected"]];
    }
    
    if (homeModel.companyModel.lock_status) {
        // 锁住了
        [self.configurationBtn setImage:[UIImage imageNamed:@"set_d"] forState:UIControlStateNormal];
        [self.syncBtn setImage:[UIImage imageNamed:@"tb_42_d"] forState:UIControlStateNormal];
        [self.uploadBtn setImage:[UIImage imageNamed:@"upload_d"] forState:UIControlStateNormal];
    } else {
        // 未锁住
        [self.configurationBtn setImage:[UIImage imageNamed:@"set_a"] forState:UIControlStateNormal];
        [self.syncBtn setImage:[UIImage imageNamed:@"tb_42_a"] forState:UIControlStateNormal];
        [self.uploadBtn setImage:[UIImage imageNamed:@"upload_a"] forState:UIControlStateNormal];
    }
    // 选择imgView跟遮罩层显示跟隐藏
    self.shadeTopView.hidden = homeModel.hiddenShade;
    self.deleteImgView.hidden = homeModel.hiddenShade;

    // 锁imgView跟遮罩层显示跟隐藏
    self.lockImgView.hidden = !homeModel.companyModel.lock_status;
    self.lockShadeView.hidden = !homeModel.companyModel.lock_status;
    
}

/**
 配置按钮点击

 @param sender 配置按钮
 */
- (IBAction)configurationBtnClick:(UIButton *)sender {
    if (!self.homeModel.companyModel.lock_status) {
        
        if (self.configurationBlock) {
            self.configurationBlock();
        }
    }
}


/**
 删除按钮点击

 @param sender 删除按钮
 */
- (IBAction)deleteBtnClick:(UIButton *)sender {
    if (self.deleteBlock) {
        self.deleteBlock();
    }
}


/**
 同步按钮点击

 @param sender 同步按钮
 */
- (IBAction)syncBtnClick:(UIButton *)sender {
    if (!self.homeModel.companyModel.lock_status) {
        
        if (self.syncMethodBlock) {
            self.syncMethodBlock();
        }
    }
}

/**
 上传按钮点击

 @param sender 上传按钮
 */
- (IBAction)uploadBtnClick:(UIButton *)sender {
    if (!self.homeModel.companyModel.lock_status) {
        
        if (self.uploadMethodBlock) {
            self.uploadMethodBlock();
        }
    }
}



@end
