//
//  PersonnelModel+SyncData.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/3/6.
//  Copyright © 2018年 red. All rights reserved.
//

#import "PersonnelModel+CoreDataClass.h"

typedef void(^ChangedBlock)(BOOL changed);

@interface PersonnelModel (SyncData)

/**
 * 初始同步更新CY/CD的尺寸数据
 *
 * 在该品类没有尺寸数据的时候，同步关联的品类的尺寸数据
 **/
-(void)referencePositionSizeByAssociateCategory:(CategoryModel *)category;

/**
 * 根据部位尺寸，更新加放量中的对应部位尺寸
 * @param positionName 部位名称
 * @param size         尺寸
 * @param complete      修改触发block
 **/
-(void)referenceAdditionByPositionName:(NSString *)positionName andSize:(NSInteger)size complete:(ChangedBlock)complete;


/**
 * 同步关联的品类的成衣尺寸
 ***/
-(void)syncAssociationCategory:(CategoryModel *)category andPositionSize:(PositionModel *)position;

/**
 * 修改性别，更新部位尺寸的BLCode
 **/
-(void)referenceCategoryPositionsBLCode:(CategoryModel *)category;

/**
 * 修改性别，更新所有的的成衣的部位尺寸的BLCode
 **/
-(void)referenceClothesCategoryPositionsBLCode;

#pragma mark - 配置公司全局设置的品类数量
-(void)setupCompanyCategoryConfigure;

#pragma mark - 修改性别关联修改数据
/**
 * 修改性别修改关联数据
 **/
-(void)referenceAssociateDataBySexChanged;

@end
