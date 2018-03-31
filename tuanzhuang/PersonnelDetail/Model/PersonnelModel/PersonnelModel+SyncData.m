//
//  PersonnelModel+SyncData.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/3/6.
//  Copyright © 2018年 red. All rights reserved.
//

#import "PersonnelModel+SyncData.h"
#import "PersonnelModel+Helper.h"
#import "NSManagedObject+Coping.h"
#import "AdditionModel+Helper.h"
#import "PositionSizeRangeModel.h"

@implementation PersonnelModel (SyncData)

/**
 * 初始同步更新CY/CD的尺寸数据
 **/
-(void)referencePositionSizeByAssociateCategory:(CategoryModel *)category{
    
    if ([category.position count] > 0) {
        return;
    }
    
    NSArray *associateCategorys = [self getAssociatedCategoryCodeArray:category.cate];
    
    if ([associateCategorys count]) {
        
        NSString *categoryCode = associateCategorys[0];
        
        NSArray *categoryArray = [self getCategoryArrayByCode:categoryCode];
        
        for (CategoryModel *otherCategory in categoryArray) {
            
            if ([otherCategory.position count]>0) {
                [category copyRelationships:@"position" From:otherCategory];
            }
            
            NSSet *sleevePositions = [category.position filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"positionname CONTAINS[cd] '袖长'"]];
            
            for (PositionModel *position in sleevePositions) {
                [position MR_deleteEntity];
            }
            break;
        }
    }
    
}

#pragma mark - 根据部位尺寸，更新加放量中的对应部位尺寸

/**
 * 根据部位尺寸，更新加放量中的对应部位尺寸
 * @param positionName 部位名称
 * @param size         尺寸
 * @param changed      修改触发block
 **/
-(void)referenceAdditionByPositionName:(NSString *)positionName andSize:(NSInteger)size complete:(ChangedBlock)complete{
    
    BOOL changed = NO;
    
    NSDictionary *positionDic = [AdditionModel positionAssociateDic];
    
    for (NSString *name in positionDic.allKeys) {
        
        NSString *key = [positionDic objectForKey:name];
        
        if ([positionName containsString:name]) {
            NSArray *categoryArray = [self getCategorySizeType:CategorySizeType_Body];
            
            for (CategoryModel *category in categoryArray) {
                BOOL validate = [AdditionModel validateSyncPositioin:positionName inCategory:category.cate];
                
                if (validate) {
                    changed = YES;
                    for (AdditionModel *addition in category.addition) {
                        [addition setValue:@(size) forKey:key];
                    }
                }
            }
            
            break;
        }
    }
    
    if (changed && complete) {
        complete(changed);
    }
}

#pragma mark - Sync Category CY and CD Clothes Position Size
/**
 * 同步关联的品类的成衣尺寸
 ***/
-(void)syncAssociationCategory:(CategoryModel *)category andPositionSize:(PositionModel *)position{
    
    NSArray *associateArray = [self getAssociatedCategoryCodeArray:category.cate];
    
    if ([position.positionname containsString:@"袖长"]) {
        return;
    }
    
    if ([associateArray count]) {
        
        NSString *associateCategoryCode = associateArray[0];
        
        NSArray *categoryArray = [self getCategoryArrayByCode:associateCategoryCode];
        
        for (CategoryModel *otherCategory in categoryArray) {
            
            PositionModel *otherPosition = [self getPositionByCode:position.blcode atCategory:otherCategory];
            
            if (!otherPosition) {
                otherPosition = [PositionModel MR_createEntity];
            }
            
            [otherPosition copyAttributesFrom:position];
            otherPosition.category = otherCategory;
        }
    }
}

/**
 * 修改性别，更新部位尺寸的BLCode
 **/
-(void)referenceCategoryPositionsBLCode:(CategoryModel *)category{
    
    for (PositionModel *position in category.position) {
        PositionSizeRangeModel *sizeRangeModel = [PositionSizeRangeModel getClothesPositionSizeRange:category.cate byBLCode:position.blcode andMTM:self.mtm];
        
        if (PERSON_GENDER_MAN == self.gender) {
            position.blcode = sizeRangeModel.blcode;
        }else{
            position.blcode = sizeRangeModel.wblcode;
        }
    }
    
    //[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

/**
 * 修改性别，更新所有的的成衣的部位尺寸的BLCode
 **/
-(void)referenceClothesCategoryPositionsBLCode{
    
    for (CategoryModel *category in self.category) {
        [self referenceCategoryPositionsBLCode:category];
    }
    
}

/**
 * 修改性别，更新配置的品类的数量为0
 **/
-(void)resetCategoryConfigCountBySexChanged{
    
    NSArray *categorys = [Category_Code_Array_Str componentsSeparatedByString:@","];
    
    for (NSString *code in categorys) {
        
        if (![self canConfigCategory:code]) {
            //验证是否可配置该品类,不可配置时置0
            [self setConfigCategoryCount:0 byCategoryCode:code];
            [self setCategoryCount:0 byCategoryCode:code];
        }
        
    }
    
}

#pragma mark - 修改性别关联修改数据
/**
 * 修改性别修改关联数据
 **/
-(void)referenceAssociateDataBySexChanged{
    
    //重新配置全局的品类
    [self setupCompanyCategoryConfigure];
    
    //重置该性别不能配置的品类的数量为0
    [self resetCategoryConfigCountBySexChanged];
    
    //重置加放量数据
    [self resetAssociateAdditional];
    
    //更新或有的成衣部位的BLCode
    [self referenceClothesCategoryPositionsBLCode];
    
}

#pragma mark - 配置公司全局设置的品类数量
-(void)setupCompanyCategoryConfigure{
    
    BOOL allowConfig = [self allowCompanyCategoryConfig];
    
    if (allowConfig && self.company && self.company.configuration.isValidString) {
        
        NSMutableDictionary *countDic = [NSMutableDictionary dictionary];
        NSMutableDictionary *categoryConfigDic = [NSMutableDictionary dictionaryWithDictionary:[PersonnelModel convertDicByCategoryConfigStr:self.company.configuration]];
        
        
        for (NSString *categoryCode in categoryConfigDic.allKeys) {
            
            if (![self canConfigCategory:categoryCode]) {
                //不能配置该品类
                [categoryConfigDic removeObjectForKey:categoryCode];
                continue;
            }
            
            NSInteger count = [[categoryConfigDic objectForKey:categoryCode] integerValue];
            
            if ([categoryCode isEqualToString:Category_Code_T]) {
                
                NSInteger count_A = [[countDic objectForKey:Category_Code_A] integerValue];
                NSInteger count_B = [[countDic objectForKey:Category_Code_B] integerValue];
                
                [countDic setObject:@(count_A + count) forKey:Category_Code_A];
                [countDic setObject:@(count_B + count) forKey:Category_Code_B];
            }else{
                NSInteger count_Category = [[countDic objectForKey:categoryCode] integerValue];
                
                [countDic setObject:@(count + count_Category) forKey:categoryCode];
            }
        }
        
        //删除之前的品类
        for (CategoryModel *category in self.category) {
            [category MR_deleteEntity];
        }
        [self removeCategory:self.category];
        
        //复制默认的品类配置
        self.category_config = [PersonnelModel convertStrByCategoryConfigDic:categoryConfigDic];
        
        for (NSString *categoryCode in countDic.allKeys) {
            NSInteger count = [[countDic objectForKey:categoryCode] integerValue];
            [self setCategoryCount:count byCategoryCode:categoryCode];
        }
        
    }
    
}

/**
 * 是否允许使用公司全局类别配置
 **/
-(BOOL)allowCompanyCategoryConfig{
    BOOL allow = YES;
    
    if ([self.position count] > 0) {
        //有净体的部位尺寸
        allow = NO;
    }else{
        //有成衣的部位尺寸
        for (CategoryModel *category in self.category) {
            if ([category.position count] > 0) {
                allow = NO;
                break;
            }
        }
    }
    
    if (allow && self.status != PERSON_STATUS_WAITING) {
        //判断品类是否一样
        allow = NO;
    }
    
    return allow;
}


@end
