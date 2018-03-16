//
//  StartSyncViewController.h
//  tuanzhuang
//
//  Created by zhuang on 2017/12/11.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZCircleProgress.h"
#import "Multipeer.h"
#import "DeviceEntity.h"

@interface StartSyncViewController : SuperViewController

@property (strong,nonatomic) DeviceEntity* device;
@property (strong,nonatomic) Multipeer* multipeer;

@end
