//
//  PersonnelModel+CategoriesHelper.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/22.
//  Copyright © 2018年 red. All rights reserved.
//

#import "PersonnelModel+CategoriesHelper.h"
#import "CategoryAddRangeModel.h"
#import "NSManagedObject+Coping.h"
#import "CategoryModel+Helper.h"
#import "AdditionModel+Helper.h"
#import "PersonnelModel+Helper.h"


@implementation PersonnelModel (CategoriesHelper)

/**
 * 是否可配置该品类
 **/
-(BOOL)canConfigCategory:(NSString *)categoryCode{
    
    BOOL pass = YES;
    
    if ([categoryCode isEqualToString:Category_Code_D] && PERSON_GENDER_MAN == self.gender) {
        pass = NO;
    }
    
    return pass;
    
}

/**
 * 获取指定量体方式的品类
 */
-(NSArray *)getCategorySizeType:(CategorySizeType)type{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %d && count>0",type];
    
    NSArray *categoryArray = [[self.category filteredSetUsingPredicate:predicate] sortedArrayUsingDescriptors:@[]];
    
    categoryArray = [self getSortedCategoryArray:categoryArray];
    
    return categoryArray;
}

-(void)setCategorySizeType:(CategorySizeType)type byCategoryCode:(NSString *)code{
    
    NSArray *categorys = [self getCategoryArrayByCode:code];
    
    for (CategoryModel *categoryItem in categorys) {
        categoryItem.type = type;
        
        //同步成衣测量下，CY/CD的尺寸一致
        [self referencePositionSizeByAssociateCategory:categoryItem];
        
        //修改净体测量的加放量信息
        [categoryItem associatedSetCategoryAddtional];
    }
    
    //[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

/**
 * 设置品类的数量
 */
-(void)setCategoryCount:(NSInteger)count byCategoryCode:(NSString *)code{
    
    //设置套装的数量
    if ([code isEqualToString:Category_Code_T]) {
        [self setCategoryTCount:count];
        return;
    }
    
    NSArray *categorys = [self getCategoryArrayByCode:code];
    
    CategoryModel *categoryItem;
    
    if ([categorys count] > 0) {
        categoryItem = categorys[0];
    }else if (count > 0){
        CategorySizeType type = [self getCategoryTypeByCode:code];
        
        categoryItem = [CategoryModel MR_createEntity];
        categoryItem.personnel = self;
        if (self.personnelid.isValidString) {
            categoryItem.personnelid = self.personnelid;
        }else{
            categoryItem.personnelid = @"";
        }
        
        categoryItem.cate = code;
        categoryItem.type = type;
    }
    
    if (count > 0 || [categoryItem.position count] > 0) {
        categoryItem.count = count;
        
        if (0 == count) {
            //删除有测量数据的成衣测量方式的品类时，需要设置测量方式为净体测量
            categoryItem.type = CategorySizeType_Body;
        }
        
        //关联配置冬季与夏季数量，并配置对应的加放量数据
        [categoryItem associatedSetCategorySeasonCount];
    }else if(categoryItem){
        [self removeCategoryObject:categoryItem];
        [categoryItem MR_deleteEntity];
    }
    
    //同步CY/CD的成衣量体尺寸数据同步
    [self referencePositionSizeByAssociateCategory:categoryItem];
    
    //[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

/**
 * 设置 套装的数量
 **/
-(void)setCategoryTCount:(NSInteger)count{
    
    NSInteger count_A = [self getConfigCategoryCount:Category_Code_A];
    NSInteger count_B = [self getConfigCategoryCount:Category_Code_B];
    
    count_A += count;
    count_B += count;
    
    [self setCategoryCount:count_A byCategoryCode:Category_Code_A];
    [self setCategoryCount:count_B byCategoryCode:Category_Code_B];
}

/**
 * 根据品类类型，获取品类列表
 */
-(NSArray *)getCategoryArrayByCode:(NSString *)categoryCode{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cate = %@",categoryCode];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"cate" ascending:YES];
    
    NSArray *categorys = [[self.category filteredSetUsingPredicate:predicate] sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    return categorys;
}

/**
 * 根据品类，获取关联的品类
 */
-(NSArray *)getAssociatedCategoryCodeArray:(NSString *)categoryCode{
    
    NSMutableArray *array = [NSMutableArray array];
    
    if ([Category_Code_T isEqualToString:categoryCode]) {
        [array addObject:Category_Code_A];
        [array addObject:Category_Code_B];
    }else if ([Category_Code_A isEqualToString:categoryCode]){
        [array addObject:Category_Code_B];
    }else if ([Category_Code_B isEqualToString:categoryCode]){
        [array addObject:Category_Code_A];
    }else if ([Category_Code_CY isEqualToString:categoryCode]){
        [array addObject:Category_Code_CD];
    }else if ([Category_Code_CD isEqualToString:categoryCode]){
        [array addObject:Category_Code_CY];
    }
    
    return array;
}


#pragma mark - private Helper Methods

-(CategorySizeType)getCategoryTypeByCode:(NSString *)categoryCode{
    
    CategorySizeType type = CategorySizeType_Body;
    
    NSArray *categorys = [self getCategoryArrayByCode:categoryCode];
    
    if ([categorys count]>0) {
        type = [(CategoryModel *)categorys[0] type];
    }else{
        NSArray *associatedCategorys = [self getAssociatedCategoryCodeArray:categoryCode];
        
        for (NSString *code in associatedCategorys) {
            NSArray *categorys = [self getCategoryArrayByCode:code];
            
            if ([categorys count]>0) {
                type = [(CategoryModel *)categorys[0] type];
                break;
            }
        }
    }
    
    return type;
}


-(NSArray *)getSortedCategoryArray:(NSArray *)categorys{
    NSArray *sortCategory = @[Category_Code_A,Category_Code_CY,Category_Code_CD,Category_Code_W,Category_Code_C,Category_Code_B,Category_Code_D];
    
    NSArray *sortedArray = [categorys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *cate1 = [(CategoryModel *)obj1 cate];
        NSString *cate2 = [(CategoryModel *)obj2 cate];
        
        if ([sortCategory indexOfObject:cate1] > [sortCategory indexOfObject:cate2]) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    
    return sortedArray;
}

/**
 * 设置配置里面的品类数量
 **/
-(void)setConfigCategoryCount:(NSInteger)count byCategoryCode:(NSString *)categoryCode{
    
    NSMutableDictionary *configDic = [NSMutableDictionary dictionaryWithDictionary:[PersonnelModel convertDicByCategoryConfigStr:self.category_config]];
    
    if (count > 0) {
        [configDic setObject:@(count) forKey:categoryCode];
    }else if ([configDic.allKeys containsObject:categoryCode]){
        [configDic removeObjectForKey:categoryCode];
    }
    
    self.category_config = [PersonnelModel convertStrByCategoryConfigDic:configDic];
}

/**
 * 获取品类配置里面的品类数量
 */
-(NSInteger)getConfigCategoryCount:(NSString *)categoryCode{
    
    NSDictionary *configDic = [PersonnelModel convertDicByCategoryConfigStr:self.category_config];
    
    return [[configDic objectForKey:categoryCode] integerValue];
}


#pragma mark - Class Method For Category Config Convert Methods

/**
 * 品类配置字符串转换为Dictionary类型
 * @param str : 品类配置字符串 "1-T,2-A,3-B"
 * return : {T:1,A:2,B:3}格式
 **/
+(NSDictionary *)convertDicByCategoryConfigStr:(NSString *)str{
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    NSArray *tempArray = [str componentsSeparatedByString:@","];
    
    for (NSString *itemStr in tempArray) {
        NSArray *itemArray = [itemStr componentsSeparatedByString:@"-"];
        
        if ([itemArray count] > 1) {
            NSString *key = itemArray[1];
            NSString *countStr = itemArray[0];
            NSInteger count = [countStr integerValue];
            
            [dictionary setObject:@(count) forKey:key];
        }
    }
    
    return dictionary;
}

/**
 * 品类配置Dictionary转换为字符串
 * @param dic : 品类配置 {T:1,A:2,B:3}
 * return : "1-T,2-A,3-B"
 **/
+(NSString *)convertStrByCategoryConfigDic:(NSDictionary *)dic{
    
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (NSString *key in dic.allKeys) {
        [tempArray addObject:[NSString stringWithFormat:@"%@-%@",[dic objectForKey:key],key]];
    }
    
    return [tempArray componentsJoinedByString:@","];
    
}



@end
