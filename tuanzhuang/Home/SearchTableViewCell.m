//
//  SearchTableViewCell.m
//  tuanzhuang
//
//  Created by Fenly on 2017/12/7.
//  Copyright © 2017年 red. All rights reserved.
//

#import "SearchTableViewCell.h"
#import "HomeModel.h"

@implementation SearchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)cellWithData:(HomeModel *)model searchKeyWords:(NSString *)keywords {
    _companyNameLb.text = model.companyModel.missionname;
    if (keywords.length>0) {
        NSMutableAttributedString * attributeString = [[NSMutableAttributedString alloc] initWithString:model.companyModel.missionname];
        [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[model.companyModel.missionname rangeOfString:keywords]];
        [self.companyNameLb setAttributedText:attributeString];
    }
    _totalNumLb.text = model.numberOfPerson;
    _waitNumLb.text = model.waitNum;
    _beingNumLb.text = model.beingNum;
    _doneNumLb.text = model.doneNum;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
