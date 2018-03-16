//
//  UserCell.m
//  tuanzhuang
//
//  Created by zhuang on 2017/12/14.
//  Copyright © 2017年 red. All rights reserved.
//

#import "UserCell.h"

#define ROW_H 80

@interface UserCell()
@property (nonatomic, strong) UIView * boxView;/***/
@property (strong, nonatomic) UIImageView *userIcon;
@property (strong, nonatomic) UILabel *userName;
@property (strong, nonatomic) UIImageView *selectIcon;


@end

@implementation UserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self boxView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(UIView *)boxView{
    if(!_boxView){
        _boxView  = [self createRow];
        [self addSubview:_boxView];
        weakObjc(self);
        [_boxView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.equalTo(weakself);
        }];
        [_boxView addSubview:self.userIcon];
        [_boxView addSubview:self.selectIcon];
        [_boxView addSubview:self.userName];
    }
    return _boxView;
}

-(UIImageView *)userIcon{
    if(!_userIcon){
        _userIcon = [[UIImageView alloc] init];
        [_boxView addSubview:_userIcon];
        [_userIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.mas_equalTo(40);
            make.left.equalTo(self.boxView).with.offset(20);
            make.centerY.equalTo(self.boxView.mas_centerY);
        }];
    }
    return _userIcon;
}

-(UILabel *)userName{
    if(!_userName){
        _userName = [[UILabel alloc] init];
        _userName.font = [UIFont systemFontOfSize:24 weight:0];
        _userName.textColor = RGBColor(51, 51, 51);
        [_boxView addSubview:_userName];
        [_userName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(20);
            make.left.equalTo(self.boxView.mas_left).with.offset(80);
            make.right.equalTo(self.boxView.mas_right).with.offset(-80);
            make.centerY.equalTo(self.boxView.mas_centerY);
        }];
    }
    return _userName;
}

-(UIImageView *)selectIcon{
    if(!_selectIcon){
        _selectIcon = [[UIImageView alloc] init];
        [_boxView addSubview:_selectIcon];
        [_selectIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.mas_equalTo(30);
            make.right.equalTo(self).with.offset(-20);
            make.centerY.equalTo(self.boxView.mas_centerY);
        }];
    }
    return _selectIcon;
}

-(UIView*)createRow{
    UIView* row = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, ROW_H)];
    row.backgroundColor = RGBColor(255, 255, 255);
    //
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = RGBColor(152, 152, 152);
    [row addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(row.mas_width);
        make.height.mas_equalTo(1);
    }];
    //
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = RGBColor(152, 152, 152);
    [row addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(row.mas_width);
        make.height.mas_equalTo(1);
    }];
    return row;
}

//
-(void)loadData:(NSMutableDictionary*)user{
    self.userIcon.image = [UIImage imageNamed:@"user_logo"];
    self.userName.text = [user objectForKey:@"name"];
    int sel = (int)[user objectForKey:@"selected"];
    if(sel){
        self.selectIcon.image = [UIImage imageNamed:@"finish_130"];
    }else{
        self.selectIcon.image = nil;
    }
}

@end
