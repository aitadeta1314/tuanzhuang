//
//  NSDictionary+DIC_Extension.m
//  tuanzhuang
//
//  Created by zhuang on 2018/1/4.
//  Copyright © 2018年 red. All rights reserved.
//

#import "NSDictionary+DIC_Extension.h"

@implementation NSDictionary (DIC_Extension)

-(NSMutableDictionary *)copyToDic{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    for(NSString* key in self){
        [dic setValue:self[key] forKey:key];
    }
    return dic;
}

/**
 是否是有效的字典
 
 @return BOOL 类型, 是否是有效的字典
 */
- (BOOL)isValidDic {
    return [self isValidObject] &&
    [self.allKeys isValidArray] &&
    [self.allValues isValidArray] &&
    self.allKeys.count == self.allValues.count;
}

@end
