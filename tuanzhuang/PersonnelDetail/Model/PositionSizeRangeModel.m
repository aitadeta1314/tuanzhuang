//
//  PositionSizeRangeModel.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/12.
//  Copyright © 2018年 red. All rights reserved.
//

#import "PositionSizeRangeModel.h"

static NSString * const KEY_BODY_SIZE = @"body";
static NSString * const KEY_BODY_SIZE_MTM = @"body_mtm";
static NSString * const KEY_CLOTHES_SIZE = @"clothes";
static NSString * const KEY_CLOTHES_SIZE_MTM = @"clothes_mtm";

@implementation PositionSizeRangeModel


#pragma mark - Getter Methods

-(NSString *)wblcode{
    if (!_wblcode || [_wblcode isEqualToString:@""]) {
        return _blcode;
    }
    
    return _wblcode;
}

-(NSInteger)manMin{
    return [self getNumberIn:self.man atIndex:0];
}

-(NSInteger)manMax{
    return [self getNumberIn:self.man atIndex:1];
}

-(NSInteger)womanMin{
    return [self getNumberIn:self.woman atIndex:0];
}

-(NSInteger)womanMax{
    return [self getNumberIn:self.woman atIndex:1];
}

-(NSInteger)getNumberIn:(NSString *)range atIndex:(NSInteger)index{
    
    NSArray *rangeArray = [range componentsSeparatedByString:@"-"];
    
    NSInteger number = 0;
    
    if (index < [rangeArray count]) {
        number = [rangeArray[index] integerValue];
    }
    
    return number;
}

/**
 * 根据性别获取最大值与最小值
 **/
-(void)getRangeMin:(NSInteger *)min andRangeMax:(NSInteger *)max byIsMan:(BOOL)isMan{
    if (isMan) {
        *min = self.manMin;
        *max = self.manMax;
    }else{
        *min = self.womanMin;
        *max = self.womanMax;
    }
}

#pragma mark - Public Methods
/**
 * 针对净体测量品类，是否为必填项
 */
-(BOOL)isRequiredForBodySizeCategorys:(NSArray <CategoryModel *> *)categorys{
    BOOL isrequired = NO;
    
    NSArray *codeArray = [self.required componentsSeparatedByString:@","];
    
    if ([codeArray count] > 0 && [categorys count] > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cate in %@",codeArray];
        
        NSArray *requiredCateArray = [categorys filteredArrayUsingPredicate:predicate];
        
        if ([requiredCateArray count]) {
            isrequired = YES;
        }
    }
    
    return isrequired;
}

#pragma mark - Class Methods
/**
 * 获取所有净体尺寸范围
 **/
+(NSArray<PositionSizeRangeModel *> *)getBodyPositionSizeRangeArrayMTM:(BOOL)mtm{
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:BASIC_DATA_PLIST_FILE_PATH];
    
    NSArray *sizeRangeArray;
    
    if (mtm) {
        sizeRangeArray = [dictionary objectForKey:KEY_BODY_SIZE_MTM];
    }else{
        sizeRangeArray = [dictionary objectForKey:KEY_BODY_SIZE];
    }
    
    NSArray *modelArray = [PositionSizeRangeModel mj_objectArrayWithKeyValuesArray:sizeRangeArray];
    
    return modelArray;
}

/**
 * 获取指定的成衣品类的尺寸范围
 ***/
+(NSArray<PositionSizeRangeModel *> *)getClothesPositionSizeRangeArray:(NSString *)catecode andMTM:(BOOL)mtm{
    
    NSArray *modelArray;
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:BASIC_DATA_PLIST_FILE_PATH];
    
    if (mtm) {
        dictionary = [dictionary objectForKey:KEY_CLOTHES_SIZE_MTM];
    }else{
        dictionary = [dictionary objectForKey:KEY_CLOTHES_SIZE];
    }
    
    BOOL isExist = [dictionary.allKeys containsObject:[catecode uppercaseString]];
    
    if (isExist) {
        NSArray *sizeRangeArray = [dictionary objectForKey:[catecode uppercaseString]];
        
        modelArray = [PositionSizeRangeModel mj_objectArrayWithKeyValuesArray:sizeRangeArray];
    }
    
    return modelArray;
}

+(NSArray<PositionSizeRangeModel *> *)getClothesPositionSizeRangeArray:(NSString *)catecode bySex:(BOOL)isMan andMTM:(BOOL)mtm{
    
    NSString *predicateFromatStr;
    if (isMan) {
        predicateFromatStr  = [NSString stringWithFormat:@"man CONTAINS '-'"];
    }else{
        predicateFromatStr = [NSString stringWithFormat:@"woman CONTAINS '-'"];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFromatStr];
    
    NSArray *array = [[self getClothesPositionSizeRangeArray:catecode andMTM:mtm] filteredArrayUsingPredicate:predicate];
    
    return array;
}


+(NSArray<PositionSizeRangeModel *> *)getBodyPositionSizeRangeArrayBySex:(BOOL)isMan andMTM:(BOOL)mtm{
    
    NSString *predicateFromatStr;
    if (isMan) {
        predicateFromatStr  = [NSString stringWithFormat:@"man CONTAINS '-'"];
    }else{
        predicateFromatStr = [NSString stringWithFormat:@"woman CONTAINS '-'"];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFromatStr];
    
    NSArray *array = [[self getBodyPositionSizeRangeArrayMTM:mtm] filteredArrayUsingPredicate:predicate];
    
    return array;
}

/**
 * 获取指定部位的尺寸范围
 **/
+(PositionSizeRangeModel *)getBodyPositionSizeRangeByName:(NSString *)positionName andSex:(BOOL)isMan andMTM:(BOOL)mtm{
    
    NSArray *rangeArray  = [self getBodyPositionSizeRangeArrayBySex:isMan andMTM:mtm];
    
    PositionSizeRangeModel *positionRangeModel;
    
    for (PositionSizeRangeModel *rangeModel in rangeArray) {
        if ([rangeModel.position isEqualToString:positionName]) {
            positionRangeModel = rangeModel;
            break;
        }
    }
    
    return positionRangeModel;
}

/**
 * 根据部位的名称获取部位的尺寸范围
 **/
+(PositionSizeRangeModel *)getBodyPositionSizeRangeByPositionName:(NSString *)positionName andMTM:(BOOL)mtm{
    
    NSArray *array = [self getBodyPositionSizeRangeArrayMTM:mtm];
    
    PositionSizeRangeModel *rangeModel;
    
    for (PositionSizeRangeModel *itemModel in array) {
        if ([itemModel.position isEqualToString:positionName]) {
            rangeModel = itemModel;
            break;
        }
    }
    
    return rangeModel;
    
}

/**
 * 根据BLCode获取成衣品类的尺寸范围
 **/
+(PositionSizeRangeModel *)getClothesPositionSizeRange:(NSString *)catecode byBLCode:(NSString *)blcode andMTM:(BOOL)mtm{
    
    NSArray *rangeArray = [self getClothesPositionSizeRangeArray:catecode andMTM:mtm];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"blcode == %@ || wblcode == %@",blcode,blcode];
    
    rangeArray = [rangeArray filteredArrayUsingPredicate:predicate];
    
    PositionSizeRangeModel *sizeRangeModel;
    
    if ([rangeArray count] > 0) {
        sizeRangeModel = (PositionSizeRangeModel *)[rangeArray objectAtIndex:0];
    }else{
        rangeArray = [self getClothesPositionSizeRangeArray:catecode andMTM:!mtm];
        rangeArray = [rangeArray filteredArrayUsingPredicate:predicate];
        
        if ([rangeArray count] > 0) {
            sizeRangeModel = (PositionSizeRangeModel *)[rangeArray objectAtIndex:0];
        }
    }
    
    return sizeRangeModel;
    
}

@end
