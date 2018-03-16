//
//  MultipeerCell.h
//  tuanzhuang
//
//  Created by zhuang on 2017/12/5.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceEntity.h"

@interface MultipeerCell : UITableViewCell

@property (strong, nonatomic) UIView *lineView;

@property (weak, nonatomic) IBOutlet UIImageView *syncStatusView;
//
-(void)loadData:(DeviceEntity*)device;
-(void)loadReceiveData:(DeviceEntity*)device;
-(void)loadSyncData:(DeviceEntity*)device;

@end
