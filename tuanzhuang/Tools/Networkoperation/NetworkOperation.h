//
//  NetworkOperation.h
//
//  Created by jsj on 2017/2/18.
//  Copyright © 2017年 jsj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface NetworkOperation : NSObject

+(NSURLSessionDataTask *)networkWithHost:(NSString *)host andParameters:(NSDictionary *)parameters andSuccess:(void (^) (id rootobject))success andFailure:(void (^) (NSError *error))failure;
+(NSURLSessionDataTask *)networkWithHost:(NSString *)host andParameters:(NSDictionary *)parameters andFormDatas:(NSDictionary *)formdatas andSuccess:(void (^)(id))success andFailure:(void (^)(NSError *))failure;
@end
