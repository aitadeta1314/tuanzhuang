//
//  SyncMultipeerView.h
//  tuanzhuang
//
//  Created by zhuang on 2018/1/2.
//  Copyright © 2018年 red. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Multipeer.h"

@interface SyncMultipeerView : UIViewController

@property (strong,nonatomic) Multipeer * multipeer;/** 多点连接 */
//
- (instancetype)initView;

@end
