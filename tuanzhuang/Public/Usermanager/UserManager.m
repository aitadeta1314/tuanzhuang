//
//  UserManager.m
//  tuanzhuang
//
//  Created by red on 2017/11/29.
//  Copyright © 2017年 red. All rights reserved.
//

#import "UserManager.h"

@implementation UserManager
//存储组织、用户名、密码
+(void)saveUser:(NSDictionary*)info{
    [[NSUserDefaults standardUserDefaults] setObject:info forKey:@"user"];
    [UserManager addUser:info];
}

+(void)clearUser{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"user"];
    [defaults removeObjectForKey:@"userList"];
}

//获取用户信息
+(NSString *)getMultiName{
    return [UserManager getUserInfo:@"multiName"];
}

+(NSString *)getName{
    return [UserManager getUserInfo:@"uname"];
}

+(NSString *)getCname{
    return [UserManager getUserInfo:@"cname"];
}

+(NSString *)getUserId{
    return [UserManager getUserInfo:@"userId"];
}

+(NSString *)getOrgId{
    return [UserManager getUserInfo:@"orgId"];
}

+(NSString *)getShowname
{
    return [UserManager getUserInfo:@"showname"];
}

+(NSString *)getToken
{
    return [UserManager getUserInfo:@"token"];
}

+(id)getUserInfo:(NSString*)key{
    NSMutableDictionary * one = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    return [one objectForKey:key];
}

+(void)setUserInfo:(NSString *)key value:(id)val{
    // KEY : syncPlistUrl,multiType
    NSDictionary* dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    NSMutableDictionary * one = [dic copyToDic];
    [one setValue:val forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:one forKey:@"user"];
}

//获取已登录用户信息
+(NSArray *)getLoginUsers:(NSString*)cname{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * arr = [defaults objectForKey:@"userList"];
    NSMutableArray* res = [[NSMutableArray alloc] init];
    if([cname isEqualToString:@""]){
        res = [arr copyToDic];
    }else{
        NSString* uname = [UserManager getUserInfo:@"uname"];
        NSDictionary* one = nil;
        for(int i=0;i<arr.count;i++){
            one = arr[i];
            if([[one objectForKey:@"cname"] isEqualToString:cname]
               && ![[one objectForKey:@"uname"] isEqualToString:uname]){
                [res addObject:one];
            }
        }
    }
    return res;
}

+(NSDictionary*)getLoginUser:(NSString *)cname uname:(NSString *)uname upwd:(NSString *)upwd{
    NSArray* arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"userList"];
    int i = [arr indexToDic:@{@"cname":cname,@"uname":uname}];
    if(i<0){
        return nil;
    }else{
        return arr[i];
    }
}

//列表:保存用户
+(void)addUser:(NSDictionary *)info{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* arr = [defaults objectForKey:@"userList"];
    //
    if(arr==nil){
        arr = [[NSMutableArray alloc] init];
    }
    int index = [arr indexToDic:@{@"cname":[info objectForKey:@"cname"],@"uname":[info objectForKey:@"uname"]}];
    if(index>-1){
        // no-do
    }else{
        NSMutableArray* newArr = [arr copyToDic];
        [newArr addObject:info];
        [defaults setObject:newArr forKey:@"userList"];
    }
}
//列表:删除用户
+(void)delUser:(NSDictionary *)info{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray* arr = [defaults objectForKey:@"userList"];
    NSMutableArray* newArr = [arr copyToDic];
    [newArr removeObject:info];
    [defaults setObject:newArr forKey:@"userList"];
}

@end
