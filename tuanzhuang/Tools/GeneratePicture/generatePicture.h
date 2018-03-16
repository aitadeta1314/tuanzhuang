//
//  generatePicture.h
//  tuanzhuang
//
//  Created by red on 2017/12/13.
//  Copyright © 2017年 red. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface generatePicture : NSObject
//将view生成image图片
+(UIImage *)generateImageOfView:(UIView *)view;
//将view生成image data
+(NSData *)generateImageDataOfView:(UIView *)view;

@end
