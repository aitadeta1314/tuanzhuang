//
//  UIViewController+MBProgressHUD.m
//  tuanzhuang
//
//  Created by red on 2017/12/2.
//  Copyright © 2017年 red. All rights reserved.
//

#import "UIViewController+MBProgressHUD.h"

static const CGFloat zPostion = 999999;

MBProgressHUD *HUD;

@implementation UIViewController (MBProgressHUD)

//加载成功提示
-(void)loadSuccess
{
    [self loadSuccessWith:@"加载成功"];
}

-(void)loadSuccessWith:(NSString *)message
{
    if (HUD) {
        [HUD removeFromSuperview];
    }
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    UIImage * image = [[UIImage imageNamed:@"success.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    HUD.customView = [[UIImageView alloc] initWithImage:image];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.layer.zPosition = zPostion;
    HUD.labelText = message;
    [HUD hide:YES afterDelay:1.3];
}

//显示正在加载提示
-(void)showLoading
{
    [self showLoadingWith:@"正在加载..."];
}

-(void)showLoadingWith:(NSString *)message
{
    [self showLoadingWith:message andDelay:-1];
}

-(void)showLoadingWith:(NSString *)message  andDelay:(NSTimeInterval)delay
{
    if (HUD) {
        [HUD removeFromSuperview];
    }
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.labelText = message;
    HUD.layer.zPosition = zPostion;
    if (delay<0) {
        [HUD show:YES];
    } else {
        [HUD hide:YES afterDelay:delay];
    }
}

//显示提示语
-(void)showHUDMessage:(NSString *)message
{
    [self showHUDMessage:message andDelay:1.0];
}

-(void)showHUDMessage:(NSString *)message andDelay:(NSTimeInterval)delay
{
    if (HUD) {
        [HUD removeFromSuperview];
    }
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = message;
    HUD.removeFromSuperViewOnHide = YES;
    HUD.layer.zPosition = zPostion;
    [HUD hide:YES afterDelay:delay];
}

-(void) tipDialog:(NSString*)title content:(NSString*)msg result:(void(^)(id obj))result{
    UIAlertController* vc = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        result(@"确定");
    }]];
    [self presentViewController:vc animated:YES completion:^{}];
}

//显示加载进度条
-(void)showLoadingPress
{
    if (HUD) {
        [HUD removeFromSuperview];
    }
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
    HUD.layer.zPosition = zPostion;
    [HUD show:YES];
}
//设置加载进度
-(void)loadingPress:(float)press
{
    HUD.progress = press;
}

//隐藏加载框
-(void)hideLoading
{
    if (HUD!=nil) {
        [HUD hide:YES];
    }
}

// 确认框
-(void) confirmDialog:(NSString*)title content:(NSString*)msg result:(void(^)(NSInteger i,id obj))result{
    UIAlertController* vc = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        result(0,@"取消");
    }]];
    [vc addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        result(1,@"确定");
    }]];
    [self presentViewController:vc animated:YES completion:^{}];
}

-(void) confirmDialog:(NSString*)title content:(NSString*)msg confirmTitle:(NSString *)confirmTitle cancelTitle:(NSString *)cancelTitle result:(void(^)(BOOL confirm))result{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        result(NO);
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        result(YES);
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
