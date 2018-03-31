//
//  AboutViewController.m
//  tuanzhuang
//
//  Created by Fenly on 2017/12/21.
//  Copyright © 2017年 red. All rights reserved.
//

#import "AboutViewController.h"
#import "TableRow.h"
#import "ExplainViewController.h"
#import "CopyRightViewController.h"

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
        versions.text = [NSString stringWithFormat:@"团装APP%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
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
        _tableView.tableHeaderView = self.headerView;
    }
    return _tableView;
}

- (NSArray *)itemArr {
    if (!_itemArr) {
        _itemArr = @[@"版本特性", @"版权信息"];
    }
    return _itemArr;
}

#pragma mark - uitableviewDelegate / datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell==nil){
        cell = [[UITableViewCell alloc] init];
        cell.layer.borderWidth = 0;
        TableRow* row = [[TableRow alloc] init];
        [cell addSubview:row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [row mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(cell);
        }];
        if(indexPath.row==0){
            row.text(nil,self.itemArr[indexPath.row],@"").topLine(0).rightIcon(@"enter").bottomLine(40);
        } else if(indexPath.row==1) {
            
            row.text(nil,self.itemArr[indexPath.row],@"").rightIcon(@"enter").bottomLine(0);
        }
        
    }
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger idx = indexPath.row;
    SuperViewController *vc = nil;
    if ([self.itemArr[idx] isEqualToString:@"版本特性"]) {
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
