//
//  personnelCell.m
//  tuanzhuang
//
//  Created by red on 2017/12/4.
//  Copyright © 2017年 red. All rights reserved.
//

#import "personnelCell.h"

@interface personnelCell ()
@property (strong, nonatomic) UILabel * nameLabel;//姓名
@property (nonatomic, strong) UIImageView * remarkIcon;/**<是否有备注的标志*/
@property (nonatomic, strong) UIImageView * signIcon;/**<是否有签名的标志*/
@property (strong, nonatomic) UILabel * genderAndDepartmentLabel;//性别+部门
@property (strong, nonatomic) UIImageView * statusIcon;//测量状态“圆点”
@property (strong, nonatomic) UILabel * statusLabel;//状态
@property (strong, nonatomic) UIImageView * iconImageView;//图标
@property (strong, nonatomic) UILabel * jobnumberLabel;//工号
@property (strong, nonatomic) UIView * bottomLineView;//底部线条
@end

@implementation personnelCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - 懒加载
//姓名
-(UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

-(UIImageView *)remarkIcon
{
    if (_remarkIcon == nil) {
        _remarkIcon = [[UIImageView alloc] init];
        _remarkIcon.image = [UIImage imageNamed:@"comments_remark"];
        [self.contentView addSubview:_remarkIcon];
    }
    return _remarkIcon;
}

-(UIImageView *)signIcon
{
    if (_signIcon == nil) {
        _signIcon = [[UIImageView alloc] init];
        _signIcon.image = [UIImage imageNamed:@"pencil_remark"];
        [self.contentView addSubview:_signIcon];
    }
    return _signIcon;
}

//性别 - 部门
-(UILabel *)genderAndDepartmentLabel
{
    if (_genderAndDepartmentLabel == nil) {
        _genderAndDepartmentLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_genderAndDepartmentLabel];
    }
    return _genderAndDepartmentLabel;
}

//圆点
-(UIImageView *)statusIcon
{
    if (_statusIcon == nil) {
        _statusIcon = [[UIImageView alloc] init];
        [self.contentView addSubview:_statusIcon];
    }
    return _statusIcon;
}

//量体状态
-(UILabel *)statusLabel
{
    if (_statusLabel == nil) {
        _statusLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_statusLabel];
    }
    return _statusLabel;
}

//工号图标
-(UIImageView *)iconImageView
{
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconImageView];
    }
    return _iconImageView;
}

//工号
-(UILabel *)jobnumberLabel
{
    if (_jobnumberLabel == nil) {
        _jobnumberLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_jobnumberLabel];
    }
    return _jobnumberLabel;
}

//底部线
-(UIView *)bottomLineView
{
    if (_bottomLineView == nil) {
        _bottomLineView = [[UIView alloc] init];
        [self.contentView addSubview:_bottomLineView];
    }
    return _bottomLineView;
}

#pragma mark - 数据填充
-(void)cellWithData:(PersonnelModel *)model linehide:(BOOL)hide needoffset:(BOOL)needoffset
{
    CGFloat x = 20;
    CGFloat y = 20;
    CGFloat space = 15;
//    UIColor * textcolor = model.ignored ? systemGrayColor : RGBColor(51, 51, 51);
    UIColor * textcolor = RGBColor(51, 51, 51);
    
    weakObjc(self);
    //姓名label布局
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.contentView).offset(y);
        make.left.mas_equalTo(weakself.contentView).offset(x);
        make.height.mas_equalTo(18);
    }];
    
    NSString *name = model.name;
    
    if (model.mtm) {
        name = [NSString stringWithFormat:@"%@-MTM",name];
    }
    
    self.nameLabel.text = name;
    self.nameLabel.textColor = textcolor;
    self.nameLabel.font = [UIFont systemFontOfSize:18];
    
    CGFloat remark_size = 16;
    CGFloat remark_space = 10;
    self.remarkIcon.hidden = model.remark == NULL;
    [self.remarkIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nameLabel);
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(20);
        make.height.mas_equalTo(remark_size);
        make.width.mas_equalTo(remark_size);
    }];
    
    CGFloat sigh_size = remark_size;
    self.signIcon.hidden = model.sign == NULL;
    [self.signIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nameLabel);
        make.left.mas_equalTo(self.remarkIcon.mas_right).offset(remark_space);
        make.height.mas_equalTo(sigh_size);
        make.width.mas_equalTo(sigh_size);
    }];
    
    //性别-部门label布局
    [self.genderAndDepartmentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.nameLabel.mas_bottom).offset(space);
        make.left.mas_equalTo(weakself.nameLabel);
        make.height.mas_equalTo(14);
    }];
    self.genderAndDepartmentLabel.text = [NSString stringWithFormat:@"%@  -  %@",model.gender == 0? @"女":@"男",model.department];
    self.genderAndDepartmentLabel.textColor = textcolor;
    self.genderAndDepartmentLabel.font = [UIFont systemFontOfSize:14];
    
    //量体状态label布局
    CGFloat icon_size = 16;
    CGFloat rightspace = 50;
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.nameLabel);
        make.right.mas_equalTo(weakself.contentView).offset(-rightspace);
        make.height.mas_equalTo(16);
        make.width.mas_equalTo(50);
    }];
    NSString * status = @"";
    NSString * statusiconname = @"";
    switch (model.status) {
        case 0:
            status = @"待量体";
            statusiconname = @"status_gray";
            break;
        case 1:
            status = @"进行中";
            statusiconname = @"status_yellow";
            break;
        default:
            status = @"已完成";
            statusiconname = @"status_green";
            break;
    }
    self.statusLabel.text = status;
    self.statusLabel.textColor = textcolor;
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    
    //圆点布局
    [self.statusIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(icon_size, icon_size));
        make.right.mas_equalTo(weakself.statusLabel.mas_left).offset(-10);
        make.centerY.mas_equalTo(weakself.statusLabel.mas_centerY);
    }];
    self.statusIcon.image = [UIImage imageNamed:statusiconname];
    
    self.jobnumberLabel.hidden = self.iconImageView.hidden = model.status == 0;
    //工号图标布局
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(icon_size, icon_size));
        make.right.mas_equalTo(weakself.jobnumberLabel.mas_left).offset(-10);
        make.centerY.mas_equalTo(weakself.jobnumberLabel.mas_centerY);
    }];
    self.iconImageView.image = [UIImage imageNamed:@"user_logo"];
    
    //工号label布局
    [self.jobnumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.statusLabel.mas_bottom).offset(space);
        make.right.mas_equalTo(weakself.statusLabel);
        make.width.mas_equalTo(weakself.statusLabel);
        make.height.mas_equalTo(weakself.statusLabel);
    }];
    self.jobnumberLabel.text = model.lname;
    self.jobnumberLabel.textColor = textcolor;
    self.jobnumberLabel.font = [UIFont systemFontOfSize:14];
    
    //底部线条布局
    self.bottomLineView.hidden = hide;
    CGFloat right_offset = needoffset ? -x : 0;
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.contentView).offset(x);
        make.right.mas_equalTo(weakself.contentView).offset(right_offset);
        make.bottom.mas_equalTo(weakself.contentView);
        make.height.mas_equalTo(1);
    }];
    self.bottomLineView.backgroundColor = RGBColor(204, 204, 204);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
