//
//  ConfigSlideMenuView.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/10.
//  Copyright © 2018年 red. All rights reserved.
//

#import "CustomSlideMenuView.h"

typedef void(^CategorySizeTypeChangedBlock)(NSArray *bodyCategoryArray,NSArray *clothesCategoryArray);

@interface ConfigSlideMenuView : CustomSlideMenuView

@property(nonatomic,copy) CategorySizeTypeChangedBlock changedBlock;

@end
