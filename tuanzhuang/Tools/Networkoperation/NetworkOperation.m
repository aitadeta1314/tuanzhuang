//
//  NetworkOperation.m
//
//  Created by jsj on 2017/2/18.
//  Copyright © 2017年 jsj. All rights reserved.
//

#import "NetworkOperation.h"

@implementation NetworkOperation

#pragma mark - json解析，过滤特殊字符
+ (NSDictionary *)dictionaryWithJsonData:(NSData *)responseData {
    NSString *jsonString = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r\n" withString: @"" ];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString: @"" ];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\t" withString : @"" ];
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark - 网络请求
/*
    解锁
 */
+ (void)getUnlockWithUrl:(NSString *)url token:(NSString *)token success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    [NetworkOperation getWithUrl:url andToken:token andSuccess:success andFailure:^(NSError *error, NSString *errorMessage) {
        failure(error);
    }];
}

//get方式网络请求
+(NSURLSessionDataTask *)getWithUrl:(NSString *)url andToken:(NSString *)token andSuccess:(void (^)(id))success andFailure:(void (^)(NSError *, NSString *))failure
{
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    if (token.length > 0) {
        [sessionManager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    }
    
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLSessionDataTask * datatask = [sessionManager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *rootDic = [self dictionaryWithJsonData:responseObject];
        if ([[rootDic valueForKey:@"resu"] intValue] == 0) {
            success([rootDic valueForKey:@"result"]);
        } else if ([[rootDic valueForKey:@"resu"] intValue] == 3) {//token过期
            NSError * error;
            failure(error, @"账号过期");
        } else if ([[rootDic valueForKey:@"resu"] intValue] == 4) {//文件不存在
            NSError * error;
            failure(error, @"任务已归档");
        } else {
            NSError * error;
            failure(error, [[rootDic valueForKey:@"warningMessages"] firstObject]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error, @"网络异常");
    }];
    
    return datatask;
}

//post方式网络请求
+(NSURLSessionDataTask *)postWithHost:(NSString *)host andToken:(NSString *)token andType:(requestType)type andParameters:(NSDictionary *)parameters andSuccess:(void (^) (id rootobject))success andFailure:(void (^) (NSError *error, NSString * errorMessage))failure
{
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    if (type == JSONOBJECT) {
        sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    if (token.length > 0) {
        [sessionManager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    }
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLSessionDataTask * datatask = [sessionManager POST:host parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *rootDic = [self dictionaryWithJsonData:responseObject];
        if ([[rootDic valueForKey:@"resu"] intValue] == 0) {
            success([rootDic valueForKey:@"result"]);
        } else if ([[rootDic valueForKey:@"resu"] intValue] == 3) {//token过期
            NSError * error;
            failure(error, @"账号过期");
        } else if ([[rootDic valueForKey:@"resu"] intValue] == 4) {//文件不存在
            NSError * error;
            failure(error, @"任务已归档");
        } else {
            NSError * error;
            failure(error, [[rootDic valueForKey:@"warningMessages"] firstObject]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error, @"网络异常");
    }];
    
    return datatask;
}

//上传数据网络请求
+(NSURLSessionDataTask *)networkWithHost:(NSString *)host andToken:(NSString *)token andParameters:(NSDictionary *)parameters andFormDatas:(NSDictionary *)formdatas andSuccess:(void (^)(id rootobject))success andProgress:(void (^)(float percentage))progress andFailure:(void (^)(NSError *, NSString *))failure
{
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    if (token.length > 0) {
        [sessionManager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    }
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLSessionDataTask * datatask = [sessionManager POST:host parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSString * name in formdatas) {
            for (NSDictionary * fileDic in [formdatas valueForKey:name]) {
                [formData appendPartWithFileData:[fileDic valueForKey:@"data"] name:name fileName:[fileDic valueForKey:@"filename"] mimeType:@"image/png"];
            }
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress.completedUnitCount*1.0/uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *rootDic = [self dictionaryWithJsonData:responseObject];
        if ([[rootDic valueForKey:@"resu"] intValue] == 0) {
            success([rootDic valueForKey:@"result"]);
        }if ([[rootDic valueForKey:@"resu"] intValue] == 0) {
            success([rootDic valueForKey:@"result"]);
        } else if ([[rootDic valueForKey:@"resu"] intValue] == 3) {//token过期
            NSError * error;
            failure(error, @"账号过期");
        } else if ([[rootDic valueForKey:@"resu"] intValue] == 4) {//文件不存在
            NSError * error;
            failure(error, @"任务已归档");
        } else {
            NSError * error;
            failure(error, [[rootDic valueForKey:@"warningMessages"] firstObject]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error, @"网络异常");
    }];
    return datatask;
}

#pragma mark -- 检测是否有新版本
+(void)checkversionWithAppid:(NSString *)appid andResult:(void (^)(BOOL))result
{
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [sessionManager POST:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",appid] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //本地app信息
        NSDictionary * infoDic = [[NSBundle mainBundle] infoDictionary];
        //本地版本号
        NSString * currentVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
        //获取苹果商店最新的版本信息
        NSDictionary * rootDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray *infoArray = [rootDic objectForKey:@"results"];
        if (infoArray.count) {
            NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
            //苹果商店最新版本号
            NSString *lastVersion = [releaseInfo objectForKey:@"version"];
            if ([lastVersion floatValue] > [currentVersion floatValue]) {
                result(YES);
                return;
            }
        }
        result(NO);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        result(NO);
    }];
}

@end
