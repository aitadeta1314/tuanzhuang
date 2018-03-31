//
//  UserManager.h
//  tuanzhuang
//
//  Created by red on 2017/11/29.
//  Copyright © 2017年 red. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserManager : NSObject

//组织、用户名、密码
+(void)saveUser:(NSDictionary*)info;
+(void)clearUser;
//获取用户信息
+(id)getUserInfo:(NSString*)key;
+(void)setUserInfo:(NSString *)key value:(id)val;
+(NSString *)getMultiName;
+(NSString *)getName;
+(NSString *)getCname;
+(NSString *)getUserId;
+(NSString *)getOrgId;
+(NSString *)getToken;
+(NSString *)getShowname;
//获取已登录用户信息
+(NSArray *)getLoginUsers:(NSString*)cname;
+(NSDictionary*)getLoginUser:(NSString *)cname uname:(NSString *)uname upwd:(NSString *)upwd;
//用户列表
+(void)addUser:(NSDictionary *)info;
+(void)delUser:(NSDictionary *)info;

@end
