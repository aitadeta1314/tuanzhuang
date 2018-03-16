//
//  MultipeerView.m
//  tuanzhuang
//
//  Created by zhuang on 2017/12/5.
//  Copyright © 2017年 red. All rights reserved.
//

#import "MultipeerView.h"
#import "HomeViewController.h"
#import "Multipeer.h"
#import "MultipeerCell.h"
#import "DeviceEntity.h"
#import "StartSyncViewController.h"
#import "ReceiveDataViewController.h"
#import "HomeViewController.h"
#import "SynCodeView.h"

#define TOP_H 60
#define TOP_BTN_W 100
#define TOP_BTN_H 35
#define NIB_CELL @"MultipeerCell"

@interface MultipeerView ()<UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) UIView *boxMaskView;
@property (strong,nonatomic) UIView *boxView;
@property (strong,nonatomic) UIView *topView;
@property (strong,nonatomic) UILabel *topViewTitle;/** */
@property (strong,nonatomic) UIView *centerView;
//
@property (strong,nonatomic) UITableView *listView;
@property (strong,nonatomic) NSMutableArray* dataList;
@property (strong,nonatomic) Multipeer* multipeer;
@property (strong,nonatomic) SynCodeView* alert;
@property (strong,nonatomic) DeviceEntity* synDevice;

@end

@implementation MultipeerView

- (instancetype)initView{
    [super viewDidLoad];
    [self dataList];
    [self.view addSubview:self.boxMaskView];
    [self.view addSubview:self.boxView];
    [self setupRefresh];
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    weakObjc(self);
    self.multipeer.onRefresh = ^{
        [weakself.listView reloadData];
    };
    self.multipeer.onReceive = ^{
        if(!weakself.view.hidden){// 用户在当前页面
            ReceiveDataViewController* vc = [[ReceiveDataViewController alloc] init];
            
            MainNavigationViewController * navi = [[MainNavigationViewController alloc] initWithRootViewController:vc];
            [weakself presentViewController:navi animated:YES completion:^{}];
        }
    };
    self.multipeer.message.subCode_0 = ^(NSMutableDictionary *dic, DeviceEntity *device) {
        NSData* msg = [weakself.multipeer.message createMsg:@"subCode" s:@1 msg:@"1"];
        [weakself.multipeer sendMsg:device msg:msg];
    };
}

-(void)viewWillDisappear:(BOOL)animated{
    self.multipeer.message.subCode_0 = nil;
}

-(void)dealloc{
    self.multipeer.onRefresh = nil;
    self.multipeer.onReceive = nil;
}

#pragma mark - 懒加载
-(Multipeer *)multipeer{
    if(!_multipeer){
        _multipeer = [[Multipeer alloc] init];
    }
    return _multipeer;
}

-(NSMutableArray *)dataList{
    if(!_dataList){
        _dataList = [self.multipeer start];
    }
    return _dataList;
}

-(SynCodeView*)alert{
    if(!_alert){
        _alert = [[SynCodeView alloc] init];
        [self.view addSubview:_alert];
        //
        [SynCodeView clickConfirmButton:^(NSString * code, SynCodeViewType type){
            if(type==FILLIN_SYNCODE){
                NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(syncFileAction_overTime) userInfo:nil repeats:NO];
                [self showLoadingWith:@"同步中..."];
                weakObjc(self);
                [_multipeer collectCodeValidAction:_synDevice collectCode:code result:^(NSMutableDictionary *dic) {
                    if(timer.isValid){// 超时返回
                        [timer invalidate];
                        [weakself hideLoading];
                    }else{
                        return;
                    }
                    if([dic[@"msg"] isEqual:@1]){
                        StartSyncViewController *vc = [[StartSyncViewController alloc] init];
                        vc.device = _synDevice;
                        vc.multipeer = _multipeer;
                        [weakself presentViewController:vc animated:NO completion:^{}];
                    }else{
                        UIAlertController* tip = [UIAlertController alertControllerWithTitle:@"" message:@"同步码错误！" preferredStyle:UIAlertControllerStyleAlert];
                        [tip addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}]];
                        [weakself presentViewController:tip animated:YES completion:nil];
                    }
                }];
            }else{
                [_multipeer collectCodeCreateAction:code];
                [self topViewTitle];
            }
        }];
    }
    return _alert;
}

#pragma mark - action
-(void)refreshClickAction{
    [_multipeer refreshPeers];
    [self showLoadingWith:@"刷新中..." andDelay:2];
}

-(void)cancelClickAction{
    self.listView = nil;
    self.dataList = nil;
    [self.multipeer end];
    UINavigationController* nav = (UINavigationController*)self.presentingViewController;
    HomeViewController* vc = nav.viewControllers[0];
    [self dismissViewControllerAnimated:NO completion:^{
        [vc.collectionView reloadData];
    }];
}

-(void)collectCodeClickAction{
    NSString* validCode = [NSString stringWithFormat:@"%d",1000 + (arc4random() % 9000)];
    self.alert.type = GENERATE_SYNCODE;
    self.alert.syncode = validCode;
    self.alert.name = _multipeer.currentName;
    [self.alert show];
}

-(void)syncFileAction:(DeviceEntity*)device{
    if(device.connectStatus!=CONNECT_YES){return;}
    _synDevice = device;
    self.alert.type = FILLIN_SYNCODE;
    self.alert.name = _synDevice.name;
    [self.alert show];
}

-(void)syncFileAction_overTime{
    [self hideLoading];
    [self tipDialog:@"" content:@"同步码验证失败，请重新发送" result:^(id obj) {}];
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MultipeerCell * cell = [_listView dequeueReusableCellWithIdentifier:NIB_CELL forIndexPath:indexPath];
    if(_dataList.count>indexPath.row){
        DeviceEntity *info = _dataList[indexPath.row];
        cell.syncStatusView.hidden = YES;
        [cell loadData:info];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 115;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 1 松开手选中颜色消失
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MultipeerCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // 2
    //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    // 3点击没有颜色改变
    cell.selected = NO;
    // click
    [self syncFileAction:_dataList[indexPath.row]];
}

#pragma mark -  下拉刷新
-(void)setupRefresh{
    //1.添加刷新控件
    UIRefreshControl *control=[[UIRefreshControl alloc]init];
    [control addTarget:self action:@selector(refreshStateChange:) forControlEvents:UIControlEventValueChanged];
    [self.listView addSubview:control];
    //2.马上进入刷新状态，并不会触发UIControlEventValueChanged事件
    //[control beginRefreshing];
    // 3.加载数据
    [self refreshStateChange:control];
}

-(void)refreshStateChange:(UIRefreshControl *)control{
    [self.multipeer refreshPeers];
    [self.listView reloadData];
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [control endRefreshing];
    });
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.dataList.count == 0 || self.listView.tableFooterView.isHidden == NO) return;
    //CGFloat y = scrollView.contentOffset.y;
}

#pragma mark - view
-(UIView *)boxMaskView{
    if(!_boxMaskView){
        _boxMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelClickAction)];
        [_boxMaskView addGestureRecognizer:tapGesture];
    }
    return _boxMaskView;
}

-(UIView *)boxView{
    if(!_boxView){
        self.view.backgroundColor = RGBColorAlpha(0, 0, 0, .3);
        self.modalPresentationStyle = UIModalPresentationCustom;
        //        [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelClickAction)]];
        //
        _boxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 680, 680)];
        _boxView.layer.cornerRadius = 10;
        _boxView.layer.shadowOpacity = 0.5;// 阴影透明度
        _boxView.layer.shadowColor = [UIColor grayColor].CGColor;// 阴影的颜色
        _boxView.layer.shadowOffset = CGSizeMake(2,2);// 阴影的范围
        _boxView.layer.shadowRadius = 5;// 阴影扩散的范围控制
        _boxView.backgroundColor = [UIColor whiteColor];
        _boxView.center = self.view.center;
        [self topView];
        [_boxView addSubview:self.centerView];
        [_centerView addSubview:[self line:_centerView.frame.size.width h:1.3]];
    }
    return _boxView;
}

-(UIView *)topView{
    if(!_topView){
        _topView = [[UIView alloc] init];
        _topView.frame = CGRectMake(0, 0, _boxView.frame.size.width , TOP_H);
        [_boxView addSubview:_topView];
        // layout
        CGFloat btns_w = (TOP_BTN_W + 20) * 3;
        // title
        
        [_topView addSubview:self.topViewTitle];
        // btns
        UIView *btns = [[UIView alloc] init];
        [_topView addSubview:btns];
        [btns mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(btns_w);
            make.height.top.right.equalTo(_topView);
        }];
        [self createButton:btns text:@"同步码" action:@selector(collectCodeClickAction)];
//        [self createButton:btns text:@"刷新" action:@selector(refreshClickAction)];
    }
    return _topView;
}

-(UIView *)centerView{
    if(!_centerView){
        _centerView = [[UIView alloc] initWithFrame:CGRectMake(0, TOP_H, _boxView.frame.size.width, _boxView.frame.size.height)];
        [_centerView addSubview:self.listView];
    }
    return _centerView;
}

-(UILabel *)topViewTitle{
    if(!_topViewTitle){
        CGFloat btns_w = (TOP_BTN_W + 20) * 3;
        _topViewTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, _boxView.frame.size.width - btns_w, TOP_H)];
        _topViewTitle.font = [UIFont boldSystemFontOfSize:20];
        _topViewTitle.numberOfLines = 1;
    }
    NSString* code = [UserManager getUserInfo:@"collectCode"];
    if(code!=nil && ![code isEqualToString:@""]){
        _topViewTitle.text = [NSString stringWithFormat:@"%@  -  %@",_multipeer.currentName,code];
    }else{
        _topViewTitle.text = _multipeer.currentName;
    }
    return _topViewTitle;
}

-(UITableView *)listView{
    if(!_listView){
        _listView = [[UITableView alloc] initWithFrame:CGRectMake(20, 0, _centerView.frame.size.width - 40,_centerView.frame.size.height - TOP_H) style:UITableViewStylePlain];
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_listView registerNib:[UINib nibWithNibName:@"MultipeerCell" bundle:nil] forCellReuseIdentifier:NIB_CELL];
        _listView.delegate = self;
        _listView.dataSource = self;
    }
    return _listView;
}

-(UIView *)line:(CGFloat)w h:(CGFloat)h{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    lineView.layer.borderWidth = 0;
    lineView.backgroundColor = systemDarkGrayColor;
    return lineView;
}

-(UIButton*)createButton:(UIView*)box text:(NSString*)text action:(SEL)action{
    CGFloat rp = - ((TOP_BTN_W + 20) * box.tag++ + 20);// box.tag : 按钮数量
    UIButton *btn = [[UIButton alloc] init];
    btn.backgroundColor = skyColor;
    btn.clipsToBounds = YES;
    btn.layer.cornerRadius = 5;
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn.titleLabel.textColor = [UIColor whiteColor];
    [box addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(TOP_BTN_W);
        make.height.mas_equalTo(TOP_BTN_H);
        make.centerY.equalTo(box.mas_centerY);
        make.right.equalTo(box.mas_right).offset(rp);
    }];
    [btn addTarget:self action:action forControlEvents:(UIControlEventTouchDown)];
    return btn;
}

@end

