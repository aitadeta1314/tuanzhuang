//
//  UnfinishedCell.m
//  tuanzhuang
//
//  Created by red on 2018/2/27.
//  Copyright © 2018年 red. All rights reserved.
//

#import "UnfinishedCell.h"

@interface UnfinishedCell ()
@property (strong, nonatomic) UILabel * nameLabel;//姓名
@property (nonatomic, strong) UIImageView * remarkIcon;/**<是否有备注的标志*/
@property (nonatomic, strong) UIImageView * signIcon;/**<是否有签名的标志*/
@property (strong, nonatomic) UILabel * genderAndDepartmentLabel;//性别+部门
@property (strong, nonatomic) UIImageView * statusIcon;//测量状态“圆点”
@property (strong, nonatomic) UILabel * statusLabel;//状态
@property (strong, nonatomic) UIImageView * iconImageView;//图标
@property (strong, nonatomic) UILabel * jobnumberLabel;//工号
@property (strong, nonatomic) UIImageView * selectImageView;//选中状态
@property (strong, nonatomic) UIView * bottomLineView;//底部线条
@end

@implementation UnfinishedCell

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

//选中状态
-(UIImageView *)selectImageView
{
    if (_selectImageView == nil) {
        _selectImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_selectImageView];
    }
    return _selectImageView;
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

#pragma mark -
-(void)cellWithData:(UnfinishedModel *)model multSelect:(BOOL)mult;
{
    CGFloat x = 20;
    CGFloat y = 20;
    CGFloat space = 15;
    UIColor * textcolor = model.personModel.ignored ? systemGrayColor : RGBColor(255, 0, 0);
    
    weakObjc(self);
    //姓名label布局
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.contentView).offset(y);
        make.left.mas_equalTo(weakself.contentView).offset(x);
        make.height.mas_equalTo(18);
    }];
    
    NSString *name = model.personModel.name;
    
    if (model.personModel.mtm) {
        name = [NSString stringWithFormat:@"%@-MTM",name];
    }
    
    self.nameLabel.text = name;
    self.nameLabel.textColor = textcolor;
    self.nameLabel.font = [UIFont systemFontOfSize:18];
    
    CGFloat remark_size = 16;
    CGFloat remark_space = 8;
    self.remarkIcon.hidden = model.personModel.remark == NULL;
    [self.remarkIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nameLabel);
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(10);
        make.height.mas_equalTo(remark_size);
        make.width.mas_equalTo(remark_size);
    }];
    
    CGFloat sigh_size = remark_size;
    self.signIcon.hidden = model.personModel.sign == NULL;
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
    self.genderAndDepartmentLabel.text = [NSString stringWithFormat:@"%@  -  %@",model.personModel.gender == PERSON_GENDER_WOMEN? @"女":@"男",model.personModel.department];
    self.genderAndDepartmentLabel.textColor = textcolor;
    self.genderAndDepartmentLabel.font = [UIFont systemFontOfSize:14];
    
    //量体状态label布局
    CGFloat icon_size = 16;
    CGFloat rightspace;
    if (mult) {
        rightspace = 100;
    } else {
        rightspace = 50;
    }
    [self.statusLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.nameLabel);
        make.right.mas_equalTo(weakself.contentView).offset(-rightspace);
        make.height.mas_equalTo(18);
        make.width.mas_equalTo(70);
    }];
    NSString * status = @"";
    NSString * statusiconname = @"";
    switch (model.personModel.status) {
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
    
    //圆点布局
    [self.statusIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(icon_size, icon_size));
        make.right.mas_equalTo(weakself.statusLabel.mas_left).offset(-10);
        make.centerY.mas_equalTo(weakself.statusLabel.mas_centerY);
    }];
    self.statusIcon.image = [UIImage imageNamed:statusiconname];
    
    self.jobnumberLabel.hidden = self.iconImageView.hidden = model.personModel.status == 0;
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
    if (model.personModel.history) {
        self.jobnumberLabel.text = @"历史尺寸";
    } else if (model.personModel.sign != NULL) {
        self.jobnumberLabel.text = @"客人自报";
    } else {
        self.jobnumberLabel.text = model.personModel.lname;
    }
    self.jobnumberLabel.textColor = textcolor;
    
    self.selectImageView.hidden = !mult;
    CGFloat selecticon_size = 20;
    if (model.selected) {
        self.selectImageView.image = [UIImage imageNamed:@"checked"];
    } else {
        self.selectImageView.image = [UIImage imageNamed:@"uncheck"];
    }
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.contentView).offset(32);
        make.right.mas_equalTo(weakself.contentView).offset(-40);
        make.size.mas_equalTo(CGSizeMake(selecticon_size, selecticon_size));
    }];
    
    //底部线条布局
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.contentView).offset(x);
        make.right.mas_equalTo(weakself.contentView).offset(-x);
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
