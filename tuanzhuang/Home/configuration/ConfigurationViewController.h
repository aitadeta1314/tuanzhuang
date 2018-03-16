//
//  ConfigurationViewController.h
//  tuanzhuang
//
//  Created by Fenly on 2017/12/1.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^SaveSelectBlock)(NSString *str);

@interface ConfigurationViewController : UIViewController

/**
 * block
 */
@property (nonatomic,copy) SaveSelectBlock saveSelectBlock;

/**
 * 公司名字
 */
@property (nonatomic,copy) NSString *companyName;

/**
 初始化信息函数

 @param itemDic  各数据项字典
 @param nameText 如果是公司名称则传公司名称，如果是配置信息则传@""
 */
- (instancetype)initWithItemArray:(NSDictionary *)itemDic topText:(NSString *)nameText;

@end
