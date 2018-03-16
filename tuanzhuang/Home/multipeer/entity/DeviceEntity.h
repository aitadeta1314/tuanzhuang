//
//  DeviceInfo.h
//  tuanzhuang
//
//  Created by zhuang on 2017/12/6.
//  Copyright © 2017年 red. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface DeviceEntity : NSObject

@property (strong,nonatomic) NSString* name;
@property (strong,nonatomic) NSString* type;
@property (nonatomic, assign) EnumMultipeerStatus connectStatus;
@property (nonatomic, assign) NSString* connectStatusText;
@property (nonatomic, assign) EnumMultipeerAsyncStatus receiveStatus;
@property (nonatomic, assign) NSString* receiveStatusText;
@property (nonatomic, assign) EnumMultipeerAsyncStatus syncStatus;
@property (nonatomic, assign) NSString* syncStatusText;
@property (nonatomic, strong) MCPeerID* peer;
//
@property (nonatomic, assign) BOOL invite;


// 类属性
+(instancetype)create:(MCPeerID*)peer;
+(void)copy:(DeviceEntity*)fromObj to:(DeviceEntity*)toObj;
@end
