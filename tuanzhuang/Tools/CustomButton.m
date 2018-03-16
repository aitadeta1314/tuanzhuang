//
//  CustomButton.m
//  tuanzhuang
//
//  Created by Fenly on 2017/12/28.
//  Copyright © 2017年 red. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)contentRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.size.width*0.15, (bounds.size.height-bounds.size.width*0.7)/2, bounds.size.width*0.7, bounds.size.width*0.7);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return contentRect;
}

@end
