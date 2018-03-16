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



@end
