//
//  ReceiveInfoModel.h
//  tuanzhuang
//
//  Created by Fenly on 2017/12/20.
//  Copyright © 2017年 red. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReceiveInfoModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *department;
@property (nonatomic, copy) NSString *jobnumber;
@property (nonatomic, assign) DATAIN_STATUS dataStatus;
/**
 * 数据重复标识
 */
@property (nonatomic, assign) DATA_REPEAT_LOGO dataRepeatLogo;

/**
 * 数据是否可编辑
 */
@property (nonatomic, assign) DATA_EDIT dataEditStatus;
/**
 *  数据字典
 */
@property (nonatomic, strong) NSMutableDictionary *data;

@end
