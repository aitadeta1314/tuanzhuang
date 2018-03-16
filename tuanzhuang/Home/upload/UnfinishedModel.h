//
//  UnfinishedModel.h
//  tuanzhuang
//
//  Created by red on 2018/2/27.
//  Copyright © 2018年 red. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PersonnelModel;

@interface UnfinishedModel : NSObject
@property (nonatomic, assign) BOOL selected;/**<是否被选中*/
@property (nonatomic, strong) PersonnelModel * personModel;/**<*/
@end
