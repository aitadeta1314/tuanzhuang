//
//  LockConverView.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/2/28.
//  Copyright © 2018年 red. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^voidBlock)(void);

@interface LockConverView : UIView

@property(nonatomic,copy) voidBlock unLockBlock;

@end
