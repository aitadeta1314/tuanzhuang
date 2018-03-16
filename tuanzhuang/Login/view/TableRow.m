//
//  TableRow.m
//  tuanzhuang
//
//  Created by zhuang on 2017/12/19.
//  Copyright © 2017年 red. All rights reserved.
//

#import "TableRow.h"

@interface TableRow()

@end

@implementation TableRow

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    [self layoutView];
    return self;
}

#pragma mark - 懒加载
-(UILabel *)rightText{
    if(!_rightText){
        _rightText = [[UILabel alloc] init];
        _rightText.font = [UIFont systemFontOfSize:14 weight:0];
        _rightText.textColor = RGBColor(153, 153, 153);
        _rightText.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_rightText];
        [_rightText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0).priorityLow();
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(self.mas_right).offset(-paddingW-rightImgW);
        }];
    }
    return _rightText;
}

-(UILabel *)leftText{
    if(!_leftText){
        _leftText = [[UILabel alloc] init];
        _leftText.font = [UIFont systemFontOfSize:16 weight:0];
        _leftText.textColor = RGBColor(51, 51, 51);
        _leftText.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_leftText];
        [_leftText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self).offset(paddingW+leftImgW);
            make.right.equalTo(_rightText.mas_left).priorityLow();
        }];
    }
    return _leftText;
}

-(UIImageView *)leftImgView{
    if(!_leftImgView){
        _leftImgView = [[UIImageView alloc] init];
        [self addSubview:_leftImgView];
        [_leftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(0).priorityLow();
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self).offset(paddingW);
        }];
    }
    return _leftImgView;
}

-(UIButton *)rightBtn{
    if(!_rightBtn){
        _rightBtn = [[UIButton alloc] init];
        [self addSubview:_rightBtn];
        [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(8);
            make.height.mas_equalTo(16);
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(self).offset(-paddingW).priorityLow();
        }];
    }
    return _rightBtn;
}

-(UIView *)topLineView{
    if(!_topLineView){
        _topLineView = [[UIView alloc] init];
        _topLineView.backgroundColor = RGBColor(222, 222, 222);
        [self addSubview:_topLineView];
        [_topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
            make.top.equalTo(self.mas_top);
            make.left.equalTo(self).offset(paddingW).priorityLow();
            make.right.equalTo(self);
        }]; 
    }
    return _topLineView;
}

-(UIView *)bottomLineView{
    if(!_bottomLineView){
        _bottomLineView = [[UIView alloc] init];
        _bottomLineView.backgroundColor = RGBColor(222, 222, 222);
        [self addSubview:_bottomLineView];
        [_bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
            make.bottom.equalTo(self.mas_bottom).offset(0);
            make.left.equalTo(self).offset(paddingW).priorityLow();
            make.right.equalTo(self);
        }];
    }
    return _bottomLineView;
}

#pragma mark - action
-(TableRow *(^)(NSString *,NSString *, NSString *))text{
    weakObjc(self);
    return ^(NSString * img,NSString * lt,NSString * rt){
        if(!!img){
            weakself.leftImgView.image = [UIImage imageNamed:img];
            leftImgW = 60;
            [weakself.leftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.mas_equalTo(40).priorityLow();
            }];
        }
        if(!!lt){
            weakself.leftText.text = lt;
        }
        if(!!rt){
            weakself.rightText.text = rt;
        }
        return self;
    };
}

- (TableRow * (^)(NSString* icon))rightIcon{
    weakObjc(self);
    return ^(NSString* icon){
        [weakself.rightBtn setBackgroundImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
        rightImgW = 40;
        [weakself.rightText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-rightImgW-paddingW);
        }];
        return weakself;
    };
}

- (TableRow * (^)(CGFloat w))topLine{
    weakObjc(self);
    return ^(CGFloat w){
        weakself.topLineView.hidden = NO;
        [weakself.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakself.mas_left).offset(w);
        }];
        return weakself;
    };
}

- (TableRow * (^)(CGFloat w))bottomLine{
    weakObjc(self);
    return ^(CGFloat w){
        weakself.bottomLineView.hidden = NO;
        [weakself.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakself.mas_left).offset(w);
        }];
        return weakself;
    };
}

#pragma mark - self
-(void) layoutView {
    paddingW = 40;
    leftImgW = 0;
    rightImgW = 0;
    //
    self.leftImgView.hidden = NO;
    self.rightText.hidden = NO;
    self.leftText.hidden = NO;
    self.topLineView.hidden = YES;
    self.bottomLineView.hidden = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
