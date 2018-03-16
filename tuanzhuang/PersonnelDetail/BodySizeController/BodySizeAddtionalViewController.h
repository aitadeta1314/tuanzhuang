//
//  BodySizeAddtionalViewController.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/27.
//  Copyright © 2017年 red. All rights reserved.
//

//显示后衣长：西服上衣、长衬衫、短衬衫、大衣、马甲
//
//【需要注意：净体里面的后衣长，数据关联到附加信息、附加信息后衣长修改关联净体里的后衣长数据】
//
//显示顺序：西服上衣、长衬衫、短衬衫、大衣、马甲、西裤、西裙
//

#import "SuperViewController.h"
#import "CategoryAddRangeModel.h"

@interface BodySizeAddtionalViewController : SuperViewController

@property(nonatomic,strong) PersonnelModel *personModel;

-(void)reloadData;

@end
