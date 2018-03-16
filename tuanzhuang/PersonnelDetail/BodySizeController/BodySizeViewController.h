//
//  BodySizeViewController.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/26.
//  Copyright © 2017年 red. All rights reserved.
//

#import "SuperViewController.h"
#import "PersonnelModel+CoreDataClass.h"

typedef void(^VoidBlock)(void);

@interface BodySizeViewController : SuperViewController

/**
 * 重新加载加放量的数据
 **/
@property(nonatomic,copy) VoidBlock reloadAddtionalData;

@property(nonatomic,strong) PersonnelModel *personModel;

-(void)reloadData;

@end
