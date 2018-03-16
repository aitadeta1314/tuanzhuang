//
//  ZZNumberField.h
//  NumKeyBoard
//
//  Created by zm on 2016/11/21.
//  Copyright © 2016年 zmMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enum.h"
@class ZZNumberField;

@protocol ZZNumberFieldDelegate <NSObject>

@optional
- (void)didClickedAffirm:(ZZNumberField *)field;
/**
 搜索功能
 */
- (void)didSearchClicked;
/**
 监听同步码键盘删除按钮点击
 */
- (void)monitorSyncCodeKeyboardDeleteClick:(ZZNumberField *)field;

@end


@interface ZZNumberField : UITextField

@property (nonatomic, weak) id <ZZNumberFieldDelegate>numDelegate;

/**
 *  键盘类型
 */
@property (nonatomic, assign) KEYBOARDTYPE keyboard;
/**
 * 手写板键盘类型
 */
@property (nonatomic, assign) WRITINGPAD_TYPE writingPadType;

@end

@interface ZZNumericInputView : UIView <UIInputViewAudioFeedback, UITextFieldDelegate,UITextViewDelegate>

{
    __unsafe_unretained ZZNumberField *activeField;
}
+ (ZZNumericInputView *)sharedInputView;


/**
 * 键盘的类型
 */
@property (nonatomic, assign) KEYBOARDTYPE customKeyboardType;
/**
 * 手写板键盘类型
 */
@property (nonatomic, assign) WRITINGPAD_TYPE customWritingPadType;

/**
 *  按钮添加的bgView  用于切换键盘是隐藏跟显示的
 */
@property (nonatomic, strong) UIView *bgView;

/**
 *  手写板背景imgView  用户切换键盘隐藏跟显示的
 */
@property (nonatomic, strong) UIImageView *padImgView;
/**
  同步码数字键盘背景
 */
@property (nonatomic, strong) UIView *syncBGView;

@end
