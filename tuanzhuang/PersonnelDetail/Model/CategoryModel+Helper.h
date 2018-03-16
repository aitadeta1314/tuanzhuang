//
//  CategoryModel+Helper.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/24.
//  Copyright © 2018年 red. All rights reserved.
//

#import "CategoryModel+CoreDataClass.h"

@interface CategoryModel (Helper)

@property(nonatomic,strong,readonly) NSString *name;

@property(nonatomic,strong,readonly) AdditionModel *summerAddition;
@property(nonatomic,strong,readonly) AdditionModel *winterAddition;

@property(nonatomic,strong,readonly) NSArray        *summerAdditionArray;
@property(nonatomic,strong,readonly) NSArray        *winterAdditionArray;

-(AdditionModel *)getAdditionItemBySeason:(SEASON_TYPE)season;


/**
 * 更改品类的数量时，关联修改品类的冬季与夏季数量
 * 添加品类数量，品类的夏季数量随之增加
 * 删除品类数量，先删除夏季数量，再删除冬季数量
 **/
-(void)associatedSetCategorySeasonCount;

/**
 * 修改品类加放量数量记录
 ***/
-(void)associatedSetCategoryAddtional;



@end
