//
//  AboutViewController.m
//  tuanzhuang
//
//  Created by Fenly on 2017/12/21.
//  Copyright © 2017年 red. All rights reserved.
//

#import "AboutViewController.h"
#import "SimpleTableCell.h"
#import "ExplainViewController.h"
#import "CopyRightViewController.h"

#define simpleCellIdentify @"simpleCellIden"
@interface AboutViewController ()<UITableViewDelegate, UITableViewDataSource>

/**
 *  tableview
 */
@property (nonatomic, strong) UITableView *tableView;
/**
 *  headerview
 */
@property (nonatomic, strong) UIView *headerView;
/**
 *  dataSource
 */
@property (nonatomic, strong) NSArray *itemArr;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
    self.title = @"关于";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self layoutView];
}

- (void)layoutView {
    [self.view addSubview:self.tableView];
    
}

#pragma mark - 懒加载
- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, 200)];
        _headerView.backgroundColor = [UIColor clearColor];
        UIImageView *imageView = [[UIImageView alloc] init];
        [_headerView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_headerView);
            make.size.mas_equalTo(CGSizeMake(85, 85));
            make.top.equalTo(_headerView).offset(30);
        }];
        imageView.image = [UIImage imageNamed:@"headerIcon"];
        
        UILabel *versions = [[UILabel alloc] init];
        [_headerView addSubview:versions];
        versions.backgroundColor = [UIColor clearColor];
        [versions mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_headerView);
            make.top.equalTo(imageView.mas_bottom).offset(30);
            
        }];
        versions.text = @"团装APP1.0";
        versions.font = [UIFont boldSystemFontOfSize:14];
        versions.textAlignment = NSTextAlignmentCenter;
        versions.textColor = RGBColor(153, 153, 153);
        
        UIView *line = [[UIView alloc] init];
        [_headerView addSubview:line];
        line.backgroundColor = systemGrayColor;
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0.5);
            make.width.equalTo(_headerView);
            make.bottom.equalTo(_headerView);
            make.left.equalTo(_headerView);
        }];
    }
    return _headerView;
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = RGBColor(245, 245, 245);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerNib:[UINib nibWithNibName:@"SimpleTableCell" bundle:nil] forCellReuseIdentifier:simpleCellIdentify];
        _tableView.tableHeaderView = self.headerView;
    }
    return _tableView;
}

- (NSArray *)itemArr {
    if (!_itemArr) {
        _itemArr = @[@"版本说明", @"版权信息"];
    }
    return _itemArr;
}

#pragma mark - uitableviewDelegate / datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SimpleTableCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleCellIdentify forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.listNameLb.text = self.itemArr[indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger idx = indexPath.row;
    SuperViewController *vc = nil;
    if ([self.itemArr[idx] isEqualToString:@"版本说明"]) {
        vc = [[ExplainViewController alloc] init];
    }
    else if ([self.itemArr[idx] isEqualToString:@"版权信息"]) {
        vc = [[CopyRightViewController alloc] init];
    }
    
    
    vc.title = self.itemArr[idx];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
