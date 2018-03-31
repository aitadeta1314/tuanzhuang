//
//  SpecialBodyOptionModel.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/11.
//  Copyright © 2018年 red. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SPECIAL_BODY_TYPE) {
    SPECIAL_BODY_TYPE_ALL = 0,      //成衣与净体
    SPECIAL_BODY_TYPE_BODY,         //净体
    SPECIAL_BODY_TYPE_CLOTHES,      //成衣
};

@interface SpecialBodyOptionModel : NSObject

@property(nonatomic,strong) NSString *group;
@property(nonatomic,strong) NSArray<SpecialBodyOptionModel *> *options;
@property(nonatomic,assign) SPECIAL_BODY_TYPE   type;   //1：净体  2：成衣

@property(nonatomic,strong) NSString *name;
@property(nonatomic,assign) NSInteger code;


+(NSArray *)getSpecialBodyOptions:(BOOL)mtm;

/**
 * 获取特体信息
 * @param hasBody : 是否包含净体的特体信息
 * @param hasClothes : 是否包含成衣的特体信息
 * @param mtm       : 是否为MTM数据
 **/
+(NSArray *)getSpecialBodyOptions:(BOOL)hasBody andHasClothes:(BOOL)hasClothes isMTMData:(BOOL)mtm;

@end
