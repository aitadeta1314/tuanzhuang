//
//  PersonMsgSlideMenuView.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/21.
//  Copyright © 2017年 red. All rights reserved.
//

#import "CustomSlideMenuView.h"

typedef void(^VoidBlock)(void);

@interface PersonMsgSlideMenuView : CustomSlideMenuView

@property(nonatomic,assign) BOOL isNew;

@property(nonatomic,strong) VoidBlock changedBlock;

@end
