//
//  ReceiveInfoModel.m
//  tuanzhuang
//
//  Created by Fenly on 2017/12/20.
//  Copyright © 2017年 red. All rights reserved.
//

#import "ReceiveInfoModel.h"

@interface ReceiveInfoModel ()<NSCopying, NSMutableCopying>

@end

@implementation ReceiveInfoModel

- (id)copyWithZone:(NSZone *)zone {
    ReceiveInfoModel *model = [[ReceiveInfoModel allocWithZone:zone] init];
    model.name = self.name;
    model.gender = self.gender;
    model.department = self.department;
    model.jobnumber = self.jobnumber;
    model.dataStatus = self.dataStatus;
    model.dataRepeatLogo = self.dataRepeatLogo;
    model.dataEditStatus = self.dataEditStatus;
    model.data = self.data;
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    ReceiveInfoModel *model = [[ReceiveInfoModel allocWithZone:zone] init];
    model.name = self.name;
    model.gender = self.gender;
    model.department = self.department;
    model.jobnumber = self.jobnumber;
    model.dataStatus = self.dataStatus;
    model.dataRepeatLogo = self.dataRepeatLogo;
    model.dataEditStatus = self.dataEditStatus;
    model.data = self.data;
    return model;
}

@end
