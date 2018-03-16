//
//  LabelCollectionViewCell.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/11.
//  Copyright © 2018年 red. All rights reserved.
//

#import "LabelCollectionViewCell.h"


@interface LabelCollectionViewCell()
@end

@implementation LabelCollectionViewCell

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self layoutLabel];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self layoutLabel];
    }
    
    return self;
}

-(void)layoutLabel{
    
    self.titleLabel = [[UILabel alloc] init];
    
    [self.contentView addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

-(void)setStyle:(LabelCollectionViewCellStyle)style{
    
    _style = style;
    
    if (self.labelBySelectedBlock) {
        self.labelBySelectedBlock(style, self.titleLabel);
    }
    
}


@end
