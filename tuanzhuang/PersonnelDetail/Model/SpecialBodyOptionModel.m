//
//  SpecialBodyOptionModel.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/11.
//  Copyright © 2018年 red. All rights reserved.
//

#import "SpecialBodyOptionModel.h"

static NSString * const KEY_SPECIAL_BODY = @"special_body";
static NSString * const KEY_SPECIAL_BODY_MTM = @"special_body_mtm";

@implementation SpecialBodyOptionModel

+(void)load{
    [SpecialBodyOptionModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"options":@"SpecialBodyOptionModel"
                 };
    }];
}

+(NSArray *)getSpecialBodyOptions:(BOOL)mtm{
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:BASIC_DATA_PLIST_FILE_PATH];
    
    NSArray *modelArray;
    
    if (mtm) {
        modelArray = [SpecialBodyOptionModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:KEY_SPECIAL_BODY_MTM]];
    }else{
        modelArray = [SpecialBodyOptionModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:KEY_SPECIAL_BODY]];
    }
    
    return modelArray;
}

+(NSArray *)getSpecialBodyOptions:(BOOL)hasBody andHasClothes:(BOOL)hasClothes isMTMData:(BOOL)mtm{
    
    NSArray *tempArray = [self getSpecialBodyOptions:mtm];
    
    NSMutableArray *types = [NSMutableArray arrayWithObjects:@(SPECIAL_BODY_TYPE_ALL), nil];
    
    if (hasBody) {
        [types addObject:@(SPECIAL_BODY_TYPE_BODY)];
    }

    if (hasClothes) {
        [types addObject:@(SPECIAL_BODY_TYPE_CLOTHES)];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type IN %@",types];
    
    tempArray = [tempArray filteredArrayUsingPredicate:predicate];
    
    
    //筛选所有的子选项
    for (SpecialBodyOptionModel *model in tempArray) {
        
        NSArray *options = [model.options filteredArrayUsingPredicate:predicate];
        
        model.options = options;
    }
    
    
    return  tempArray;
}

@end


