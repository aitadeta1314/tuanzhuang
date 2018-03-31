//
//  StartSyncViewController.m
//  tuanzhuang
//
//  Created by zhuang on 2017/12/11.
//  Copyright © 2017年 red. All rights reserved.
//

#import "StartSyncViewController.h"
#import "ZZCircleProgress.h"
#import "DeviceEntity.h"
#import "WaterView.h"

@interface StartSyncViewController ()

@property (nonatomic, strong) NSTimer* loseTimer;/** */
@property (strong,nonatomic) NSString* topTitle;

@property (strong,nonatomic) NSProgress* progress;
@property (nonatomic, strong) WaterView * waterView;/**<水波纹view*/

@end

@implementation StartSyncViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self multipeerBlock];
}

-(void)viewDidAppear:(BOOL)animated{
    [self waterView];
    [self sendDataAction];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_waterView stop];
//    [_multipeer setStartSyncBack:nil];
//    [_multipeer setOnLose:nil];
//    _multipeer.message.masterCode_1 = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(WaterView *)waterView
{
    if (_waterView == nil) {
        _waterView = [[WaterView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
        [self.view addSubview:_waterView];
        _waterView.title = @"数据同步";
        _waterView.step = 1;
        _waterView.status = SYN_NORMAL;
        [_waterView show];
    }
    return _waterView;
}


-(void)multipeerBlock{
    weakObjc(self);
    // 设置同步回调
    self.multipeer.startSyncBack = ^(NSProgress *progress){
        [weakself step:3 message:@"0%"];
        weakself.progress = progress;
        [weakself.progress addObserver:weakself forKeyPath:@"fractionCompleted" options:(NSKeyValueObservingOptionNew) context:nil];
    };
    //
    self.multipeer.onLose = ^(DeviceEntity* one,BOOL on){
        if([one.name isEqualToString:weakself.device.name] && weakself.waterView.step>1){
            if(on){// 离开
                [weakself error:YES];
            }else{// 离开后上线
                [weakself error:NO];
                [weakself hideLoading];
                //
                if(1==weakself.waterView.step){// 1 : 续传
                    [weakself sendDataAction];
                }else{// 2 : 询问主设备状态
                    // 消息->主设备：询问主设备是否还是master
                    weakself.device = one;
                    NSData* msg = [weakself.multipeer.message createMsg:@"masterCode" s:@0 msg:@""];
                    [weakself.multipeer sendMsg:one msg:msg];
                }
            }
        }
    };
    self.multipeer.message.masterCode_1 = ^(NSMutableDictionary *dic, DeviceEntity *device){
        if(device.name == weakself.device.name){// 我的master返回了
            [weakself tipDialog:@"" content:@"主设备取消了同步操作！" result:^(id obj) {
                [weakself cancelAction];
            }];
        }
    };
    
    [WaterView clickBlock:^(OperateType type) {
        if(type==SYN_REFRESH){
            [self refreshAction];
        }else if(type==SYN_CANCLE){
            [self cancelAction];
        }else if(type==SYN_FINISH){
            [self finishAction];
        }
    }];
}


#pragma mark - action
-(void)sendDataAction{
    [self step:1 message:@"0%"];
    weakObjc(self);
    [_multipeer sendData:_device result:^(NSProgress *progress) {
        weakself.progress = progress;
        [weakself.progress addObserver:weakself forKeyPath:@"fractionCompleted" options:(NSKeyValueObservingOptionNew) context:nil];
    } error:^(NSError* e){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself error:YES];
        });
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    //获取观察的新值
    CGFloat value = [change[NSKeyValueChangeNewKey] doubleValue];
    weakObjc(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"进度:%f",value);
        [weakself step:0 message:[NSString stringWithFormat:@"%0.0f%%",value*100]];
        if(1==value && 1==_waterView.step){
            [weakself step:2 message:nil];
            [weakself.progress removeObserver:weakself forKeyPath:@"fractionCompleted"];
        }
    });
}

-(void)onLoseAction{
    [self hideLoading];
    if(_device.connectStatus!=CONNECT_YES && _waterView.step>1){
        NSString* content = [NSString stringWithFormat:@"设备(%@)已断开连接，是否返回？",_device.name];
        [self confirmDialog:@"" content:content result:^(NSInteger i, id obj) {
            if(i){
                [self cancelAction];
            }
        }];
    }
}

-(void)refreshAction{
    [self.multipeer end];
    [self.multipeer start];
    [self showLoadingWith:@"刷新中..."];
    self.loseTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(onLoseAction) userInfo:nil repeats:NO];
}

-(void)cancelAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)finishAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - view
-(void)step:(int)i  message:(NSString*)message{// i：步骤  message：进度
    if(!i){
        i = _waterView.step;
    }else{
        _waterView.step = i;
    }
    if(1==i){
        _topTitle = [NSString stringWithFormat:@"向 %@ 同步数据，已经完成%@",_device.name,message];
    }else if(2==i){
        _topTitle = [NSString stringWithFormat:@"等待来自 %@ 的分发数据...",_device.name];
    }else if(3==i){
        _topTitle = [NSString stringWithFormat:@"正在接收来自 %@ 的数据，已经完成%@",_device.name,message];
    }
    _waterView.message = _topTitle;
}

-(void)error:(BOOL)on{
    if(_waterView.step!=3){
        if(on){
            self.waterView.message = @"数据连接出错，请刷新重试";
            self.waterView.status = SYN_ERROR;
        }else{
            [self step:0 message:@"0%"];
            self.waterView.status = SYN_NORMAL;
        }
    }
}

/*
 #pragma mark - Navigation
 */

-(void)dealloc{
    NSLog(@"startSyncViewController : dealloc");
}

@end

