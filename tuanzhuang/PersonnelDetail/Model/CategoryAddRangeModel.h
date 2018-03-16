//
//  CategoryAddRangeModel.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/17.
//  Copyright © 2018年 red. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryAddRangeModel : NSObject

@property(nonatomic,strong) NSString *cate;
@property(nonatomic,strong) NSString *rangeStr;
@property(nonatomic,assign) NSInteger manValue;
@property(nonatomic,assign) NSInteger womenValue;
@property(nonatomic,strong) NSString *type; //无褶、单褶、双褶

@property(nonatomic,strong,readonly) NSArray  *cateArray;
@property(nonatomic,strong,readonly) NSArray  *rangeArray;

+(NSArray<CategoryAddRangeModel *> *)getCategoryAddRangeArray;

+(CategoryAddRangeModel *)rangeModelByCategory:(NSString *)categoryCode withPleatType:(NSInteger)type;

@end
