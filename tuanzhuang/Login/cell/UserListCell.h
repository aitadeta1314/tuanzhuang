//
//  UserListCell.h
//  tuanzhuang
//
//  Created by zhuang on 2017/12/19.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^delUserBlock)(NSDictionary* info);

@interface UserListCell : UITableViewCell

@property (nonatomic, copy) delUserBlock delUserAction;/** 删除数据 */

-(void)loadData:(NSUserDefaults*)user;

@end
