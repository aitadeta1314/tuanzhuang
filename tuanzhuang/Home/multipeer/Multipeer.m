//
//  Multipeer.m
//  tuanzhuang
//
//  Created by zhuang on 2017/12/7.
//  Copyright © 2017年 red. All rights reserved.
//

#import "Multipeer.h"
#import "DeviceEntity.h"
#import "MessageEntity.h"
#import "SynCodeView.h"

static CGFloat collectDate = 1;
static NSString* SERVICE_TYPE = @"RCserviceType";
static Multipeer* instance = nil;// 永存不休

@interface Multipeer()

// multipeer
@property (nonatomic, strong) MCNearbyServiceBrowser *nearbyServiceBrowser;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *assistant;
@property (nonatomic, strong) MCPeerID* peerID;
@property (nonatomic, assign) MCSessionState state;

@end

@implementation Multipeer

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

-(instancetype)init{
    self = [super init];
    [self message];
    return self;
}

-(NSString *)currentName{
    if(!_currentName){
        _currentName = [NSString stringWithFormat:@"%@(%@)",[UserManager getUserInfo:@"uname"],[SynCodeView randomString]];
    }
    return _currentName;
}

-(NSMutableArray *)list{
    if(!_list){
        _list = [[NSMutableArray alloc] init];
    }
    return _list;
}

-(NSMutableArray *)syncList{
    if(!_syncList){
        _syncList = [[NSMutableArray alloc] init];
    }
    return _syncList;
}

-(void)setIsMaster:(BOOL)isMaster{
    if(!isMaster){// 取消master身份
        _masterMergeDictory = nil;
        [self sendMsg:nil msg:[_message createMsg:@"masterCode" s:@1 msg:@1]];// 回复消息
        [self.syncList removeAllObjects];
    }
    _isMaster = isMaster;
}

-(MessageEntity *)message{
    if(!_message){
        _message = [[MessageEntity alloc] init];
        weakObjc(self);
        _message.collectCode_0 = ^(NSMutableDictionary *dic, DeviceEntity *device){
            NSString* code = [UserManager getUserInfo:@"collectCode"];
            NSNumber* s = [code isEqualToString:dic[@"msg"]] ? @1 : @0;
            [weakself sendMsg:device msg:[weakself.message createMsg:@"collectCode" s:@1 msg:s]];
        };
        _message.masterCode_0 = ^(NSMutableDictionary *dic, DeviceEntity *device){
            if(!weakself.isMaster){
                [weakself sendMsg:device msg:[weakself.message createMsg:@"masterCode" s:@1 msg:@""]];// 回复消息
            }
        };
        _message.subCode_1 = ^(NSMutableDictionary *dic, DeviceEntity *device){
            if(weakself.isMaster && ![dic[@"msg"] isEqualToString:@""]){
                DeviceEntity* one = [weakself searchArrayObj:weakself.syncList name:device.name];
                [weakself.syncList removeObject:one];
                [weakself refreshViewBlock];
            }
        };
    }
    return _message;
}

#pragma mark - action
-(NSMutableArray*)start{
    if(_session==nil){
        SERVICE_TYPE = [UserManager getUserInfo:@"multiType"];
        // 创建会话
        NSLog(@"(multipeer)----%@---",self.currentName);
        self.peerID = [[MCPeerID alloc] initWithDisplayName:self.currentName];
        self.session = [[MCSession alloc] initWithPeer:self.peerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
        self.session.delegate = self;
        // 广播
        self.assistant = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID discoveryInfo:nil serviceType:SERVICE_TYPE];
        self.assistant.delegate = self;
        [self.assistant startAdvertisingPeer];
        // 监听
        self.nearbyServiceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID serviceType:SERVICE_TYPE];
        self.nearbyServiceBrowser.delegate = self;
        [self.nearbyServiceBrowser startBrowsingForPeers];
    }
    //
    [self collectCodeInitAction];
    return self.list;
}

-(void)end{
    self.nearbyServiceBrowser.delegate = nil;
    [self.nearbyServiceBrowser stopBrowsingForPeers];
    [self setNearbyServiceBrowser:nil];
    self.assistant.delegate = nil;
    [self.assistant stopAdvertisingPeer];
    [self setAssistant:nil];
    self.session.delegate = nil;
    [self.session disconnect];
    [self setSession:nil];
    [self setIsMaster:NO];
    [self.list removeAllObjects];
}

-(void)refreshPeers{
    DeviceEntity* device = nil;
    NSArray* arr = [self.session connectedPeers];
    for(int i=0; i<arr.count; i++){
        device = [self getDevice:arr[i]];
        device.connectStatus = CONNECT_YES;
    }
    for(int j=0; j<_list.count; j++){
        device = _list[j];
        if(device.connectStatus != CONNECT_YES){
            [self connectPeers:device];
        }
    }
    [self refreshViewBlock];
}

-(void)refreshSyncPeers{
    DeviceEntity* device = nil;
    [self.syncList removeAllObjects];
    for(int i=0;i<_list.count;i++){
        device = _list[0];
        if(device.syncStatus!=SYNC_NO){
            [self.syncList addObject:device];
        }
    }
}

-(void)connectPeers:(DeviceEntity*)device{
    if(device.peer!=nil && !device.invite){
        NSLog(@"设备同步(向%@发起邀请) ",device.name);
        device.invite = YES;
        NSData* data = nil;
        [self.nearbyServiceBrowser invitePeer:device.peer toSession:_session withContext:data timeout:300];
    }
}

/*
 数据接收时，还原接收数据状态为接收中
 */
-(void)resetReceiveStatus{
    DeviceEntity* device = nil;
    for(int j=0; j<_list.count; j++){
        device = _list[j];
        device.receiveStatus = SYNC_NO;
    }
}
/*
 数据发送时，还原同步数据状态为发送中
 */
-(void)resetSyncStatus{
    DeviceEntity* device = nil;
    for(int j=0; j<_list.count; j++){
        device = _list[j];
        device.syncStatus = SYNC_NO;
    }
}

/*
 同步码
 */
-(void)collectCodeCreateAction:(NSString*)validCode{
    NSDate* nowDate = [NSDate date];
    NSTimeInterval interval =24*60*60*collectDate; //1:天数
    NSDate* tDate = [nowDate initWithTimeIntervalSinceNow:+interval];
    [UserManager setUserInfo:@"collectCodeDate" value:tDate];
    [UserManager setUserInfo:@"collectCode" value:validCode];
}

-(void)collectCodeValidAction:(DeviceEntity *)device collectCode:(NSString *)validCode result:(void(^)(NSMutableDictionary *dic))result{
    NSLog(@"同步码验证请求");
    [self sendMsg:device msg:[_message createMsg:@"collectCode" s:@0 msg:validCode]];
    _message.collectCode_1 = ^(NSMutableDictionary *dic, DeviceEntity *device){
        result(dic);
    };
}

/*
 同步码：验证
 */
-(void)collectCodeInitAction{
    [UserManager setUserInfo:@"collectCodeDate" value:0];
    [UserManager setUserInfo:@"collectCode" value:@""];
}

#pragma mark - block
-(void)sortViewBlock{
    // 排序
//    DeviceEntity* pre = nil;
//    DeviceEntity* now = nil;
//    int len = [[NSNumber numberWithFloat:_list.count] intValue];// 当前位置
//    for(int i=1;i<len;i++){
//        pre = _list[i];
//        for(int j=i-1;j>-1;j--){
//            now = _list[j];
//            if([self sortViewBlock_Max:pre.name str:now.name]){// 大
//                [_list exchangeObjectAtIndex:i withObjectAtIndex:j];
//            }else{
//                break;
//            }
//        }
//    }
    if(self.onRefresh){
        self.onRefresh();
    }
}

-(BOOL)sortViewBlock_Max:(NSString*)s1 str:(NSString*)s2{
    BOOL res = NO;
    long len = [s1 length];
    for(long i=0;i<len;i++){
        if([s1 characterAtIndex:i]>[s2 characterAtIndex:i]){
            res = YES;
            break;
        }
    }
    return res;
}

-(void)refreshViewBlock{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.onRefresh){
            self.onRefresh();
        }
    });
}

-(void)onMergeBlock:(NSMutableDictionary*)dic{
    if(self.onMerge){
        self.onMerge(dic);
    }
}

-(void)receiveViewBlock{
    if(self.onReceive){
        self.onReceive();
    }
}

-(void)onLoseBlock:(DeviceEntity*)device on:(BOOL)on{
    if(self.onLose){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.onLose(device,on);
        });
    }
}

//


#pragma mark - <MCSessionDelegate,MCNearbyServiceBrowserDelegate,MCNearbyServiceAdvertiserDelegate,MCAdvertiserAssistantDelegate>
- (void)session:(nonnull MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(nullable NSURL *)localURL withError:(nullable NSError *)error {
    NSLog(@"数据接收结束");
    dispatch_async(dispatch_get_main_queue(), ^{
        // 获取同步数据
        NSDictionary* dic = [[NSDictionary alloc] initWithContentsOfFile:[localURL relativePath]];
        if(![resourceName isValidByRegex:@"^dispatch"]){
            [self receiveDataAction:localURL peerID:peerID];
            // 合并-存储
            if(_masterMergeDictory==nil){
                _masterMergeDictory = (NSMutableDictionary*)[[NSDictionary alloc] initWithContentsOfFile:[UserManager getUserInfo:@"syncPlistUrl"]];
            }
            // 合并-返回
            [self onMergeBlock:(NSMutableDictionary*)[SynchronizeData handleMasterDic:_masterMergeDictory andSlaveDic:dic]];
            _masterMergeDictory = (NSMutableDictionary*)[SynchronizeData mergeMasterDic:_masterMergeDictory andSlaveDic:dic];
        }else{//startSyncBack
            [SynchronizeData createSyncFile:(NSMutableDictionary*)dic];
            [SynchronizeData handleMasterDataWithFileUrl:localURL];
            [SynchronizeData multiUpdateModel];
        }
        // 删除文件
        [[NSFileManager defaultManager] removeItemAtPath:[localURL relativePath] error:nil];
    });
}

- (void)session:(nonnull MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_message recieveMsg:data device:[self getDevice:peerID]];
    });
}

- (void)session:(nonnull MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(nonnull MCPeerID *)peerID {
    NSLog(@"数据接收-stream");
}

- (void)session:(nonnull MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(nonnull NSProgress *)progress {
    NSLog(@"数据接收开始:%@",resourceName);
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        if(![resourceName isValidByRegex:@"^dispatch"]){
            self.isMaster = YES;
            //
            DeviceEntity* device = [self getDevice:peerID];
            device.receiveStatus = SYNC_ING;
            [self addSyncDevice:device];
            [self refreshViewBlock];
        }
        //
        if(self.isMaster){// 跳到接收页
            [self receiveViewBlock];
        }else{
            if(self.startSyncBack){
                self.startSyncBack(progress);
            }
        }
    });
}

- (void)session:(nonnull MCSession *)session peer:(nonnull MCPeerID *)peerID didChangeState:(MCSessionState)state {
    DeviceEntity* device = [self getDevice:peerID];
    switch (state) {
        case MCSessionStateNotConnected://未连接
        {
            NSLog(@"设备未连接");
            [self downline:peerID];
            [self connectPeers:device];
            break;
        }
        case MCSessionStateConnecting://连接中
        {
            NSLog(@"设备连接中");
            break;
        }
        case MCSessionStateConnected://连接完成
        {
            NSLog(@"设备连接OK");
            [self online:peerID];
            [self onLoseBlock:device on:NO];
            break;
        }
    }
}

- (void)advertiser:(nonnull MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(nullable NSData *)context invitationHandler:(nonnull void (^)(BOOL, MCSession * _Nullable))invitationHandler {
    NSLog(@"设备收到连接请求: %@", peerID.displayName);
    invitationHandler(YES, self.session);// 自动接受
    if([self searchConnectPeers:peerID]){
        [self online:peerID];
    }else{
        DeviceEntity* device = [self getDevice:peerID];
        [self connectPeers:device];
    }
}

-(void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler{
    certificateHandler(YES);
}

- (void)browser:(nonnull MCNearbyServiceBrowser *)browser foundPeer:(nonnull MCPeerID *)peerID withDiscoveryInfo:(nullable NSDictionary<NSString *,NSString *> *)info {
    NSLog(@"设备发现: %@", peerID.displayName);
    if([self searchConnectPeers:peerID]){
        [self online:peerID];
    }else{
        DeviceEntity* device = [self getDevice:peerID];
        [self connectPeers:device];
    }
}

- (void)browser:(nonnull MCNearbyServiceBrowser *)browser lostPeer:(nonnull MCPeerID *)peerID {
    NSLog(@"设备断开: %@", peerID.displayName);
    dispatch_async(dispatch_get_main_queue(), ^{
        DeviceEntity* device = [self offline:peerID];
        [self onLoseBlock:device on:YES];
    });
}

#pragma mark - MESSAGE
-(void)messageSubCode0:(DeviceEntity*)device{
    if([self isMaster]){
        [self sendMsg:device msg:[_message createMsg:@"subCode" s:@0 msg:@""]];
    }
}

#pragma mark - 数据传输处理过程
-(void)sendMsg:(DeviceEntity*)device msg:(NSData*)msg{
    NSError* err = nil;
    if(![self searchConnectPeers:device.peer]){// 发消息前 ：发现设备未连接-重连
        [self connectPeers:device];
    }
    if(device==nil){
        [_session sendData:msg toPeers:[self getAllPeers] withMode:MCSessionSendDataReliable error:&err];
    }else{
        [_session sendData:msg toPeers:@[device.peer] withMode:MCSessionSendDataReliable error:&err];
    }
}

-(void)sendData:(DeviceEntity*)device result:(void(^)(NSProgress* progress))result error:(void(^)(NSError* e))err{
    NSURL* filePath = [NSURL fileURLWithPath:[UserManager getUserInfo:@"syncPlistUrl"]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:[filePath relativePath]]){
        err([[NSError alloc] initWithDomain:NSMachErrorDomain code:1 userInfo:@{NSURLErrorKey:@"文件不存在！"}]);
        return;
    }
    //
    NSProgress* progress = [_session sendResourceAtURL:filePath withName:[filePath lastPathComponent] toPeer:device.peer withCompletionHandler:^(NSError * e) {
        if(e!=nil){
            NSLog(@"ERROR-发送: - %@ -",[e description]);
            err(e);
        }
    }];
    result(progress);
    //
}

-(void)distributeData:(NSMutableDictionary*)data{
    NSURL* filePath = [SynchronizeData createSyncFile:data];
    if(_masterMergeDictory == nil || filePath == nil){
        NSLog(@"--异常--:分发数据不存在！");
        return;
    }
    [SynchronizeData handleMasterDataWithFileUrl:filePath];
    //
    DeviceEntity* device = nil;
    NSProgress* progress = nil;
    for(int i=0;i<_syncList.count;i++){
        device = _syncList[i];
        if([_session.connectedPeers containsObject:device.peer]){//TODO device.connectStatus==CONNECT_YES
            device.syncStatus = SYNC_ING;
            NSLog(@"分发设备 : %d - %@",i,device.name);
            // LOGIC-发送出去：展示为成功
            progress = [_session sendResourceAtURL:filePath withName:@"dispatch" toPeer:device.peer withCompletionHandler:^(NSError * e) {}];
            [progress addObserver:self forKeyPath:@"fractionCompleted" options:(NSKeyValueObservingOptionNew) context:(void *)device.name];
        }
    }
    [SynchronizeData multiUpdateModel];
    [self refreshViewBlock];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    //获取观察的新值
    NSString* name = (__bridge id) context;
    if(!name){
        return;
    }
    //
    DeviceEntity* device = [self searchArrayObj:_syncList name:name];
    if(device){
        CGFloat value = [change[NSKeyValueChangeNewKey] doubleValue];
        if(1==value){
            NSLog(@"给--%@--分发文件",device.name);
            device.syncStatus = SYNC_YES;
            [self refreshViewBlock];
        }
    }
}

-(void)receiveDataAction:(NSURL*)filePath peerID:(MCPeerID*)peerID{
    NSArray* arr = [NSArray arrayWithContentsOfURL:filePath];
    NSLog(@"接收到数据：--%@--",arr);
    DeviceEntity* device = [self getDevice:peerID];
    device.receiveStatus = SYNC_YES;
    // receive
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(receiveDataAction_Receive:) userInfo:device repeats:NO];
}

-(void)receiveDataAction_Receive:(NSTimer*)timer{
    DeviceEntity* device = [timer userInfo];
    device.receiveStatus = SYNC_YES;
    [self refreshViewBlock];
}

-(void)receiveDataAction_Sync:(NSTimer*)timer{
    DeviceEntity* device = [timer userInfo];
    device.syncStatus = SYNC_YES;
    [self refreshViewBlock];
}

-(NSString*)filePath:(NSString*)name{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docPath stringByAppendingPathComponent:name];
}

#pragma mark - self
-(DeviceEntity*)online:(MCPeerID*)peerID{
    DeviceEntity* device = [self getDevice:peerID];
    NSLog(@"上线：- %@ - ",peerID.displayName);
    device.peer = peerID;
    device.connectStatus = CONNECT_YES;
    [self refreshViewBlock];
    [self messageSubCode0:device];
    return device;
}

-(DeviceEntity*)downline:(MCPeerID*)peerID{
    DeviceEntity* device = [self getDevice:peerID];
    NSLog(@"下线：- %@ - ",peerID.displayName);
    device.connectStatus = CONNECT_ING;
    device.invite = NO;
    [self refreshViewBlock];
    return device;
}

-(DeviceEntity*)offline:(MCPeerID*)peerID{
    DeviceEntity* device = [self getDevice:peerID];
    NSLog(@"断线：- %@ - ",peerID.displayName);
    device.connectStatus = CONNECT_NO;
    device.invite = NO;
    [_list removeObject:device];
    [self refreshViewBlock];
    return device;
}

-(DeviceEntity*)getDevice:(MCPeerID*)peerID{
    DeviceEntity* device = [self searchArrayObj:_list name:peerID.displayName];
    if(![peerID.displayName isEqualToString:_currentName] && device == nil){// 设备不存在：创建新对象
        device = [DeviceEntity create:peerID];
        [_list addObject:device];
        [self updateSyncDevice:device];// 重新上线更新同步列表
        [self refreshViewBlock];
    }
    return device;
}

-(void)addSyncDevice:(DeviceEntity*)device{
    int i = [self searchArrayIndex:self.syncList name:device.name];
    if(i<0){
        [_syncList addObject:device];
    }
}

-(void)updateSyncDevice:(DeviceEntity*)device{
    if(self.isMaster){
        //int i = [self searchArrayIndex:_syncList name:device.name];
        int i = -1;
        DeviceEntity* one = nil;
        for(int j=0;j<_syncList.count;j++){
            one = _syncList[j];
            if([one.name substringToIndex:one.name.length - 6]==[device.name substringToIndex:device.name.length - 6]){
                i = j;
                break;
            }
        }
        //
        if(i>-1){
            DeviceEntity* syncDevice = [_syncList objectAtIndex:i];
            device.receiveStatus = syncDevice.receiveStatus;
            device.syncStatus = syncDevice.syncStatus;
            [_syncList replaceObjectAtIndex:i withObject:device];
        }
    }
}

-(NSMutableArray*)getAllPeers{
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    for(int i=0;i<_list.count;i++){
        [arr addObject:[_list[i] peer]];
    }
    return arr;
}

-(BOOL)searchConnectPeers:(MCPeerID*)peerID{
    NSArray* arr = [self.session connectedPeers];
    BOOL res = NO;
    for(int i=0; i<arr.count; i++){
        if([peerID.displayName isEqualToString:[arr[i] displayName]]){
            res = YES;
            break;
        }
    }
    return res;
}

-(DeviceEntity*)searchArrayObj:(NSMutableArray*)list name:(NSString*)name{// !
    int res = -1;
    DeviceEntity* one = nil;
    for(int i = 0;i<list.count;i++){
        NSString* deviceName = [list[i] name];
        if([deviceName isEqualToString:name]){
            res = i;
            one = list[i];
            break;
        }
    }
    return one;
}

-(int)searchArrayIndex:(NSMutableArray*)list name:(NSString*)name{// !
    int res = -1;
    DeviceEntity* one = nil;
    for(int i = 0;i<list.count;i++){
        if([[list[i] name] isEqualToString:name]){
            res = i;
            one = list[i];
            break;
        }
    }
    return res;
}

@end

