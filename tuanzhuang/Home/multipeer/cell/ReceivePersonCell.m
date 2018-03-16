//
//  ReceivePersonCell.m
//  tuanzhuang
//
//  Created by Fenly on 2017/12/19.
//  Copyright © 2017年 red. All rights reserved.
//

#import "ReceivePersonCell.h"

@implementation ReceivePersonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(ReceiveInfoModel *)model {
    _model = model;
    _nameLabel.text = model.name;
    _genderLabel.text = model.gender;
    _departmentLb.text = model.department;
    _numberOfJobLb.text = model.jobnumber;
    switch (model.dataStatus) {
        case DATAIN_STATUS_WAIT:
            _statusLb.text = @"待量体";
            [_statusImgView setImage:[UIImage imageNamed:@"status_gray"]];
            break;
        case DATAIN_STATUS_DOING:
            _statusLb.text = @"进行中";
            [_statusImgView setImage:[UIImage imageNamed:@"status_yellow"]];
            break;
        case DATAIN_STATUS_DONE:
            _statusLb.text = @"已完成";
            [_statusImgView setImage:[UIImage imageNamed:@"status_green"]];
            break;
        default:
            break;
    }
    
    if (model.dataEditStatus == DATA_EDIT_YES) {
        // 可编辑数据
        switch (model.dataRepeatLogo) {
            case DATA_REPEAT_LOGO_no:
                [self noRepeatDataShow];
                break;
            case DATA_REPEAT_LOGO_ignore:
                [self ignoreDataShow];
                break;
            case DATA_REPEAT_LOGO_repeat:
                [self repeatDataShow];
                break;
            default:
                break;
        }
    }
    else {
        // 不可编辑数据
        [self canotEditDataShow];
    }
    
}

- (void)canotEditDataShow {
    _nameLabel.textColor = systemDarkGrayColor;
    _genderLabel.textColor = systemDarkGrayColor;
    _stubLb.textColor = systemDarkGrayColor;
    _departmentLb.textColor = systemDarkGrayColor;
    _statusLb.textColor = systemDarkGrayColor;
    _numberOfJobLb.textColor = systemDarkGrayColor;
}

/** 无重复数据，不可编辑数据*/
- (void)noRepeatDataShow {
    _nameLabel.textColor = systemBlackColor;
    _genderLabel.textColor = systemBlackColor;
    _stubLb.textColor = systemBlackColor;
    _departmentLb.textColor = systemBlackColor;
    _numberOfJobLb.textColor = systemBlackColor;
    _statusLb.textColor = systemBlackColor;
}

// 重复数据显示红色
- (void)repeatDataShow {
    _nameLabel.textColor = [UIColor redColor];
    _genderLabel.textColor = [UIColor redColor];
    _stubLb.textColor = [UIColor redColor];
    _departmentLb.textColor = [UIColor redColor];
    _numberOfJobLb.textColor = [UIColor redColor];
    _statusLb.textColor = [UIColor redColor];
}

// 忽略数据显示灰色
- (void)ignoreDataShow {
    _nameLabel.textColor = systemGrayColor;
    _genderLabel.textColor = systemGrayColor;
    _stubLb.textColor = systemGrayColor;
    _departmentLb.textColor = systemGrayColor;
    _numberOfJobLb.textColor = systemGrayColor;
    _statusLb.textColor = systemGrayColor;
}

@end
