//
//  SettingViewController.m
//  tuanzhuang
//
//  Created by zhuang on 2017/12/19.
//  Copyright © 2017年 red. All rights reserved.
//

#import "SettingViewController.h"
#import "AboutViewController.h"
#import "LoginViewController.h"
#import "TableRow.h"

@interface SettingViewController ()

@property (nonatomic, strong) UITableView * listView;/** 列表 */

@property (nonatomic, strong) UIView * headerView;/**  */
@property (nonatomic, strong) UIView * footerView;/**  */

@end

@implementation SettingViewController

- (void)viewDidLoad {
    self.title = @"设置";
    [super viewDidLoad];
    [self listView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 懒加载
-(UIView *)headerView{
    if(!_headerView){
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_H,30)];
    }
    return _headerView;
}

-(UIView *)footerView{
    if(!_footerView){
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_W,100)];
        TableRow* row = [[TableRow alloc] init];
        [_footerView addSubview:row];
        [row mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SCREEN_W);
            make.height.mas_equalTo(46);
            make.top.equalTo(_footerView.mas_top).offset(40);
        }];
        row.text(nil,@"换个登陆账号",@"").rightIcon(@"enter").topLine(0).bottomLine(0);
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeUserAction)];
        [row addGestureRecognizer:tapGesture];
    }
    return _footerView;
}

-(UITableView *)listView{
    if(!_listView){
        _listView = [[UITableView alloc] init];
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView.backgroundColor = RGBColor(241, 241, 241);
        _listView.tableHeaderView = self.headerView;
        _listView.tableFooterView = self.footerView;
        _listView.delegate = self;
        _listView.dataSource = self;
        [self.view addSubview:_listView];
        [_listView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.left.equalTo(self.view);
            make.top.equalTo(self.view).offset(TOPNAVIGATIONBAR_H);
        }];
    }
    return _listView;
}



#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell==nil){
        cell = [[UITableViewCell alloc] init];
        cell.layer.borderWidth = 0;
        TableRow* row = [[TableRow alloc] init];
        [cell addSubview:row];
        [row mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(cell);
        }];
        if(indexPath.row==0){
            row.text(nil,@"数据版本",@"2017年9月7日  18:30:09").topLine(0).bottomLine(40);
        }else if(indexPath.row==1){
            row.text(nil,@"关于",@"").rightIcon(@"enter").bottomLine(0);
        }
//        else if(indexPath.row==2){
//            row.text(nil,@"删除缓存",@"--测试用--").bottomLine(0);
//        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 46;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 1 松开手选中颜色消失
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 2 点击没有颜色改变
    cell.selected = NO;
    //
    if(indexPath.row==0){
        //
    }else if(indexPath.row==1){
        AboutViewController* aboutVc = [[AboutViewController alloc] init];
        [self.navigationController pushViewController:aboutVc animated:YES];
    }else if(indexPath.row==2){
        [UserManager clearUser];
    }
}

#pragma mark - action
-(void)changeUserAction{
    LoginViewController* loginVc = [[LoginViewController alloc] init];
//    [self.navigationController pushViewController:loginVc animated:NO];
    [self presentViewController:loginVc animated:YES completion:^{
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
