//
//  SynchronizeData.h
//  tuanzhuang
//
//  Created by red on 2018/1/2.
//  Copyright © 2018年 red. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CompanyModel+CoreDataProperties.h"

@interface SynchronizeData : NSObject

// -- 多点连接 --
+(void)multiCreateFile:(CompanyModel*)companymodel;
+(void)multiUpdateModel;

//生成plist文件
+(NSURL *)createSyncFile:(NSMutableDictionary*)dic;
+(NSURL *)fileUrlWithCompany:(CompanyModel*)companymodel;

//删除plist文件
+(void)deletFile:(NSString *)filename;

/**
 * 处理master分发的数据
 * 将本地“已完成”的数据全部删除
 * 将master分发的数据从文件取出保存
 */
+(void)handleMasterDataWithFileUrl:(NSURL *)url;

/**
 * 合并同步数据
 * 将master、slave的"新建数据"合并
 * 将master、slave的"原始数据"合并、去重
 */
+(NSDictionary *)mergeMasterDic:(NSDictionary *)masterDic andSlaveDic:(NSDictionary *)slaveDic;//合并数据
/**
 * 合并+处理同步数据
 * 将master、slave的“新建数据”合并，并且将重复数据分组
 * 将master、slave的“原始数据”合并并去重
 */
+(NSDictionary *)handleMasterDic:(NSDictionary *)masterDic andSlaveDic:(NSDictionary *)slaveDic;//合并、处理数据

/**
 * 重新处理同步数据
 * 应用场景：处理冲突时，进入详情页修改数据后，要对数据进行重新处理、重新分组(针对修改姓名的情况)
 */
+(NSDictionary *)rehandleSynchronizeDict:(NSDictionary *)dic;

/**
 * 处理重复数组  给字典加repeatlogo字段
 */
+(NSArray *)handleRepeatArray:(NSArray *)array;
/**
 * 处理非重复数组 给字典加repeatlogo字段
 */
+(NSArray *)handleNonrepeatArray:(NSArray *)array;

//将人员信息字典转化为model
+(PersonnelModel *)personnelModelByDic:(NSDictionary *)dic;
//将人员信息model转化为字典
+(NSDictionary *)personnelDicByModel:(PersonnelModel *)pmodel;

@end
