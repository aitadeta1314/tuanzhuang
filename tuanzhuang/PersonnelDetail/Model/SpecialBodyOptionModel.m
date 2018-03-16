//
//  SpecialBodyOptionModel.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/11.
//  Copyright © 2018年 red. All rights reserved.
//

#import "SpecialBodyOptionModel.h"

@implementation SpecialBodyOptionModel

+(void)load{
    [SpecialBodyOptionModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"options":@"SpecialBodyOptionModel"
                 };
    }];
}

+(NSArray *)getSpecialBodyOptions{
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:BASIC_DATA_PLIST_FILE_PATH];
    
    NSArray *modelArray = [SpecialBodyOptionModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"special_body"]];
    
    return modelArray;
}

+(NSArray *)getSpecialBodyOptions:(BOOL)hasBody andHasClothes:(BOOL)hasClothes{
    
    NSArray *specialOptions = [self getSpecialBodyOptions];
    
    NSMutableArray *typeArray = [NSMutableArray arrayWithObjects:@(0), nil];
    
    if (hasBody) {
        [typeArray addObject:@(1)];
    }
    
    if (hasClothes) {
        [typeArray addObject:@(2)];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type IN %@",typeArray];
    
    specialOptions = [specialOptions filteredArrayUsingPredicate:predicate];
    
    return  specialOptions;
}

@end


