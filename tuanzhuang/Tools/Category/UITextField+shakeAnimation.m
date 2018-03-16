//
//  UITextField+shakeAnimation.m
//  TextFieldText
//
//  Created by jsj on 16/3/3.
//  Copyright © 2016年 青岛晨之晖信息服务有限公司. All rights reserved.
//

#import "UITextField+shakeAnimation.h"

@implementation UITextField (shakeAnimation)
//输入错误抖动效果
- (void)shakeAnimation

{
    // 获取到当前的View
    
    CALayer *viewLayer = self.layer;
    
    // 获取当前View的位置
    
    CGPoint position = viewLayer.position;
    
    // 移动的两个终点位置
    
    CGPoint x = CGPointMake(position.x + 10, position.y);
    
    CGPoint y = CGPointMake(position.x - 10, position.y);
    
    // 设置动画
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    // 设置运动形式
    
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    
    // 设置开始位置
    
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    
    // 设置结束位置
    
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    
    // 设置自动反转
    
    [animation setAutoreverses:YES];
    
    // 设置时间
    
    [animation setDuration:.06];
    
    // 设置次数
    
    [animation setRepeatCount:8];
    
    // 添加上动画
    
    [viewLayer addAnimation:animation forKey:nil];
    
}

- (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat)borderWidth {
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = color.CGColor;
    layer.frame = CGRectMake(0, 0, self.frame.size.width, borderWidth);
    [self.layer addSublayer:layer];
}

- (void)addLeftBorderWithColor:(UIColor *)color andWidth:(CGFloat)borderWidth {
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = color.CGColor;
    layer.frame = CGRectMake(0, 0, borderWidth, self.frame.size.height);
    [self.layer addSublayer:layer];
}

- (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat)borderWidth {
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = color.CGColor;
    layer.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
    [self.layer addSublayer:layer];
}

- (void)addRightBorderWithColor:(UIColor *)color andWidth:(CGFloat)borderWidth {
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = color.CGColor;
    layer.frame = CGRectMake(self.frame.size.width-borderWidth, 0, borderWidth, self.frame.size.height);
    [self.layer addSublayer:layer];
}

@end
