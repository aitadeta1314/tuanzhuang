//
//  companyModel.h
//  tuanzhuang
//
//  Created by red on 2017/11/30.
//  Copyright © 2017年 red. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface companyModel : NSObject
@property (copy, nonatomic) NSString * companyid;
@property (copy, nonatomic) NSString * companyname;
@property (copy, nonatomic) NSString * uploaddate;
@property (copy, nonatomic) NSString * downloadtimes;
@property (assign, nonatomic) BOOL selected;
@property (assign, nonatomic) BOOL yiliang;//是否已量
@property (nonatomic, assign) int status;/**<0：普通状态，1：准备下载，2：正在下载 3:已完成*/
@end
