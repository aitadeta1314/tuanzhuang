//
//  UserListCell.m
//  tuanzhuang
//
//  Created by zhuang on 2017/12/19.
//  Copyright © 2017年 red. All rights reserved.
//

#import "UserListCell.h"

@interface UserListCell()

@property (nonatomic, strong) NSDictionary * info;/** 用户信息 */
@property (nonatomic, strong) UILabel* userName;/** 工号 */
@property (nonatomic, strong) UIButton * delIcon;/** 删除 */
@property (nonatomic, strong) UIView* topLine;/** 分割线 */

@end

@implementation UserListCell

//- (void)awakeFromNib {
//    [super awakeFromNib];
//    [self layoutView];
//}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [self layoutView];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - 懒加载
-(UILabel *)userName{
    if(!_userName){
        _userName = [[UILabel alloc] init];
        _userName.textColor = RGBColor(151, 151, 151);
        _userName.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_userName];
        [_userName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.frame.size.width - 100);
            make.height.mas_equalTo(40);
            make.left.equalTo(self).offset(50);
        }];
    }
    return _userName;
}

-(UIButton *)delIcon{
    if(!_delIcon){
        UIButton* _delIcon = [[UIButton alloc] init];
        [_delIcon setImage:[UIImage imageNamed:@"delete_icon1"] forState:UIControlStateNormal];
        [self addSubview:_delIcon];
        [_delIcon setUserInteractionEnabled:YES];
        [_delIcon addTarget:self action:@selector(delAction) forControlEvents:UIControlEventTouchDown];
        [_delIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(20);
            make.right.equalTo(self.mas_right).offset(-20);
            make.top.equalTo(self).offset(10);
        }];
    }
    return _delIcon;
}

-(UIView *)topLine{
    if(!_topLine){
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = RGBColor(238, 238, 238);
        [self addSubview:_topLine];
        [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.frame.size.width - 40);
            make.height.mas_equalTo(1);
            make.left.equalTo(self).offset(20);
            make.top.equalTo(self.mas_top).offset(1);
        }];
    }
    return _topLine;
}

#pragma mark - action
-(void)loadData:(NSDictionary *)user{
    self.info = user;
    self.userName.text = [user objectForKey:@"uname"];
}

-(void) delAction {
    if(self.delUserAction){
        self.delUserAction(self.info);
    }
}

#pragma mark - view
-(void) layoutView {
    self.userName.hidden = NO;
    self.delIcon.hidden = NO;
    self.topLine.hidden = NO;
}


#pragma mark - self
@end
