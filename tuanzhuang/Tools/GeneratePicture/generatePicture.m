//
//  generatePicture.m
//  tuanzhuang
//
//  Created by red on 2017/12/13.
//  Copyright © 2017年 red. All rights reserved.
//

#import "generatePicture.h"

@implementation generatePicture
+(UIImage *)generateImageOfView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSString* docDir = [NSString stringWithFormat:@"%@/Documents/Image", NSHomeDirectory()];
    [[NSFileManager defaultManager] createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *path = [NSString stringWithFormat:@"%@/Documents/Image/IMAGE.PNG", NSHomeDirectory()];
    
    //用png是透明的
    [UIImagePNGRepresentation(image) writeToFile: path atomically:YES];
    
    return image;
}

+(NSData *)generateImageDataOfView:(UIView *)view
{
    return UIImagePNGRepresentation([self generateImageOfView:view]);
}
@end
