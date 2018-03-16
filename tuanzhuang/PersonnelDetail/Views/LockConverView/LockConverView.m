//
//  LockConverView.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/2/28.
//  Copyright © 2018年 red. All rights reserved.
//

#import "LockConverView.h"

@implementation LockConverView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:button];
        
        [button setBackgroundColor:RGBColor(22, 155, 213)];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:@"编辑" forState:UIControlStateNormal];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(140, 40));
            make.center.mas_equalTo(self);
        }];
        
        button.layer.cornerRadius = 5.0;
        button.layer.masksToBounds = YES;
        
        [button addTarget:self action:@selector(unLockButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)unLockButtonAction:(id)sender{
    
    if (self.unLockBlock) {
        self.unLockBlock();
    }
    
}

@end
