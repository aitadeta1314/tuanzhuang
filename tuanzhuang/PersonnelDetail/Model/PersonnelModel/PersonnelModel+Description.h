//
//  PersonnelModel+Description.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/3/6.
//  Copyright © 2018年 red. All rights reserved.
//

#import "PersonnelModel+CoreDataClass.h"

@interface PersonnelModel (Description)

/**
 * 获取品类配置描述
 ***/
-(NSString *)getCategoryConfigDescription;

/**
 * 获取不同量体方式的品类配置描述
 **/
-(NSString *)getCategoryConfigDescription_BySizeType;

@end
