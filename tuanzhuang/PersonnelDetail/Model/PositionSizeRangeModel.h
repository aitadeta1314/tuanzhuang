//
//  PositionSizeRangeModel.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/12.
//  Copyright © 2018年 red. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PositionSizeRangeModel : NSObject

@property(nonatomic,strong) NSString *position;             //量体部位
@property(nonatomic,strong) NSString *man;                  //男士尺寸范围
@property(nonatomic,strong) NSString *woman;                //女士尺寸范围
@property(nonatomic,strong) NSString *required;             //品类必填项
@property(nonatomic,strong) NSString *blcode;               //男士部位编码
@property(nonatomic,strong) NSString *wblcode;              //女士部位编码

@property(nonatomic,assign,readonly) NSInteger manMin;
@property(nonatomic,assign,readonly) NSInteger manMax;

@property(nonatomic,assign,readonly) NSInteger womanMin;
@property(nonatomic,assign,readonly) NSInteger womanMax;

/**
 * 针对净体测量品类，是否为必填项
 */
-(BOOL)isRequiredForBodySizeCategorys:(NSArray <CategoryModel *> *)categorys;


/**
 * 根据部位的名称获取部位的尺寸范围
 **/
+(PositionSizeRangeModel *)getBodyPositionSizeRangeByPositionName:(NSString *)positionName;


#pragma mark - 获取净体尺寸
/**
 * 获取所有净体尺寸范围
 **/
+(NSArray<PositionSizeRangeModel *> *)getBodyPositionSizeRangeArray;

/**
 * 根据性别获取净体尺寸范围
 **/
+(NSArray<PositionSizeRangeModel *> *)getBodyPositionSizeRangeArrayBySex:(BOOL)isMan;

#pragma mark - 获取成衣尺寸

/**
 * 获取指定的成衣品类的尺寸范围
 ***/
+(NSArray<PositionSizeRangeModel *> *)getClothesPositionSizeRangeArray:(NSString *)catecode;

/**
 * 根据性别获取指定的成衣品类的尺寸范围
 ***/
+(NSArray<PositionSizeRangeModel *> *)getClothesPositionSizeRangeArray:(NSString *)catecode bySex:(BOOL)isMan;



@end
