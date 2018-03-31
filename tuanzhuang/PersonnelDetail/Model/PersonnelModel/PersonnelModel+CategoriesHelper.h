//
//  PersonnelModel+CategoriesHelper.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/22.
//  Copyright © 2018年 red. All rights reserved.
//

#import "PersonnelModel+CoreDataClass.h"

typedef NS_ENUM(NSUInteger, CategorySizeType) {
    CategorySizeType_Body = 0,          //净体量体
    CategorySizeType_Clothes = 1        //成衣量体
};

@interface PersonnelModel (CategoriesHelper)

/**
 * 是否可配置该品类
 **/
-(BOOL)canConfigCategory:(NSString *)categoryCode;

/**
 * 获取指定量体方式的品类
 */
-(NSArray *)getCategorySizeType:(CategorySizeType)type;

/**
 * 设置品类的量体方式
 **/
-(void)setCategorySizeType:(CategorySizeType)type byCategoryCode:(NSString *)code;

/**
 * 设置品类的数量
 */
-(void)setCategoryCount:(NSInteger)count byCategoryCode:(NSString *)code;

/**
 * 根据品类类型，获取品类列表
 */
-(NSArray *)getCategoryArrayByCode:(NSString *)categoryCode;

/**
 * 根据品类，获取相关品类列表
 **/
-(NSArray *)getAssociatedCategoryCodeArray:(NSString *)categoryCode;

#pragma mark - 品类配置操作
/**
 * 设置配置里面的品类数量
 **/
-(void)setConfigCategoryCount:(NSInteger)count byCategoryCode:(NSString *)categoryCode;

/**
 * 获取品类配置里面的品类数量
 */
-(NSInteger)getConfigCategoryCount:(NSString *)categoryCode;


#pragma mark - Class Method For Category Config Convert Methods

/**
 * 品类配置字符串转换为Dictionary类型
 * @param str : 品类配置字符串
 * return : {T:1,A:2,B:3}格式
 **/
+(NSDictionary *)convertDicByCategoryConfigStr:(NSString *)str;

/**
 * 品类配置Dictionary转换为字符串
 * @param dic : 品类配置
 * return : "1-T,2-A,3-B"
 **/
+(NSString *)convertStrByCategoryConfigDic:(NSDictionary *)dic;

@end
