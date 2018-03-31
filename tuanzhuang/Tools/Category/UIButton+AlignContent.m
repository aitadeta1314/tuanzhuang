//
//  UIButton+AlignContent.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/9.
//  Copyright © 2018年 red. All rights reserved.
//

#import "UIButton+AlignContent.h"
#import <objc/runtime.h>

@implementation UIButton (AlignContent)

- (void)centerImageAndTitle:(float)spacing
{
    
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    // get the size of the elements here for readability
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    
    // get the height they will take up as a unit
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);

    // raise the image and push it right to center it
    self.imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight - imageSize.height), self.frame.size.width/2 - (imageSize.width/2), 0.0, 0.0);

    
    
    // lower the text and push it left to center it
    CGFloat _paddingLeft = -imageSize.width + (self.frame.size.width/2 - (titleSize.width/2));
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, _paddingLeft, -(totalHeight - titleSize.height), 0.0);
}

- (void)centerImageAndTitle
{
    const int DEFAULT_SPACING = 6.0f;
    [self centerImageAndTitle:DEFAULT_SPACING];
}

/**
 *  设置部分圆角(绝对布局)
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii
                color:(UIColor *)borderColor {
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:radii];
    CAShapeLayer *temp = [CAShapeLayer layer];
    temp.lineWidth = 0.8f;
    temp.fillColor = [UIColor clearColor].CGColor;
    temp.strokeColor = borderColor.CGColor;
    temp.frame = self.bounds;
    temp.path = rounded.CGPath;
    [self.layer addSublayer:temp];
    
    CAShapeLayer *mask = [[CAShapeLayer alloc] initWithLayer:temp];
    mask.path = rounded.CGPath;

    self.layer.mask = mask;
}

/**
 *  设置部分圆角(相对布局)
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 *  @param rect    需要设置的圆角view的rect
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii
                 viewRect:(CGRect)rect {
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:radii];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    self.layer.mask = shape;
}


@end
