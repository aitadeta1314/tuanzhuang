//
//  Enum.h
//  tuanzhuang
//
//  Created by zhuang on 2017/12/6.
//  Copyright © 2017年 red. All rights reserved.
//

#ifndef Enum_h
#define Enum_h

// multipeer - connection status
typedef enum {
    CONNECT_NO,
    CONNECT_ING,
    CONNECT_YES
}EnumMultipeerStatus;

typedef enum {
    SYNC_NO,//未连接
    SYNC_ING,//连接中
    SYNC_YES//成功
}EnumMultipeerAsyncStatus;

typedef NS_ENUM(NSInteger, KEYBOARDTYPE) {
    KEYBOARDTYPE_WRITINGPAD,         // 手写板
    KEYBOARDTYPE_NUMBER,             // 数字键盘
    KEYBOARDTYPE_NUMBER_SYNCCODE,   // 数字键盘（同步码）
};

/**
 手写键盘类型

 - WRITINGPAD_TYPE_SEARCH: 搜索
 - WRITINGPAD_TYPE_CONFIRM: 确定
 */
typedef NS_ENUM(NSInteger, WRITINGPAD_TYPE) {
    WRITINGPAD_TYPE_SEARCH,
    WRITINGPAD_TYPE_CONFIRM,
};

#pragma mark - master同步界面
/**
 数据录入状态

 - DATAIN_STATUS_WAIT: 待量体
 - DATAIN_STATUS_DOING: 进行中
 - DATAIN_STATUS_DONE: 已完成
 */
typedef NS_ENUM(NSInteger, DATAIN_STATUS) {
    DATAIN_STATUS_WAIT,
    DATAIN_STATUS_DOING,
    DATAIN_STATUS_DONE,
};


/**
 数据重复标识

 - DATA_REPEAT_LOGO_ignore: 数据重复中忽略的数据标识
 - DATA_REPEAT_LOGO_repeat: 数据重复中重复的数据标识
 - DATA_REPEAT_LOGO_no: 数据没有重复标识
 */
typedef NS_ENUM(NSInteger, DATA_REPEAT_LOGO) {
    DATA_REPEAT_LOGO_no = 0,
    DATA_REPEAT_LOGO_ignore,
    DATA_REPEAT_LOGO_repeat,
};

/**
 数据是否可编辑

 - DATA_EDIT_YES: 数据可编辑
 - DATA_EDIT_NO: 数据不可编辑
 */
typedef NS_ENUM(NSInteger, DATA_EDIT) {
    DATA_EDIT_YES = 0,
    DATA_EDIT_NO,
};

#pragma mark -

#endif /* Enum_h */
