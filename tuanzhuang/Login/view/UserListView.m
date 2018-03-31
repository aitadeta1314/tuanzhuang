//
//  UserListView.m
//  tuanzhuang
//
//  Created by zhuang on 2017/12/19.
//  Copyright © 2017年 red. All rights reserved.
//

#import "UserListView.h"
#import "UserListCell.h"

@interface UserListView()

@property (nonatomic, strong) UITableView * listView;/** tableview */
@property (nonatomic, strong) NSArray * list;/** 数据 */

@end

@implementation UserListView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.listView.hidden = NO;
    return self;
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserListCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell == nil){
        cell = [[UserListCell alloc] init];
        cell.layer.borderWidth = 0;
        cell.delUserAction = ^(NSDictionary* info){
            [_dataSource delUserAction:info];
        };
        [cell loadData:_list[indexPath.row]];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 1 松开手选中颜色消失
    UserListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 2 点击没有颜色改变
    cell.selected = NO;
    //
    [_dataSource selectUser:_list[indexPath.row]];
}

#pragma mark - 懒加载
-(UITableView *)listView{
    if(!_listView){
        _listView = [[UITableView alloc] init];
        _listView.layer.borderWidth = 0;
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView.delegate = self;
        _listView.dataSource = self;
        [self addSubview:_listView];
        [_listView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.left.top.equalTo(self);
        }];
    }
    return _listView;
}

#pragma mark - action
-(void)loadData:(NSArray *)arr{
    self.list = arr;
    [_listView reloadData];
}

@end

