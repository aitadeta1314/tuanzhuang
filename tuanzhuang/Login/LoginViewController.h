//
//  LoginViewController.h
//  tuanzhuang
//
//  Created by red on 2017/11/29.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : SuperViewController

@property (nonatomic, strong) NSDictionary * selectUser;/** 选择用户 */
@property (nonatomic, strong) UITextField * companyText;/**  */
@property (nonatomic, strong) UITextField * userNameText;/**  */
@property (nonatomic, strong) UITextField * userPwdText;/**  */
//
-(void) selectUser:(NSDictionary*)one;
-(void) delUserAction:(NSDictionary*)info;

@end
