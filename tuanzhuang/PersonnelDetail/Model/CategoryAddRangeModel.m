//
//  CategoryAddRangeModel.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/17.
//  Copyright © 2018年 red. All rights reserved.
//

#import "CategoryAddRangeModel.h"

@implementation CategoryAddRangeModel

#pragma mark - Getter Methods
-(NSArray *)cateArray{
    return [self.cate componentsSeparatedByString:@","];
}

-(NSArray *)manRangeArray{
    return [self.manRange componentsSeparatedByString:@","];
}

-(NSArray *)womenRangeArray{
    return [self.womenRange componentsSeparatedByString:@","];
}

#pragma mark - Class Methods

+(NSArray<CategoryAddRangeModel *> *)getCategoryAddRangeArray{
    
    static NSArray *addRangeArray;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (0 == [addRangeArray count]) {
            NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:BASIC_DATA_PLIST_FILE_PATH];
            
            NSArray *rangeArray = [dictionary objectForKey:@"categoryaddrange"];
            
            addRangeArray = [CategoryAddRangeModel mj_objectArrayWithKeyValuesArray:rangeArray];
        }
    });
    
    return addRangeArray;
}


+(CategoryAddRangeModel *)rangeModelByCategory:(NSString *)categoryCode withPleatType:(NSInteger)type{
    
    CategoryAddRangeModel *model;
    
    for (CategoryAddRangeModel *item in [self getCategoryAddRangeArray]) {
        
        if ([item.cateArray containsObject:categoryCode]) {
            
            if (item.type) {
                
                if ([item.type intValue] == type) {
                    model = item;
                    break;
                }
                
            }else{
                model = item;
                break;
            }
        }
    }
    
    return model;

}


@end
