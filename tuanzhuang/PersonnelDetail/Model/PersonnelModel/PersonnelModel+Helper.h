//
//  PersonnelModel+Helper.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/16.
//  Copyright © 2018年 red. All rights reserved.
//

#import "PersonnelModel+CoreDataClass.h"
#import "PersonnelModel+CategoriesHelper.h"
#import "PersonnelModel+SyncData.h"
#import "PersonnelModel+Description.h"


FOUNDATION_EXPORT NSString * const ERROR_DESCRIPTION_KEY;
FOUNDATION_EXPORT NSString * const ERROR_POSITION_BLCODE_KEY;
FOUNDATION_EXPORT NSString * const ERROR_POSITION_NAME_KEY;
FOUNDATION_EXPORT NSString * const ERROR_CATEGORY_NAME_KEY;
FOUNDATION_EXPORT NSString * const ERROR_CATEGORY_CODE_KEY;

FOUNDATION_EXPORT NSString * const KEY_PERSON_USERINFO_NOTIFICATION;

FOUNDATION_EXPORT NSString * const KEY_ENTITY_USERINFO_NOTIFICATION;

@interface PersonnelModel (Helper)

/**
 * 存在短袖长
 **/
-(BOOL)hasShortSleeveSize;

/**
 * 设置包含短袖长标志
 */
-(void)setHasShortSleeveFlag;

/**
 * 设置量体中状态
 **/
-(void)setPersonSatus_Progressing;

/**
 * 设置修改时间为当前时间
 */
-(void)setEditTimeIsNow;

/**
 * 拷贝其他用户的量体与品类数据
 **/
-(void)copyPersonSizeDataFrom:(PersonnelModel *)otherPerson;

/**
 * 检测是否为重复用户数据
 * 用户名、性别、部门 一致，为重复用户数据
 ***/
-(BOOL)validateRepeatPerson:(NSError **)error;

/**
 * 验证基本的数据
 */
-(BOOL)validatePerson:(NSError **)error;

/**
 * 验证净体数据
 **/
-(BOOL)validateBodySizeData:(NSError **)error;

/**
 * 验证成衣数据
 **/
-(BOOL)validateClothesSizeData:(NSError **)error;


/**
 * 根据部位名称，获取部位的净体量体尺寸
 **/
-(NSInteger)getBodyPositionSizeByName:(NSString *)positionName;

/**
 * 根据部位的编号，获取部位的净体尺寸
 **/
-(NSInteger)getBodyPositionSizeByCode:(NSString *)blcode;

/**
 * 根据部位的编码，获取成衣的品类测量尺寸
 **/
-(PositionModel *)getPositionByCode:(NSString *)blcode atCategory:(CategoryModel *)category;

@end
