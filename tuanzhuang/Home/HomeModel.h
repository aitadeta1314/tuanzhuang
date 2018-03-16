//
//  HomeModel.h
//  tuanzhuang
//
//  Created by Fenly on 2017/12/5.
//  Copyright © 2017年 red. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeModel : NSObject

/**
 *  CompanyModel
 */
@property (nonatomic, strong) CompanyModel *companyModel;
@property (nonatomic,copy) NSString *companyName;
@property (nonatomic,copy) NSString *createTime;
@property (nonatomic,copy) NSString *numberOfPerson;
@property (nonatomic,copy) NSString *waitNum;
@property (nonatomic,copy) NSString *beingNum;
@property (nonatomic,copy) NSString *doneNum;
@property (nonatomic,copy) NSString *syncTimes; // 同步次数
@property (nonatomic,copy) NSString *syncTime;  // 同步时间
@property (nonatomic,copy) NSString *uploadTimes; // 上传次数
@property (nonatomic,copy) NSString *uploadTime;  // 上传时间
@property (nonatomic,assign) BOOL hiddenShade;  // 是否隐藏遮罩
@property (nonatomic,assign) BOOL isSelected;   // 是否选中

@end

