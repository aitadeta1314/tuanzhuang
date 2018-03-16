//
//  SpecialBodyViewController.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/4.
//  Copyright © 2018年 red. All rights reserved.
//

#import "SuperViewController.h"

@interface SpecialBodyViewController : SuperViewController

@property(nonatomic,strong) PersonnelModel *personModel;

-(void)reloadData;

@end
