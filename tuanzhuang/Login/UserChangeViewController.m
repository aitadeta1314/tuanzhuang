//
//  UserChangeViewController.m
//  tuanzhuang
//
//  Created by zhuang on 2017/12/14.
//  Copyright © 2017年 red. All rights reserved.
//

#import "UserChangeViewController.h"
#import "UserCell.h"
#import "LoginViewController.h"

#define ROW_H 80
#define PADDING_W 20

@interface UserChangeViewController ()

@property (nonatomic, strong) UIView * topView;/**标题view*/
@property (nonatomic, strong) UITableView * listView;/**用户列表view*/
@property (nonatomic, strong) UIView * bottomView;/**标题view*/

@end

@implementation UserChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _list = [self testData];
    //
    [self listView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - action
-(NSArray*)testData{
    NSMutableArray * res = [[NSMutableArray alloc] init];
    for(int i=0; i<4; i++){
        NSMutableDictionary * one = [[NSMutableDictionary alloc] init];
        [one setValue:[NSString stringWithFormat:@"%@--%i",@"用户",i] forKey:@"name"];
        if(i<1){
            [one setValue:@1 forKey:@"selected"];
        }
        [res addObject:one];
    }
    return res;
}

-(void)toLogin{
    LoginViewController* vc = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark - view
-(UITableView *)listView{
    if(!_listView){
        _listView = [[UITableView alloc] init];
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView.backgroundColor = RGBColor(238,238,238);
        //
        _listView.tableHeaderView = self.topView;
        _listView.tableFooterView = self.bottomView;
        [self.view addSubview:_listView];
        _listView.delegate = self;
        _listView.dataSource = self;
        weakObjc(self);
        [_listView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakself.view).with.insets(UIEdgeInsetsMake(TOPNAVIGATIONBAR_H,0,0,0));
        }];
    }
    return _listView;
}

-(UIView *)topView{
    if(!_topView){
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_W,ROW_H)];
        _topView.backgroundColor = [UIColor clearColor];
        UILabel* title = [[UILabel alloc] init];
        title.textColor = RGBColor(151, 151, 151);
        title.font = [UIFont systemFontOfSize:24 weight:0];
        title.text = @"用户信息列表";
        [_topView addSubview:title];
        weakObjc(self);
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakself.topView.mas_left).with.offset(PADDING_W);
            make.right.equalTo(weakself.topView.mas_right).with.offset(-PADDING_W).priorityLow();
            make.centerY.equalTo(weakself.topView.mas_centerY);
        }];
    }
    return _topView;
}

-(UIView *)bottomView{
    if(!_bottomView){
        _bottomView = [self footerRow];
    }
    return _bottomView;
}

#pragma mark - <UITableViewDataSource,UITableViewDelegate>
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id one = _list[indexPath.row];
    UserCell * cell = [[UserCell alloc] init];
    cell.tag = 1;
    [cell loadData:one];
    //
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _list.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ROW_H;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    editingStyle = UITableViewCellEditingStyleDelete;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    BOOL res = YES;
    id one = _list[indexPath.row];
    if([one isKindOfClass:[NSString class]]){
        res = NO;
    }
    return res;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 1 松开手选中颜色消失
    UserCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 2 点击没有颜色改变
    cell.selected = NO;
    //
}

-(UIView *)footerRow{
    UIView* box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, ROW_H+60)];
    UIView* row = [self createRow:@"换个账号登陆" image:@"enter"];
    [box addSubview:row];
    [row mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(box.mas_width);
        make.height.mas_equalTo(ROW_H);
        make.centerY.equalTo(box.mas_centerY);
    }];
    // action
    UITapGestureRecognizer* changeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toLogin)];
    [row addGestureRecognizer:changeTap];
    return box;
}

-(UIView *)createRow:text image:(NSString*)img{
    UIView* row = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, ROW_H)];
    row.backgroundColor = RGBColor(255, 255, 255);
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = RGBColor(152, 152, 152);
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = RGBColor(152, 152, 152);
    [row addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.left.and.right.equalTo(row);
        make.height.mas_equalTo(1);
    }];
    [row addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.left.and.right.equalTo(row);
        make.height.mas_equalTo(1);
        make.bottom.equalTo(row.mas_bottom).with.offset(-1);
    }];
    // image
    UIImageView* imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:img];
    [row addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.centerY.equalTo(row.mas_centerY);
        make.right.equalTo(row.mas_right).offset(-PADDING_W).priorityLow();
    }];
    // text
    UILabel * label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:24 weight:0];
    label.textColor = RGBColor(51, 51, 51);
    label.text = text;
    [row addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.centerY.equalTo(row.mas_centerY);
        make.left.equalTo(row.mas_left).offset(30).priorityLow();
        make.right.equalTo(row.mas_right).offset(-80).priorityLow();
    }];
    return row;
}


/*
 #pragma mark - Navigation
 */
-(void)dealloc{
    NSLog(@"UserChangeViewController - dealloc");
}

@end

