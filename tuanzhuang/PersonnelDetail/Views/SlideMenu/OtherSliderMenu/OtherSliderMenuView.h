//
//  OtherSliderMenuView.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/8.
//  Copyright © 2018年 red. All rights reserved.
//

#import "CustomSlideMenuView.h"

typedef NS_ENUM(NSUInteger, SLIDER_BUTTON_ITEM_TYPE) {
    SLIDER_BUTTON_ITEM_TYPE_COPY = 200,
    SLIDER_BUTTON_ITEM_TYPE_PASTER,
    SLIDER_BUTTON_ITEM_TYPE_COPY_OTHER,
    SLIDER_BUTTON_ITEM_TYPE_HISTORY ,
    SLIDER_BUTTON_ITEM_TYPE_REMARK,
    SLIDER_BUTTON_ITEM_TYPE_SIGNED,
    SLIDER_BUTTON_ITEM_TYPE_CANCEL_PASTER   //撤销粘贴
};

typedef void(^MenuButtonTapBlock)(SLIDER_BUTTON_ITEM_TYPE type);

IB_DESIGNABLE
@interface OtherSliderMenuView : CustomSlideMenuView

@property(nonatomic,assign) BOOL showCancelButton;

@property(nonatomic,copy) MenuButtonTapBlock tapBlock;


@end
