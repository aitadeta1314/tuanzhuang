//
//  AdditionalTableViewCell.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/3/28.
//  Copyright © 2018年 red. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const STRING_CLOTHES_NO_PLEAT = @"无褶";
static NSString * const STRING_CLOTHES_SINGLE_PLEAT = @"单褶";
static NSString * const STRING_CLOTHES_DOUBLE_PLEAT = @"双褶";

typedef void(^ValueChangedBlock)(NSArray<AdditionModel *> * changedAdditions);

typedef void(^PickerViewDisplayBlock)(BOOL show);

@interface AdditionalTableViewCell : UITableViewCell


@property(nonatomic,strong) AdditionModel *addtionModel;

//值改变的回调函数
@property(nonatomic,copy) ValueChangedBlock changedBlock;

//显示或隐藏pickerView通知回调函数
@property(nonatomic,copy) PickerViewDisplayBlock pickerViewDisplayBlock;

/**
 * 隐藏已经显示的pickerView
 */
-(void)hiddenPickerView;

/**
 * 赋值模型数据
 */
-(void)setTitle:(NSString *)title andAddtionModel:(AdditionModel *)addtion;

#pragma mark - Class Methods

/**
 * 获取行高
 **/
+(CGFloat)getCellHeightByAddition:(AdditionModel *)additional;


@end
