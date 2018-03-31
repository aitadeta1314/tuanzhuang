//
//  AdditionModel+Helper.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/23.
//  Copyright © 2018年 red. All rights reserved.
//

#import "AdditionModel+CoreDataClass.h"

@interface AdditionModel (Helper)

@property(nonatomic,assign,readonly) BOOL hasClothesLong;
@property(nonatomic,assign,readonly) BOOL hasSleeveLong;
@property(nonatomic,assign,readonly) BOOL hasPleatOption;
@property(nonatomic,assign,readonly) BOOL hasShoulderWidth;
@property(nonatomic,assign,readonly) BOOL hasWaist;
@property(nonatomic,assign,readonly) BOOL hasPantsLong;
@property(nonatomic,assign,readonly) BOOL hasSkirtLong;

/**
 * 判断是否可修改该属性
 **/
-(BOOL)shouldChangedValueBykey:(NSString *)key;

/**
 * 重置数据
 **/
-(void)reset;

/**
 * 褶皱变更重置默认加放量
 */
-(void)resetIncreaseByPleatOption;

/**
 * 获取量体部位关联字典
 **/
+(NSDictionary *)positionAssociateDic;

/**
 * 验证量体部位在指定品类下，是否可同步更新对应的属性
 **/
+(BOOL)validateSyncPositioin:(NSString *)positionName inCategory:(NSString *)categoryCode;

@end
