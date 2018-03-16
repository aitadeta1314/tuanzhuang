//
//  SizeTableViewCell.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/26.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BodySizeValueChangedBlock)(NSInteger size);

typedef void(^inputBecomeFirstResponderBlock)(void);
typedef void(^inputResignFirstResponserBlock)(void);

typedef NS_ENUM(NSUInteger, BodySizeCellStatus) {
    BodySizeCellStatus_Normal,      //正常状态
    BodySizeCellStatus_Selected,    //选中状态
    BodySizeCellStatus_Warning      //警告状态
};

@interface SizeTableViewCell : UITableViewCell

@property(nonatomic,strong) ZZNumberField *sizeTextField;

@property(nonatomic,assign) BodySizeCellStatus status;

/**
 * 尺寸值改变的block回调函数
 */
@property(nonatomic,copy) BodySizeValueChangedBlock sizeChangedBlock;

/**
 * 配置净体cell显示的数据
 *
 * @param title     量体部位名称
 * @param size      量体部位尺寸
 * @param minSize   最小尺寸
 * @param maxSize   最大尺寸
 * @param required 是否为必输项
 **/
-(void)setBodySizeTitle:(NSString *)title andSizeValue:(NSInteger)size andMinSize:(NSInteger)minSize andMaxSize:(NSInteger)maxSize isRequired:(BOOL)required;

/**
 * 配置成衣cell显示的数据
 **/
-(void)setClothSizeTitle:(NSString *)title andSizeValue:(NSString *)sizeValue andMinSize:(NSInteger)minSize andMaxSize:(NSInteger)maxSize isRequired:(BOOL)required;

@end
