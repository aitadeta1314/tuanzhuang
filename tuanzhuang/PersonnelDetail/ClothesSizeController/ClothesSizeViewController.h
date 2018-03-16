//
//  ClothesSizeViewController.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/28.
//  Copyright © 2017年 red. All rights reserved.
//

#import "SuperViewController.h"
#import "LockConverView.h"

/**
 * 冬季与夏季的件数 默认：夏季件数=总件数  冬季件数=0
 * 删除总件数：默认先删除夏季件数、再删除冬季件数
 ***/

@interface ClothesSizeViewController : SuperViewController

@property(nonatomic,strong) PersonnelModel *personModel;

@property(nonatomic,assign) BOOL    showLockView;

@property(nonatomic,copy) voidBlock  unLockBlock;

-(void)reloadData;

@end
