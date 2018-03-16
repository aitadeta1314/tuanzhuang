//
//  SpecialBodyOptionModel.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/11.
//  Copyright © 2018年 red. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpecialBodyOptionModel : NSObject

@property(nonatomic,strong) NSString *group;
@property(nonatomic,strong) NSArray<SpecialBodyOptionModel *> *options;
@property(nonatomic,assign) NSInteger   type;   //1：成衣

@property(nonatomic,strong) NSString *name;
@property(nonatomic,assign) NSInteger code;


+(NSArray *)getSpecialBodyOptions;

/**
 * 获取特体信息
 * @param hasBody : 是否包含净体的特体信息
 * @param hasClothes : 是否包含成衣的特体信息
 **/
+(NSArray *)getSpecialBodyOptions:(BOOL)hasBody andHasClothes:(BOOL)hasClothes;

@end
