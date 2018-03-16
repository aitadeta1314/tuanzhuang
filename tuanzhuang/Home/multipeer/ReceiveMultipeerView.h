//
//  MultipeerView.h
//  tuanzhuang
//
//  Created by zhuang on 2017/12/5.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Multipeer.h"

@interface ReceiveMultipeerView : UIViewController

@property (strong,nonatomic) Multipeer * multipeer;/** 多点连接 */
//
- (instancetype)initView;

@end
