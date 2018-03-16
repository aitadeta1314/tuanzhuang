//
//  UITextField+shakeAnimation.h
//  TextFieldText
//
//  Created by jsj on 16/3/3.
//  Copyright © 2016年 青岛晨之晖信息服务有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (shakeAnimation)
- (void)shakeAnimation;/**< 输入框抖动效果*/

/*
 给textfield添加某一边框
 */
-(void)addBottomBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;
-(void)addLeftBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;
-(void)addRightBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;
-(void)addTopBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;
@end
