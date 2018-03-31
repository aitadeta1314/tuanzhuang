//
//  MultipeerView.m
//  tuanzhuang
//
//  Created by zhuang on 2017/12/5.
//  Copyright © 2017年 red. All rights reserved.
//

#import "SyncMultipeerView.h"
#import "HomeViewController.h"
#import "Multipeer.h"
#import "MultipeerCell.h"
#import "DeviceEntity.h"
#import "StartSyncViewController.h"
#import "ReceiveDataViewController.h"

#define TOP_H 60
#define TOP_BTN_W 84
#define TOP_BTN_H 32
#define NIB_CELL @"MultipeerCell"

@interface SyncMultipeerView ()<UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) UIView *boxMaskView;
@property (strong,nonatomic) UIView *boxView;
@property (strong,nonatomic) UIView *topView;
@property (strong,nonatomic) UIView *centerView;
//
@property (strong,nonatomic) UITableView *listView;
@property (strong,nonatomic) NSMutableArray* dataList;

@end

@implementation SyncMultipeerView

- (instancetype)initView{
    [super viewDidLoad];
    [self dataList];
    [self.view addSubview:self.boxMaskView];
    [self.view addSubview:self.boxView];
    [self multipeerBlock];
    [self refreshView];
    return self;
}

-(void)multipeerBlock{
    [self.multipeer resetSyncStatus];
    weakObjc(self);
    self.multipeer.onRefresh = ^{
        [weakself refreshView];
    };
}

-(void)dealloc{
    NSLog(@"multipeer : dealloc");
//    self.multipeer.onRefresh = nil;
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
        _dataList = [[NSMutableArray alloc] init];
    }
    return _dataList;
}

#pragma mark - action
-(void)refreshView{
    NSArray *arr = self.multipeer.syncList;
    DeviceEntity* device = nil;
    [_dataList removeAllObjects];
    for(int i=0;i<arr.count;i++){
        device = arr[i];
        if(device.connectStatus==CONNECT_YES && device.syncStatus!=SYNC_NO){
            [_dataList addObject:device];
        }
    }
    [self.listView reloadData];
}

-(void)cancelClickAction{
    self.listView = nil;
    [self dismissViewControllerAnimated:NO completion:^{}];
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MultipeerCell *cell = [self.listView dequeueReusableCellWithIdentifier:NIB_CELL forIndexPath:indexPath];
    if(_dataList.count>indexPath.row){
        DeviceEntity *info = _dataList[indexPath.row];
        [cell loadSyncData:info];
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
}

#pragma mark - view
-(UIView *)boxMaskView{
    if(!_boxMaskView){
        _boxMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
        _boxMaskView.backgroundColor = RGBColorAlpha(0,0,0,0);
        //        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelClickAction)];
        //        [_boxMaskView addGestureRecognizer:tapGesture];
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
        _boxView.layer.cornerRadius = 5;
        _boxView.layer.shadowOpacity = 0.5;// 阴影透明度
        _boxView.layer.shadowColor = [UIColor grayColor].CGColor;// 阴影的颜色
        _boxView.layer.shadowOffset = CGSizeMake(2, 2);// 阴影的范围
        _boxView.layer.shadowRadius = 5;// 阴影扩散的范围控制
        _boxView.backgroundColor = [UIColor whiteColor];
        _boxView.center = self.view.center;
        [_boxView addSubview:self.topView];
        [_boxView addSubview:self.centerView];
        [_centerView addSubview:[self line:_centerView.frame.size.width h:1.3]];
    }
    return _boxView;
}

-(UIView *)topView{
    if(!_topView){
        _topView = [[UIView alloc] init];
        _topView.frame = CGRectMake(0, 0, _boxView.frame.size.width , TOP_H);
        [self layoutTop];
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

- (void)layoutTop{
    CGFloat w = _topView.frame.size.width;
    CGFloat btns_p = 20;
    CGFloat btns_w = (TOP_BTN_W + btns_p) * 2;
    //
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(btns_p, 0, self.view.frame.size.width - btns_w, TOP_H)];
    title.font = [UIFont boldSystemFontOfSize:20];
    title.numberOfLines = 1;
    title.text = @"数据同步信息";
    [_topView addSubview:title];
    //
    UIView *btns = [[UIView alloc] initWithFrame:CGRectMake( w - btns_w, 0, btns_w, TOP_H)];
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(TOP_BTN_W + btns_p , (TOP_H - TOP_BTN_H)/2, TOP_BTN_W, TOP_BTN_H)];
    cancelBtn.backgroundColor = skyColor;
    cancelBtn.clipsToBounds = YES;
    cancelBtn.layer.cornerRadius=5;
    [cancelBtn setTitle:@"关闭" forState:UIControlStateNormal];
    cancelBtn.titleLabel.textColor = [UIColor whiteColor];
    [btns addSubview:cancelBtn];
    [_topView addSubview:btns];
    // event
    [cancelBtn addTarget:self action:@selector(cancelClickAction) forControlEvents:(UIControlEventTouchDown)];
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
    lineView.backgroundColor = RGBColor(204, 204, 204);
    return lineView;
}

@end


