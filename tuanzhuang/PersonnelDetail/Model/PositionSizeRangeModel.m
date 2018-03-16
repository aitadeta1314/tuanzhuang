//
//  PositionSizeRangeModel.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/12.
//  Copyright © 2018年 red. All rights reserved.
//

#import "PositionSizeRangeModel.h"

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
+(NSArray<PositionSizeRangeModel *> *)getBodyPositionSizeRangeArray{
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:BASIC_DATA_PLIST_FILE_PATH];
    
    NSArray *sizeRangeArray = [dictionary objectForKey:@"netbody"];
    
    NSArray *modelArray = [PositionSizeRangeModel mj_objectArrayWithKeyValuesArray:sizeRangeArray];
    
    return modelArray;
}

/**
 * 获取指定的成衣品类的尺寸范围
 ***/
+(NSArray<PositionSizeRangeModel *> *)getClothesPositionSizeRangeArray:(NSString *)catecode{
    
    NSArray *modelArray;
    
    NSDictionary *dictionary = [[NSDictionary dictionaryWithContentsOfFile:BASIC_DATA_PLIST_FILE_PATH] objectForKey:@"clothes"];
    
    BOOL isExist = [dictionary.allKeys containsObject:[catecode uppercaseString]];
    
    if (isExist) {
        NSArray *sizeRangeArray = [dictionary objectForKey:[catecode uppercaseString]];
        
        modelArray = [PositionSizeRangeModel mj_objectArrayWithKeyValuesArray:sizeRangeArray];
    }
    
    return modelArray;
}

+(NSArray<PositionSizeRangeModel *> *)getClothesPositionSizeRangeArray:(NSString *)catecode bySex:(BOOL)isMan{
    
    NSString *predicateFromatStr;
    if (isMan) {
        predicateFromatStr  = [NSString stringWithFormat:@"man CONTAINS '-'"];
    }else{
        predicateFromatStr = [NSString stringWithFormat:@"woman CONTAINS '-'"];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFromatStr];
    
    NSArray *array = [[self getClothesPositionSizeRangeArray:catecode] filteredArrayUsingPredicate:predicate];
    
    return array;
}


/**
 * 根据部位的名称获取部位的尺寸范围
 **/
+(PositionSizeRangeModel *)getBodyPositionSizeRangeByPositionName:(NSString *)positionName{
    
    NSArray *array = [self getBodyPositionSizeRangeArray];
    
    PositionSizeRangeModel *rangeModel;
    
    for (PositionSizeRangeModel *itemModel in array) {
        if ([itemModel.position isEqualToString:positionName]) {
            rangeModel = itemModel;
            break;
        }
    }
    
    return rangeModel;
    
}

+(NSArray<PositionSizeRangeModel *> *)getBodyPositionSizeRangeArrayBySex:(BOOL)isMan{
    
    NSString *predicateFromatStr;
    if (isMan) {
        predicateFromatStr  = [NSString stringWithFormat:@"man CONTAINS '-'"];
    }else{
        predicateFromatStr = [NSString stringWithFormat:@"woman CONTAINS '-'"];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFromatStr];
    
    NSArray *array = [[self getBodyPositionSizeRangeArray] filteredArrayUsingPredicate:predicate];
    
    return array;
}

@end
