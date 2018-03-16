//
//  UIViewController+MBProgressHUD.h
//  tuanzhuang
//
//  Created by red on 2017/12/2.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

typedef void(^ConfirmCompleteBlock)(NSInteger index,NSString *title);

@interface UIViewController (MBProgressHUD)<MBProgressHUDDelegate>
//加载成功
-(void)loadSuccess;

-(void)loadSuccessWith:(NSString *)message;

//正在加载
-(void)showLoading;
-(void)showLoadingWith:(NSString *)message;
-(void)showLoadingWith:(NSString *)message  andDelay:(NSTimeInterval)delay;
//显示提示语
-(void)showHUDMessage:(NSString *)message;
-(void)showHUDMessage:(NSString *)message andDelay:(NSTimeInterval)delay;
-(void) tipDialog:(NSString*)title content:(NSString*)msg result:(void(^)(id obj))result;
//加载进度
-(void)showLoadingPress;
-(void)loadingPress:(float)press;
-(void)hideLoading;
// 确认框
-(void) confirmDialog:(NSString*)title content:(NSString*)msg result:(void(^)(NSInteger i,id obj))result;

-(void) confirmDialog:(NSString*)title content:(NSString*)msg confirmTitle:(NSString *)confirmTitle cancelTitle:(NSString *)cancelTitle result:(void(^)(BOOL confirm))result;
@end
