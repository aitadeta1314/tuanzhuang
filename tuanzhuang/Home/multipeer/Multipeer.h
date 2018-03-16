//
//  Multipeer.h
//  tuanzhuang
//
//  Created by zhuang on 2017/12/7.
//  Copyright © 2017年 red. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "DeviceEntity.h"
#import "MessageEntity.h"

typedef void (^MultipeerSyncBackBlock)(NSProgress* progress);
typedef void (^MultipeerRefreshBlock)(void);
typedef void (^MultipeerReceiveBlock)(void);
typedef void (^MultipeerLoseBlock)(DeviceEntity* device,BOOL on);
typedef void (^MultipeerMergeBlock)(NSMutableDictionary* dic);


@interface Multipeer : NSObject<MCSessionDelegate,MCNearbyServiceAdvertiserDelegate,MCNearbyServiceBrowserDelegate>

@property (nonatomic, strong) NSString * currentName;/** 设备名称 */
@property (nonatomic, strong) MCSession* session;
@property (nonatomic, strong) NSMutableArray* list;
@property (nonatomic, strong) MessageEntity* message;/** */
@property (nonatomic, copy) MultipeerSyncBackBlock startSyncBack;/** 数据接收-回调（child：接收下发信息） */
@property (nonatomic, copy) MultipeerReceiveBlock onReceive;/** 数据接收-回调（master：接收整合信息）*/
@property (nonatomic, copy) MultipeerRefreshBlock onRefresh;/** 连接状态-回调 */
@property (nonatomic, copy) MultipeerLoseBlock onLose;/** 连接丢失-回调 */
@property (nonatomic, copy) MultipeerMergeBlock onMerge;/** 数据整合完成-回调 */

// master信息
@property (nonatomic, assign) BOOL isMaster;/** 是否为主设备 */
@property (nonatomic, strong) NSMutableArray* syncList;
@property (nonatomic, strong) NSMutableDictionary* masterMergeDictory;/** 主设备-数据对象 */

// 外部接口
-(NSMutableArray*)start;/** 启动多点连接 */
-(void)end;/** 停止多点连接(同时删除master标示) */
-(void)refreshPeers;/** 刷新并连接所有节点 */
-(void)connectPeers:(DeviceEntity*)info;/** 连接某个节点 */
-(void)resetReceiveStatus;
-(void)resetSyncStatus;
-(void)collectCodeCreateAction:(NSString*)validCode;
-(void)collectCodeValidAction:(DeviceEntity *)device collectCode:(NSString *)validCode result:(void(^)(NSMutableDictionary *dic))result;

/*
 msg类型
 key=10 : 设备发起数据收集
 */
-(void)sendMsg:(DeviceEntity*)device msg:(NSData*)msg;/**发送消息数据*/
-(void)sendData:(DeviceEntity*)device result:(void(^)(NSProgress* progress))result error:(void(^)(NSError* e))err;/**发送文件数据*/
-(void)distributeData:(NSMutableDictionary*)data;/**下发文件数据*/

@end

