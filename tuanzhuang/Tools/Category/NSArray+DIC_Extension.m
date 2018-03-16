//
//  NSArray+Dic_Extension.m
//  tuanzhuang
//
//  Created by zhuang on 2017/12/26.
//  Copyright © 2017年 red. All rights reserved.
//

#import "NSArray+DIC_Extension.h"

@implementation NSArray (DIC_Extension)

- (BOOL)isValidArray {
    return (self && self.count > 0);
}

// NSDictionary - 少些几行代码
- (int) indexToDic:(NSDictionary*)dic{
    int i = 0;
    NSDictionary* one = nil;
    for(;i<self.count;i++){
        one = self[i];
        for(id key in dic){
            if(![one[key] isEqualToString:dic[key]]){
                one = nil;
                break;
            }
        }
        if(one!=nil){// 匹配成功：返回
            break;
        }
    }
    return i<self.count?i:-1;
}

// NSDictionary -
- (NSMutableArray*)copyToDic{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(int i = 0;i<self.count;i++){
        [res addObject:self[i]];
    }
    return res;
}

@end
