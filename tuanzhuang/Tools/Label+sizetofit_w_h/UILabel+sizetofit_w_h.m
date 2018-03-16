//
//  UILabel+sizetofit_w_h.m
//  CTM
//
//  Created by jsj on 16/4/7.
//  Copyright © 2016年 青岛晨之晖信息服务有限公司. All rights reserved.
//

#import "UILabel+sizetofit_w_h.h"

@implementation UILabel (sizetofit_w_h)
-(void)size_widthToFit
{
    CGFloat height = self.frame.size.height;
    [self sizeToFit];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

-(void)size_heightToFit
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    [self sizeToFit];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height<height?height:self.frame.size.height);
}

@end
