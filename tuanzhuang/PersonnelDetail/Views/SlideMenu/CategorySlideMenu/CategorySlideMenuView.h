//
//  CategorySlideMenuView.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/22.
//  Copyright © 2017年 red. All rights reserved.
//

//  在设置品类数量为0时，删除该品类：
//       但是如果该品类已经包含成衣的测量数据，不删除该品类。设置品类的数量为0
//

#import "CustomSlideMenuView.h"

/**
 *@param cateCode 品类标识符
 *@param count    品类数量
 *@param cateLabel  品类标识符Label
 */
typedef void(^CategoryCountChangedBlock)(NSString *cateCode,NSInteger count,UILabel *cateLabel);

@interface CategorySlideMenuView : CustomSlideMenuView

/**
 * 品类数量修改后回调block
 **/
@property(nonatomic,copy) CategoryCountChangedBlock countChangedBlock;


@end
