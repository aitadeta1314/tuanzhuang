//
//  TableRow.h
//  tuanzhuang
//
//  Created by zhuang on 2017/12/19.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat paddingW;
static CGFloat leftImgW;
static CGFloat rightImgW;

@interface TableRow : UIView

@property (nonatomic, strong) UIImageView * leftImgView;/**  */
@property (nonatomic, strong) UILabel * leftText;/**  */
@property (nonatomic, strong) UILabel * rightText;/**  */
@property (nonatomic, strong) UIButton * rightBtn;/**  */
@property (nonatomic, strong) UIView * topLineView;
@property (nonatomic, strong) UIView * bottomLineView;
//
- (TableRow * (^)(NSString* img,NSString* lt, NSString* rt))text;
- (TableRow * (^)(CGFloat w))topLine;
- (TableRow * (^)(CGFloat w))bottomLine;
- (TableRow * (^)(NSString* icon))rightIcon;

@end
