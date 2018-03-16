//
//  PersonnelModel+Description.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/3/6.
//  Copyright © 2018年 red. All rights reserved.
//

#import "PersonnelModel+Description.h"
#import "PersonnelModel+Helper.h"

@implementation PersonnelModel (Description)

#pragma mark - Category Config Description Methods

/**
 * 获取品类配置描述
 ***/
-(NSString *)getCategoryConfigDescription{
    NSMutableString *description = [NSMutableString string];
    
    NSArray *categoryCodes = [Category_Code_Array_Str componentsSeparatedByString:@","];
    
    for (NSString *code in categoryCodes) {
        NSInteger count = [self getConfigCategoryCount:code];
        
        if (count>0) {
            [description appendString:[NSString stringWithFormat:@"%ld%@",count,code]];
        }
        
    }
    
    return description;
}

/**
 * 获取不同量体方式的品类配置描述
 **/
-(NSString *)getCategoryConfigDescription_BySizeType{
    
    NSArray *bodyCategorys = [self getCategorySizeType:CategorySizeType_Body];
    NSArray *clothesCategorys = [self getCategorySizeType:CategorySizeType_Clothes];
    
    NSMutableArray *description = [NSMutableArray array];
    
    NSString *bodyConfigStr = [self getCategoryArrayConfigDescription:bodyCategorys andTitle:@"净体："];
    NSString *clothesConfigStr = [self getCategoryArrayConfigDescription:clothesCategorys andTitle:@"成衣："];
    
    if (bodyConfigStr.isValidString) {
        [description addObject:bodyConfigStr];
    }
    
    if (clothesConfigStr.isValidString) {
        [description addObject:clothesConfigStr];
    }
    
    return [description componentsJoinedByString:@"/"];
}

-(NSString *)getCategoryArrayConfigDescription:(NSArray *)categoryArray andTitle:(NSString *)title{
    NSMutableString *description = [NSMutableString string];
    
    if ([categoryArray count] > 0) {
        [description appendString:title];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cate in %@",@[Category_Code_A,Category_Code_B]];
        NSArray *categoryTArray = [categoryArray filteredArrayUsingPredicate:predicate];
        //套装T数量
        NSInteger count = [self getConfigCategoryCount:Category_Code_T];
        
        if ([categoryTArray count] > 0 && count>0) {
            [description appendString:[NSString stringWithFormat:@"%ldT",count]];
        }
        
        for (CategoryModel *category in categoryArray) {
            
            [description appendString:[self getCategoryConfigDescription:category]];
        }
    }
    
    return description;
}

-(NSString *)getCategoryConfigDescription:(CategoryModel *)category{
    NSString *description = @"";
    NSInteger count = [self getConfigCategoryCount:category.cate];
    
    if (count > 0) {
        description = [NSString stringWithFormat:@"%ld%@",count,category.cate];
    }
    
    return description;
}

@end
