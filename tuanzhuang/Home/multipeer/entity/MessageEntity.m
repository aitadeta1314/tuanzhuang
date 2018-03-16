//
//  MessageEntity.m
//  tuanzhuang
//
//  Created by zhuang on 2018/1/24.
//  Copyright © 2018年 red. All rights reserved.
//

#import "MessageEntity.h"
#import "DeviceEntity.h"

@implementation MessageEntity

-(NSData*)createMsg:(NSString*)type s:(NSNumber*)s msg:(id)msg{
    // type （消息类型-类属性） s （0消息发送1消息接收） msg (发送数据)
    NSDictionary* dic = @{@"type":type,@"s":s,@"msg":msg};
    return [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
}

-(void)recieveMsg:(NSData*)data device:(DeviceEntity*)device{
    NSMutableDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString* type = dic[@"type"];
    NSNumber* s = dic[@"s"];
    MultipeerMessageBlock func = [self valueForKey:[NSString stringWithFormat:@"%@_%@",type,s]];
    if(func){
        func(dic,device);
    }
}

@end
