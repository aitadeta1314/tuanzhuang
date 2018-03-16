//
//  CommonData.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/22.
//  Copyright © 2018年 red. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PersonnelModel+CoreDataClass.h"

@interface CommonData : NSObject

/**
 * 待复制的person
 **/
@property(nonatomic,strong) PersonnelModel *personModelForCoping;

/**
 * 添加用户到拷贝他人的列表中
 **/
-(void)addPersonToCopiedOther:(PersonnelModel *)person;

/**
 * 判断用户是否在拷贝他人的列表中
 */
-(BOOL)copiedOtherContainPerson:(PersonnelModel *)person;

/**
 * 清除公司公共数据
 **/
-(void)clearDataByCompanyId:(NSString *)companyId;

+(instancetype)shareCommonData;

@end
