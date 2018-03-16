//
//  PersonDetailContainerViewController.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/20.
//  Copyright © 2017年 red. All rights reserved.
//
/**
 * 1、完善测量数据
 * 2、新建数据，并完成测量数据
 * 3、查看数据，不修改测量数据
 
 * 注意事项：
 *      修改品类的测量方式后，原测量方式的数据不删除。
 **/

#import "SuperViewController.h"
#import "TYTabPagerController.h"
#import "PersonnelModel+CoreDataClass.h"
#import "CompanyModel+CoreDataClass.h"

typedef NS_ENUM(NSUInteger, PERSON_DETAIL_STATE) {
    PERSON_DETAIL_STATE_EDIT,       //修改添加数据
    PERSON_DETAIL_STATE_NEW,        //创建一个新用户
    PERSON_DETAIL_STATE_VIEW,       //查看用户量体信息
};

@interface PersonDetailContainerViewController : TYTabPagerController<TYPagerControllerDataSource,TYPagerControllerDelegate>

@property(nonatomic,strong) CompanyModel *companyModel;
@property(nonatomic,strong) PersonnelModel *personModel;

@property(nonatomic,assign) int state;

@end
