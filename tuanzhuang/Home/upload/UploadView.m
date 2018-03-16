//
//  UploadView.m
//  tuanzhuang
//
//  Created by zhuang on 2017/12/8.
//  Copyright © 2017年 red. All rights reserved.
//

#import "UploadView.h"
#import "UploadCell.h"
#import "UnfinishedViewController.h"

#define NIB_CELL @"UploadCell"

@interface UploadView()
@property (strong,nonatomic) UITableView* listView;
@end

@implementation UploadView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.listView];
    //
    self.navigationItem.title = @"数据上传";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 懒加载
-(UITableView *)listView{
    if(!_listView){
        _listView = [[UITableView alloc] initWithFrame:CGRectMake(20, 0, SCREEN_W - 40,SCREEN_H - TOPNAVIGATIONBAR_H) style:UITableViewStylePlain];
        [_listView registerNib:[UINib nibWithNibName:@"UploadCell" bundle:nil] forCellReuseIdentifier:NIB_CELL];
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView.delegate = self;
        _listView.dataSource = self;
    }
    return _listView;
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UploadCell* cell = [self.listView dequeueReusableCellWithIdentifier:NIB_CELL forIndexPath:indexPath];
    [cell loadData:0];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 115;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 1 松开手选中颜色消失
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UploadCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // 2
    //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    // 3点击没有颜色改变
    cell.selected = NO;
    //
    [cell loadData:1];
    
    UnfinishedViewController * unfinishedVC = VCFromBundleWithIdentifier(@"UnfinishedViewController");
    [self.navigationController pushViewController:unfinishedVC animated:YES];
}

@end
