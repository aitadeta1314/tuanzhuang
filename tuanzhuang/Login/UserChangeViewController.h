//
//  UserChangeViewController.h
//  tuanzhuang
//
//  Created by zhuang on 2017/12/14.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserChangeViewController : SuperViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray * list;/**用户列表*/

@end
