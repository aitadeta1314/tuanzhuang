//
//  LabelCollectionViewCell.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/11.
//  Copyright © 2018年 red. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TEXT_BACKGROUND_COLOR_SELECTED RGBColor(24, 175, 229)

typedef NS_ENUM(NSUInteger, LabelCollectionViewCellStyle) {
    LabelCollectionViewCellStyle_Normal = 0,
    LabelCollectionViewCellStyle_Selected = 1
};

typedef void(^LabelBySelectedBlock)(BOOL selected,UILabel *label);


@interface LabelCollectionViewCell : UICollectionViewCell

@property(nonatomic,strong) UILabel *titleLabel;

@property(nonatomic,assign) LabelCollectionViewCellStyle style;

@property(nonatomic,strong) LabelBySelectedBlock labelBySelectedBlock;

@end
