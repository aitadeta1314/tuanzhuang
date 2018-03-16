//
//  NSArray+Dic_Extension.h
//  tuanzhuang
//
//  Created by zhuang on 2017/12/26.
//  Copyright © 2017年 red. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (DIC_Extension)
- (BOOL)isValidArray;
- (int) indexToDic:(NSDictionary*)dic;
- (NSMutableArray*)copyToDic;

@end
