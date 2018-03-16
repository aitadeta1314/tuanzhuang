//
//  MessageEntity.h
//  tuanzhuang
//
//  Created by zhuang on 2018/1/24.
//  Copyright © 2018年 red. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceEntity.h"

typedef void (^MultipeerMessageBlock)(NSMutableDictionary* dic,DeviceEntity* device);

@interface MessageEntity : NSObject

@property (nonatomic, copy) MultipeerMessageBlock collectCode_0;/** 同步码消息-发起 */
@property (nonatomic, copy) MultipeerMessageBlock collectCode_1;/** 同步码消息-反馈 */
@property (nonatomic, copy) MultipeerMessageBlock masterCode_0;/** Master状态消息-发起 */
@property (nonatomic, copy) MultipeerMessageBlock masterCode_1;/** Master状态消息-反馈 */
@property (nonatomic, copy) MultipeerMessageBlock subCode_0;/** 同步页面消息-发起 */
@property (nonatomic, copy) MultipeerMessageBlock subCode_1;/** 同步页面消息-反馈 */


-(NSData*)createMsg:(NSString*)type s:(NSNumber*)s msg:(id)msg;
-(void)recieveMsg:(NSData*)data device:(DeviceEntity*)device;

@end
