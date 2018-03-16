//
//  signView.h
//  tuanzhuang
//
//  Created by red on 2017/12/15.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface signView : UIImageView

@property (nonatomic, assign, readonly) BOOL editing;/**<正在编辑*/
@property (nonatomic, assign, readonly) BOOL cleared;/**<是否已被清空*/

//写字
- (void)write;
//擦除
- (void)erase;
//清空
- (void)clearImage;
@end
