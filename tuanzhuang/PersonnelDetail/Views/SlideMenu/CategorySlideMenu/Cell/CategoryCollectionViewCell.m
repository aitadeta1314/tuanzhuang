//
//  CategoryCollectionViewCell.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/22.
//  Copyright © 2017年 red. All rights reserved.
//

#import "CategoryCollectionViewCell.h"
#import "PPNumberButton.h"

@interface CategoryCollectionViewCell()<UITextFieldDelegate,PPNumberButtonDelegate>{
    NSInteger _oldCount;
}

@property(nonatomic,strong) PPNumberButton *numberButton;
@property(nonatomic,strong) UILabel *titleLabel;
@end

@implementation CategoryCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self addCustomSubviews];
    }
    
    return self;
    
}

-(void)addCustomSubviews{
    [self.contentView addSubview:self.numberButton];
    [self.contentView addSubview:self.titleLabel];
    
    [self.numberButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 40));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.numberButton.mas_right).with.offset(10);
    }];
}

#pragma mark - Property Setting Methods
-(void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = title;
}

-(void)setCount:(NSInteger)count{
    self.numberButton.currentNumber = count;
    _oldCount = count;
}



#pragma mark - Property Getting Methods
-(PPNumberButton *)numberButton{
    if (!_numberButton) {
        _numberButton = [[PPNumberButton alloc] init];
        _numberButton.borderColor = [UIColor lightGrayColor];
        _numberButton.increaseTitle = @"+";
        _numberButton.decreaseTitle = @"-";
        _numberButton.minValue = 0;
        _numberButton.delegate = self;
        _numberButton.longPressSpaceTime = CGFLOAT_MAX;
    }
    
    return _numberButton;
}

-(UILabel *)titleLabel{
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:18.0];
        _titleLabel.textColor = [UIColor blackColor];
    }
    
    return _titleLabel;
}

-(NSInteger)count{
    return self.numberButton.currentNumber;
}


#pragma mark - PPNumber Delegate Methods
- (void)pp_numberButton:(PPNumberButton *)numberButton number:(NSInteger)number increaseStatus:(BOOL)increaseStatus{
    if (self.changedBlock && numberButton == self.numberButton) {
        self.changedBlock(number, self.titleLabel);
    }
}

@end
