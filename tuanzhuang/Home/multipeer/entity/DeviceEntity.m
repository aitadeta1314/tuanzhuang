//
//  DeviceInfo.m
//  tuanzhuang
//
//  Created by zhuang on 2017/12/6.
//  Copyright © 2017年 red. All rights reserved.
//

#import "DeviceEntity.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@implementation DeviceEntity

-(NSString*)connectStatusText{
    switch (_connectStatus) {
        case CONNECT_YES:
            _connectStatusText = @"已建立连接";
            break;
        default:
            _connectStatusText = @"正在建立连接中 . . .";
            break;
    }
    return _connectStatusText;
}

-(NSString *)receiveStatusText{
    switch (_receiveStatus) {
        case SYNC_YES:
            _receiveStatusText = @"已接收";
            break;
        case SYNC_ING:
            _receiveStatusText = @"正在接收";
            break;
        default :
            _receiveStatusText = @"接收未完成";
            break;
    }
    return _receiveStatusText;
}

-(NSString *)syncStatusText{
    switch (_syncStatus) {
        case SYNC_YES:
            _syncStatusText = @"同步成功";
            break;
        case SYNC_ING:
            _syncStatusText = @"正在同步中";
            break;
        default :
            _syncStatusText = @"同步未完成";
            break;
    }
    return _syncStatusText;
}

#pragma mark - 类属性
+(instancetype)create:(MCPeerID*)peer{
    DeviceEntity* newInfo = [[DeviceEntity alloc] init];
    newInfo.name = peer.displayName;
    newInfo.type = @"ipad";
    newInfo.connectStatus = CONNECT_NO;
    newInfo.syncStatus = SYNC_NO;
    newInfo.receiveStatus = SYNC_NO;
    newInfo.peer = peer;
    newInfo.invite = NO;
    return newInfo;
}

+(void)copy:(DeviceEntity*)fromObj to:(DeviceEntity*)toObj{//?
    NSString* name = fromObj.name;
    NSString* type = fromObj.type;
    EnumMultipeerStatus connectStatus = fromObj.connectStatus;
    EnumMultipeerAsyncStatus receiveStatus = fromObj.receiveStatus;
    EnumMultipeerAsyncStatus syncStatus = fromObj.syncStatus;
    //
    toObj.name = name;
    toObj.type = type;
    toObj.connectStatus = connectStatus;
    toObj.receiveStatus = receiveStatus;
    toObj.syncStatus = syncStatus;
}

@end

