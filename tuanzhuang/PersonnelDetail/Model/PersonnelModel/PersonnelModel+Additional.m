//
//  PersonnelModel+Additional.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/3/14.
//  Copyright © 2018年 red. All rights reserved.
//

#import "PersonnelModel+Additional.h"
#import "PersonnelModel+Helper.h"
#import "AdditionModel+Helper.h"

@implementation PersonnelModel (Additional)

/**
 * 重置关联的加放量数据
 */
-(void)resetAssociateAdditional{
    
    NSArray *categoryArray = [self getCategorySizeType:CategorySizeType_Body];
    
    for (CategoryModel *category in categoryArray) {
        
        for (AdditionModel *addition in category.addition) {
            [addition reset];
        }
    }
    
    //[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

@end
