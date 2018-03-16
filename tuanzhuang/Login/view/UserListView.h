//
//  UserListView.h
//  tuanzhuang
//
//  Created by zhuang on 2017/12/19.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"

@interface UserListView : UIView <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) LoginViewController* dataSource;
//
-(void)loadData:(NSArray *)arr;

@end
