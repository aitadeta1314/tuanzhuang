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
+(NSURLSessionDataTask *)networkWithHost:(NSString *)host andParameters:(NSDictionary *)parameters andSuccess:(void (^)(id))success andFailure:(void (^)(NSError *))failure
{
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLSessionDataTask * datatask = [sessionManager POST:host parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *rootDic = [self dictionaryWithJsonData:responseObject];
        success(rootDic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    
    return datatask;
}

+(NSURLSessionDataTask *)networkWithHost:(NSString *)host andParameters:(NSDictionary *)parameters andFormDatas:(NSDictionary *)formdatas andSuccess:(void (^)(id))success andFailure:(void (^)(NSError *))failure
{
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLSessionDataTask * datatask = [sessionManager POST:host parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSString * name in formdatas) {
            for (NSDictionary * fileDic in [formdatas valueForKey:name]) {
                [formData appendPartWithFileData:[fileDic valueForKey:@"data"] name:name fileName:[fileDic valueForKey:@"filename"] mimeType:@"image/png"];
            }
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    return datatask;
}


@end
