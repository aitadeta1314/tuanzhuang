//
//  CategoryModel+Helper.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/24.
//  Copyright © 2018年 red. All rights reserved.
//

#import "CategoryModel+Helper.h"
#import "CategoryAddRangeModel.h"
#import "NSManagedObject+Coping.h"
#import "PersonnelModel+Helper.h"
#import "AdditionModel+Helper.h"

static NSDictionary *_titleDic;

@implementation CategoryModel (Helper)

+(void)load{
    [super load];
    
    _titleDic = @{Category_Code_A:@"西服上衣",
                  Category_Code_B:@"西裤",
                  Category_Code_C:@"马甲",
                  Category_Code_CY:@"长袖衬衫",
                  Category_Code_CD:@"短袖衬衫",
                  Category_Code_D:@"西裙",
                  Category_Code_W:@"大衣"
                  };
}

-(NSString *)name{
    
    NSString *title = [_titleDic objectForKey:self.cate];
    
    return title;
}

-(AdditionModel *)summerAddition{
    
    return [self getAdditionItemBySeason:SEASON_TYPE_SUMMER];
}

-(AdditionModel *)winterAddition{
    
    return [self getAdditionItemBySeason:SEASON_TYPE_WINTER];
}

-(NSArray *)summerAdditionArray{
    return [self getAddtionArrayBySeason:SEASON_TYPE_SUMMER];
}

-(NSArray *)winterAdditionArray{
    return [self getAddtionArrayBySeason:SEASON_TYPE_WINTER];
}

-(NSArray *)getAddtionArrayBySeason:(SEASON_TYPE)season{
    NSArray *addtionArray = [[self.addition filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"season == %d",season]]  sortedArrayUsingDescriptors:@[]];
    
    return addtionArray;
}

-(AdditionModel *)getAdditionItemBySeason:(SEASON_TYPE)season{
    
    AdditionModel *addition;
    
    NSArray *addtionArray = [[self.addition filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"season == %d",season]]  sortedArrayUsingDescriptors:@[]];
    
    if ([addtionArray count]>0) {
        addition=  addtionArray[0];
    }
    return addition;
}



#pragma mark - Count Changed Season Count
/**
 * 更改品类的数量时，关联修改品类的冬季与夏季数量
 * 添加品类数量，品类的夏季数量随之增加
 * 删除品类数量，先删除夏季数量，再删除冬季数量
 **/
-(void)associatedSetCategorySeasonCount{
    
    NSInteger totalCount = self.count;
    NSInteger seasonCount = self.winterCount + self.summerCount;
    
    if (totalCount > seasonCount) {
        
        NSInteger diffCount = totalCount - seasonCount;
        self.summerCount += diffCount;
        
    }else if (totalCount < seasonCount){
        
        NSInteger diffCount = seasonCount - totalCount;
        
        if (diffCount > self.summerCount) {
            
            diffCount -= self.summerCount;
            self.summerCount = 0;
            self.winterCount -= diffCount;
            
        }else{
            self.summerCount -= diffCount;
        }
    }
    
    //关联修改品类的加放量表
    [self associatedSetCategoryAddtional];
}

#pragma mark - Count Change associate Addition

/**
 * 修改品类加放量数量记录
 ***/
-(void)associatedSetCategoryAddtional{
    
    CategorySizeType type = self.type;
    
    if (CategorySizeType_Clothes == type) {
        //成衣测量方式：删除所有加放量
        for (AdditionModel *addtion in self.addition) {
            [addtion MR_deleteEntity];
        }
    }else{
        //品类数量修改：添加或删除加放量
        int diffCount = self.count - (int)[self.addition count];
        
        if (diffCount > 0) {
            //添加新的加放量对象
            for (int i=0; i<diffCount; i++) {
                
                AdditionModel *summerAddition = self.summerAddition;
                
                AdditionModel *addtion = [AdditionModel MR_createEntity];
                addtion.category = self;
                
                if (summerAddition) {
                    [addtion copyAttributesFrom:summerAddition];
                }else{
                    //设置默认值
                    [addtion reset];
                }
            }
        }else if (diffCount<0){
            
            diffCount = abs(diffCount);
            
            NSInteger summerCount = [self.summerAdditionArray count];
            NSInteger winterCount = [self.winterAdditionArray count];
            
            if (diffCount > summerCount) {
                winterCount = diffCount - summerCount;
            }else{
                summerCount = diffCount;
                winterCount = 0;
            }
            
            NSArray *summerArray = [self.summerAdditionArray subarrayWithRange:NSMakeRange(0, summerCount)];
            NSArray *winterArray = [self.winterAdditionArray subarrayWithRange:NSMakeRange(0, winterCount)];
            
            for (AdditionModel *model in summerArray) {
                [self removeAdditionObject:model];
                [model MR_deleteEntity];
            }
            
            for (AdditionModel *model in winterArray) {
                [self removeAdditionObject:model];
                [model MR_deleteEntity];
            }
        }
    }
}


#pragma mark - Value Changed Methods
-(void)didChangeValueForKey:(NSString *)key{
    [super didChangeValueForKey:key];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[[self entity] name] forKey:KEY_ENTITY_USERINFO_NOTIFICATION];
    
    if (self.personnel) {
        [userInfo setObject:self.personnel forKey:KEY_PERSON_USERINFO_NOTIFICATION];
    }
    
    //发送修改通知
    [[NSNotificationCenter defaultCenter] postNotificationName:KEY_NOTIFICATION_CENTER_PERSON_SIZE_OPERATION object:nil userInfo:userInfo];
}

#pragma mark - Class Methods

/**
 * 根据品类编码获取品类名称
 */
+(NSString *)getNameByCode:(NSString *)code{
    return [_titleDic objectForKey:code];
}

@end
