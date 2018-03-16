//
//  ClothesSizeInputView.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/8.
//  Copyright © 2018年 red. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPNumberButton.h"

typedef void(^SizeChangedBlock)(NSInteger summerSize,NSInteger winterSize);

@interface ClothesSizeInputView : UIView

@property(nonatomic,assign) NSInteger summerSize;
@property(nonatomic,assign) NSInteger winterSize;

@property(nonatomic,assign) NSInteger minSummerSize;
@property(nonatomic,assign) NSInteger maxSummerSize;

@property(nonatomic,assign) NSInteger minWinterSize;
@property(nonatomic,assign) NSInteger maxWinterSize;

@property(nonatomic,copy) SizeChangedBlock changedBlock;

/**
 * 重置数据
 **/
-(void)reset;

/**
 * 设置数据
 * @param sSize     夏天尺寸
 * @param wSize     冬天尺寸
 * @param beginSize 最小尺寸
 * @param endSize   最大尺寸
 **/
-(void)setSummerSize:(NSInteger)sSize winterSize:(NSInteger)wSize minSize:(NSInteger)beginSize maxSize:(NSInteger)endSize;

@end
