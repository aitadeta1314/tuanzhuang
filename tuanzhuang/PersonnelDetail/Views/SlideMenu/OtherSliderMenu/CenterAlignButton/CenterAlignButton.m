//
//  CenterAlignButton.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/9.
//  Copyright © 2018年 red. All rights reserved.
//

#import "CenterAlignButton.h"
#import "UIButton+AlignContent.h"

@implementation CenterAlignButton

-(void)layoutSubviews{
    [super layoutSubviews];
    [self centerImageAndTitle];
}

@end
