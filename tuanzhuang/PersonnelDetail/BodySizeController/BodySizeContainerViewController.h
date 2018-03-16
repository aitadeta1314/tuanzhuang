//
//  BodySizeContainerViewController.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/28.
//  Copyright © 2017年 red. All rights reserved.
//

#import "SuperViewController.h"
#import "LockConverView.h"

@interface BodySizeContainerViewController : SuperViewController

@property(nonatomic,strong) PersonnelModel *personModel;

@property(nonatomic,assign) BOOL showLockView;

@property(nonatomic,copy) voidBlock unLockBlock;

-(void)reloadData;

@end
