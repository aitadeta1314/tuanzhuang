//
//  NetworkOperation.h
//
//  Created by jsj on 2017/2/18.
//  Copyright © 2017年 jsj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
typedef enum {
    JSONOBJECT = 0,/**<json对象*/
    JSONSTRING,/**<json字符串*/
}requestType;

@interface NetworkOperation : NSObject

/*
 解锁
 */
+ (void)getUnlockWithUrl:(NSString *)url token:(NSString *)token success:(void (^)(id object))success failure:(void (^) (NSError *error))failure;

//get方式网络请求
+(NSURLSessionDataTask *)getWithUrl:(NSString *)url andToken:(NSString *)token andSuccess:(void (^) (id rootobject))success andFailure:(void (^) (NSError *error, NSString * errorMessage))failure;

//post方式网络请求
+(NSURLSessionDataTask *)postWithHost:(NSString *)host andToken:(NSString *)token andType:(requestType)type andParameters:(NSDictionary *)parameters andSuccess:(void (^) (id rootobject))success andFailure:(void (^) (NSError *error, NSString * errorMessage))failure;

//上传数据网络请求
+(NSURLSessionDataTask *)networkWithHost:(NSString *)host andToken:(NSString *)token andParameters:(NSDictionary *)parameters andFormDatas:(NSDictionary *)formdatas andSuccess:(void (^)(id rootobject))success andProgress:(void (^)(float percentage))progress andFailure:(void (^)(NSError *error, NSString * errorMessage))failure;

//检查APP版本
+(void)checkversionWithAppid:(NSString *)appid andResult:(void (^)(BOOL))result;
@end
