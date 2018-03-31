//
//  DownloadListViewController.m
//  tuanzhuang
//
//  Created by red on 2017/11/29.
//  Copyright © 2017年 red. All rights reserved.
//

#import "DownloadListViewController.h"
#import "companyCell.h"
#import "companyModel.h"
#import "GetLetter.h"
#import "DownloadManager.h"

static const CGFloat cellHeight = 84;
static const CGFloat downloadViewHeight = 60;
static const int pageSize = 15;

@interface DownloadListViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ZZNumberFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet ZZNumberField *searchTextfield;
@property (weak, nonatomic) IBOutlet UIButton *cancleSearchBtn;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (nonatomic, strong) MJRefreshNormalHeader * header;/**<下拉刷新*/
@property (nonatomic, strong) MJRefreshBackNormalFooter * footer;/**<上拉加载*/

@property (strong, nonatomic) UIView * maskLayerView;//搜索时出现的遮罩层

@property (strong, nonatomic) NSMutableArray * dataArray;
@property (assign, nonatomic) BOOL toSelect;
@property (assign, nonatomic) NSInteger selectedNum;

@property (nonatomic, strong) NSTimer * timer;/**<计时器*/
@property (nonatomic, assign) int times;/**<计时*/

@property (nonatomic, assign) NSInteger currentPage;/**<当前页码*/
@property (nonatomic, assign) BOOL hasmore;/**<是否还有下一页*/

@property (nonatomic, strong) NSMutableArray * managersArray;/**<"下载数据"解析器数组*/
@property (nonatomic, strong) DownloadManager * downloadManager;/**<解析下载数据*/

@property (nonatomic, strong) NSURLSessionDataTask * searchTask;/**<搜索/获取列表网络请求任务*/
@property (nonatomic, strong) NSURLSessionDataTask * downloadTask;/**<下载网络请求任务*/
@end

@implementation DownloadListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"下载";
    _toSelect = NO;
    [self addBackButton];
    [self addRightButtonWithTitle:@"多选"];
    self.selectedNum = 0;
    self.currentPage = 1;
    weakObjc(self);
    /*顶部搜索框相关布局--外部view*/
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.view).with.mas_offset(TOPNAVIGATIONBAR_H);
        make.left.mas_equalTo(weakself.view);
        make.bottom.mas_equalTo(weakself.tableView.mas_top);
        make.right.mas_equalTo(weakself.view);
    }];
    self.topView.backgroundColor = RGBColor(204, 204, 204);
    
    /*顶部搜索框相关布局--搜索textfield*/
    [self.searchTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakself.topView).with.insets(UIEdgeInsetsMake(SEARCH_Y, SEARCH_X, SEARCH_Y, SEARCH_X));
    }];
    self.searchTextfield.keyboard = KEYBOARDTYPE_WRITINGPAD;
    self.searchTextfield.backgroundColor = RGBColor(255, 255, 255);
    self.searchTextfield.layer.cornerRadius = 5;
    self.searchTextfield.delegate = self;
    self.searchTextfield.numDelegate = self;
    self.searchTextfield.clearButtonMode = UITextFieldViewModeAlways;
    UIView * leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 20)];
    self.searchTextfield.leftView = leftView;
    self.searchTextfield.leftViewMode = UITextFieldViewModeAlways;
    self.searchTextfield.inputAccessoryView = [[UIView alloc] initWithFrame:CGRectZero];
    
    /*顶部搜索框相关布局--取消搜索按钮*/
    [self.cancleSearchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.searchTextfield);
        make.left.mas_equalTo(weakself.searchTextfield.mas_right).with.offset(SEARCH_X);
        make.width.mas_equalTo(CANCLE_W);
        make.bottom.mas_equalTo(weakself.searchTextfield);
    }];
    
    /*tableview布局*/
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.topView.mas_bottom);
        make.left.mas_equalTo(weakself.view);
        make.bottom.mas_equalTo(weakself.downloadBtn.mas_top);
        make.right.mas_equalTo(weakself.view);
        make.height.mas_equalTo(SCREEN_H-TOPNAVIGATIONBAR_H-TOPVIEW_H);
    }];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(dropDownAction)];
    self.tableView.mj_header = _header;
    _header.lastUpdatedTimeLabel.hidden = YES;
    
    _footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullUpAction)];
    self.tableView.mj_footer = _footer;
    [_footer setTitle:@"没有可加载的数据" forState:MJRefreshStateNoMoreData];
    
    /*搜索时遮罩层初始布局*/
    [self.maskLayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.view).offset(TOPVIEW_H+TOPNAVIGATIONBAR_H);
        make.left.mas_equalTo(weakself.view);
        make.bottom.mas_equalTo(weakself.view);
        make.right.mas_equalTo(weakself.view);
    }];
    self.maskLayerView.hidden = YES;
    
    /*下载按钮布局*/
    [self.downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.view);
        make.top.mas_equalTo(weakself.tableView.mas_bottom);
        make.right.mas_equalTo(weakself.view);
        make.height.mas_equalTo(downloadViewHeight);
    }];
    self.downloadBtn.backgroundColor = RGBColor(204, 204, 204);
    self.downloadBtn.enabled = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self searchCompany];
    [companyCell downloadWithBlock:^(NSInteger index) {
        companyModel * model = [self.dataArray objectAtIndex:index];
        model.status = 1;
        [self downloadnotice];
    }];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_searchTask) {
        [_searchTask cancel];
    }
    if (_downloadTask) {
        [_searchTask cancel];
    }
    if (_downloadManager) {
        [_downloadManager stop];
    }
}
#pragma mark - 初始化数据
-(NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

-(NSMutableArray *)managersArray
{
    if (_managersArray == nil) {
        _managersArray = [[NSMutableArray alloc] init];
    }
    return _managersArray;
}

#pragma mark - UI布局
//搜索时处理“取消”按钮
-(void)operationCancelBtnWhenSearch:(BOOL)operation
{
    weakObjc(self);
    if (operation) {
        //显示“取消”按钮
        weakself.maskLayerView.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            [weakself.searchTextfield mas_updateConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(weakself.topView).with.insets(UIEdgeInsetsMake(SEARCH_Y, SEARCH_X, SEARCH_Y, 2*SEARCH_X+CANCLE_W));
            }];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        //隐藏“取消”按钮
        weakself.maskLayerView.hidden = YES;
        [UIView animateWithDuration:0.2 animations:^{
            [weakself.searchTextfield mas_updateConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(weakself.topView).with.insets(UIEdgeInsetsMake(SEARCH_Y, SEARCH_X, SEARCH_Y, SEARCH_X));
            }];
        } completion:^(BOOL finished) {
            
        }];
    }
}

//懒加载搜索遮罩层
-(UIView *)maskLayerView
{
    if (_maskLayerView == nil) {
        _maskLayerView = [[UIView alloc] init];
        _maskLayerView.backgroundColor = RGBColorAlpha(0, 0, 0, 0.3);
        [self.view addSubview:_maskLayerView];
    }
    return _maskLayerView;
}

#pragma mark - 重写父类方法
//重写导航栏左侧按钮方法(全选按钮)
-(void)leftButtonPress
{
    BOOL selectsatus;
    if (_selectedNum == _dataArray.count) {
        selectsatus = NO;
    } else {
        selectsatus = YES;
    }
    for (companyModel * model in _dataArray) {
        model.selected = selectsatus;
    }
    [self checkSelect];
    [self.tableView reloadData];
}

//重写导航栏右侧按钮方法
-(void)rightButtonPress
{
    CGFloat tableview_h = 0;
    self.toSelect = !self.toSelect;
    if (self.toSelect) {
        [self changeRightButtonTile:@"完成"];
        [self changeLeftButtonTile:@"全选"];
        tableview_h = self.tableView.frame.size.height-downloadViewHeight;
    } else {
        [self changeRightButtonTile:@"多选"];
        [self removeLeftBtn];
        [self addBackButton];
        self.title = @"下载";
        for (companyModel * model in _dataArray) {
            model.selected = NO;
            if (model.status < 2) {
                model.status = 0;
            }
        }
        self.downloadBtn.enabled = NO;
        self.downloadBtn.backgroundColor = RGBColor(204, 204, 204);
        tableview_h = self.tableView.frame.size.height+downloadViewHeight;
    }
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(tableview_h);
    }];
    [self.tableView reloadData];
}

#pragma mark - 网络请求
#pragma mark -- “搜索/获取任务列表”网络请求
-(void)searchCompany
{
    [self showLoading];
    NSString * url = [NSString stringWithFormat:@"%@/bmission/page?",HTTP_HEADER];
    if (_searchTextfield.text.length > 0) {
        url = [NSString stringWithFormat:@"%@name=%@&",url,_searchTextfield.text];
    }
    url = [NSString stringWithFormat:@"%@orderBy=1&pageSize=%d&currentPage=%ld",url,pageSize,self.currentPage];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    self.searchTask = [NetworkOperation getWithUrl:url andToken:[UserManager getToken] andSuccess:^(id rootobject) {
        [self hideLoading];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if (self.currentPage == 1) {
            [self.dataArray removeAllObjects];
        }
        NSArray * records = [rootobject valueForKey:@"records"];
        self.hasmore = [[rootobject valueForKey:@"currentPage"] intValue] < [[rootobject valueForKey:@"totalPages"] intValue];
        for (NSDictionary * dic in records) {
            companyModel * model = [[companyModel alloc] init];
            model.companyname = [dic valueForKey:@"name"];
            model.updatetime = [dic valueForKey:@"modifiedTime"];
            model.companyid = [dic valueForKey:@"businessId"];
            model.downloadtimes = [[dic valueForKey:@"times"] intValue];
            model.yiliang = [[dic valueForKey:@"isUpload"] boolValue];
            [self.dataArray addObject:model];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.hasmore) {
                [self.footer setState:MJRefreshStateIdle];
            } else {
                [self.footer setState:MJRefreshStateNoMoreData];
            }
            [self.tableView reloadData];
        });
    } andFailure:^(NSError *error, NSString *errorMessage) {
        [self hideLoading];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self showHUDMessage:errorMessage];
    }];
}

#pragma mark -- "数据下载"网络请求
-(void)downloadDatas
{
    [self showLoading];
    NSString * missionids = [self needDownloadDatasId];
    NSString * url = [NSString stringWithFormat:@"%@file/data/%@",HTTP_HEADER,missionids];
    self.downloadTask = [NetworkOperation getWithUrl:url andToken:[UserManager getToken] andSuccess:^(id rootobject) {
        
        NSArray * missionArray = (NSArray *)rootobject;
        _downloadManager = [[DownloadManager alloc] init];
        [_downloadManager handleDownloadDatas:missionArray andCover:NO andFailureMissions:^(NSArray *failureArray) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoading];
                [self finishDownload:failureArray];
                [self.tableView reloadData];
            });
            
        }];
    } andFailure:^(NSError *error, NSString *errorMessage) {
        [self hideLoading];
        [self finishDownload:nil];
        [self.tableView reloadData];
        NSString * message = @"网络异常！";
        if (errorMessage.length == 0) {
            message = @"网络异常！";
        } else {
            message = errorMessage;
        }
        [self showHUDMessage:message];
    }];
}

#pragma mark - 上下拉方法
#pragma mark -- 上拉加载
-(void)pullUpAction
{
    self.currentPage ++;
    [self searchCompany];
}

#pragma mark -- 下拉刷新
-(void)dropDownAction
{
    self.currentPage = 1;
    [self searchCompany];
}

#pragma mark - 按钮、手势方法
//”下载“ 按钮方法
- (IBAction)downloadAction:(UIButton *)sender {
    [self downloadnotice];
}

//”取消“搜索 按钮方法
- (IBAction)cancleSearchAction:(UIButton *)sender {
    [self operationCancelBtnWhenSearch:NO];
    _searchTextfield.text = @"";
    [_searchTextfield resignFirstResponder];
}

#pragma mark - tableviewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    companyModel * model = [self.dataArray objectAtIndex:indexPath.row];
    if (model.status == 4) {
//        model.status = 1;
//        [self downloadnotice];
    } else {
        if (_toSelect) {
            if (model.status == 3) {
                return;
            }
            model.selected = !model.selected;
            if (model.selected) {
                model.status = 1;
            } else {
                model.status = 0;
            }
            [self checkSelect];
            [self.tableView reloadData];
        }
    }
    
}

#pragma mark - tableviewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * ID = @"companycell";
    companyCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[companyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    companyModel * model = [self.dataArray objectAtIndex:indexPath.row];
    [cell cellWithData:model showSelect:_toSelect keyWords:_searchTextfield.text andIndex:indexPath.row];
    return cell;
}

#pragma mark - textfielddelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self operationCancelBtnWhenSearch:YES];
}

#pragma mark - ZZNumberFieldDelegate
-(void)didSearchClicked
{
    [self operationCancelBtnWhenSearch:NO];
    [_searchTextfield resignFirstResponder];
    [self searchCompany];
}

#pragma mark - 私有方法
#pragma mark -- 检查是否已经全部选中
-(void)checkSelect
{
    NSInteger n = 0;
    for (int i = 0; i<self.dataArray.count; i++) {
        companyModel * model = [self.dataArray objectAtIndex:i];
        if (!model.selected) continue;
        n++;
    }
    _selectedNum = n;
    if (_selectedNum == _dataArray.count) {
        [self changeLeftButtonTile:@"全不选"];
    } else {
        [self changeLeftButtonTile:@"全选"];
    }
    self.title = _selectedNum >0 ? [NSString stringWithFormat:@"已选择%ld个文件",_selectedNum]:@"下载";
    self.downloadBtn.enabled = _selectedNum >0;
    
    if (_selectedNum > 0) {
        self.downloadBtn.backgroundColor = RGBColor(0, 122, 255);
    } else {
        self.downloadBtn.backgroundColor = RGBColor(204, 204, 204);
    }
    
}

#pragma mark -- 下载提示
-(void)downloadnotice
{
    BOOL reload = [self missionExist];
    NSString * title = reload ? @"下载失败" : @"下载";
    NSString * message = reload ? @"请删除本地文档后再继续下载" : @"您确定要下载选择的数据？";
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self cancleDownload];
    }];
    UIAlertAction * sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (reload) {
            [self cancleDownload];
        } else {
            [self downloadDatas];
            [self prepareDownload];
            [self.tableView reloadData];
        }
    }];
    [sureAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
    if (!reload) {
        [alert addAction:cancleAction];
    }
    [alert addAction:sureAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 判断要下载的任务本地是否已存在:如果本地存在(但不在回收站内)返回yes，否则返回no
-(BOOL)missionExist
{
    for (companyModel * model in self.dataArray) {
        if (model.status == 1) {
            CompanyModel * originalCompany = [CompanyModel MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"companyid = %@ AND del != YES", model.companyid]];
            if (originalCompany) {
                return YES;
            }
        }
        
    }
    
    return NO;
}

#pragma mark -- 准备下载
-(void)prepareDownload
{
    for (int i = 0; i<self.dataArray.count; i++) {
        companyModel * model = [self.dataArray objectAtIndex:i];
        if (model.status == 1) {
            model.status = 2;
        }
    }
}

#pragma mark -- 获取需要下载的任务id
-(NSString *)needDownloadDatasId
{
    NSString * ids = @"";
    for (companyModel * model in self.dataArray) {
        if (model.status == 1) {
            ids = [NSString stringWithFormat:@"%@,%@",model.companyid,ids];
        }
    }
    if (ids.length > 1) {
        ids = [ids substringWithRange:NSMakeRange(0, ids.length-1)];
    }
    return ids;
}

#pragma mark -- 取消准备
-(void)cancleDownload
{
    for (int i = 0; i<self.dataArray.count; i++) {
        companyModel * model = [self.dataArray objectAtIndex:i];
        if (model.status < 3) {
            model.status = 0;
        }
    }
}

#pragma mark -- 下载结束：failureArray
-(void)finishDownload:(NSArray *)failureArray
{
    for (int i = 0; i<self.dataArray.count; i++) {
        companyModel * model = [self.dataArray objectAtIndex:i];
        if (model.status == 2) {
            if (!failureArray) {
                model.status = 4;
            } else if (failureArray.count > 0) {
                for (NSString * missionid in failureArray) {
                    if ([missionid isEqualToString:model.companyid]) {
                        model.status = 4;
                    } else {
                        model.status = 3;
                    }
                }
            } else {
                model.status = 3;
            }
        }
    }
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
