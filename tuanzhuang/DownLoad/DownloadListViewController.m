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

static const CGFloat cellheight = 84;
static const CGFloat downloadviewheight = 60;

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
    [self madeData];
    
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
    
    _header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(searchCompany)];
    self.tableView.mj_header = _header;
    _header.lastUpdatedTimeLabel.hidden = YES;
    
    _footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(searchCompany)];
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
        make.height.mas_equalTo(downloadviewheight);
    }];
    self.downloadBtn.backgroundColor = RGBColor(204, 204, 204);
    self.downloadBtn.enabled = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [companyCell downloadWithBlock:^(NSInteger index) {
        companyModel * model = [self.dataArray objectAtIndex:index];
        model.status = 1;
        [self downloadnotice];
    }];
}

#pragma mark - 测试数据
-(void)madeData
{
    for (int i=0; i<15; i++) {
        companyModel * model = [[companyModel alloc] init];
        model.companyname = [self randomCompanyName];
        model.uploaddate = @"2017-07-09";
        model.downloadtimes = @"3";
        [self.dataArray addObject:model];
    }
}

-(NSString *)randomPersonName
{
    NSArray * names = @[@"王小红",@"李小明",@"孙小刚",@"狗蛋儿",@"李二妮",@"王大花",@"李二狗",@"郭大牛",@"赵二狗",@"王二麻子",@"高大头",@"葛二蛋",@"旺财",@"来福",@"小强",@"二饼",@"虎子",@"张三",@"李四",@"李刚",@"钱二虎",@"赵大脑袋",@"欧阳蛋蛋",@"小石头",@"陈铁蛋"];
    return names[arc4random()%25];
}

-(NSString *)randomCompanyName
{
    NSArray * names = @[@"百度",@"阿里巴巴",@"腾讯",@"中国建设银行",@"中国交通银行",@"中国农业银行",@"中国招商银行",@"中国工商银行",@"中国邮政",@"酷特云蓝"];
    return [NSString stringWithFormat:@"%@%d",names[arc4random()%10],arc4random()%100];
}

-(NSString *)randomId
{
    NSString * string = [[NSString alloc] init];
    NSArray * ids = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    for (int i = 0; i < 6; i++) {
        string = [string stringByAppendingString:ids[arc4random()%10]];
    }
    return string;
}

#pragma mark - 初始化数据
-(NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
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
        tableview_h = self.tableView.frame.size.height-downloadviewheight;
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
        tableview_h = self.tableView.frame.size.height+downloadviewheight;
    }
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(tableview_h);
    }];
    [self.tableView reloadData];
}

#pragma mark - 网络请求
-(void)searchCompany
{
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    _footer.state = MJRefreshStateNoMoreData;
    [self.tableView reloadData];
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
    return cellheight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_toSelect) {
        companyModel * model = [self.dataArray objectAtIndex:indexPath.row];
        if (model.status >= 2) {
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
//检查是否已经全部选中
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

//下载提示
-(void)downloadnotice
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"您确定要下载选中的数据？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self cancleDownload];
    }];
    UIAlertAction * sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self prepareDownload];
        [self.tableView reloadData];
        [self downloadData];
        [self startTimer];
    }];
    [sureAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alert addAction:cancleAction];
    [alert addAction:sureAction];
    [self presentViewController:alert animated:YES completion:nil];
}

//准备下载
-(void)prepareDownload
{
    for (int i = 0; i<self.dataArray.count; i++) {
        companyModel * model = [self.dataArray objectAtIndex:i];
        if (model.status == 1) {
            model.status = 2;
        }
    }
}

//取消准备
-(void)cancleDownload
{
    for (int i = 0; i<self.dataArray.count; i++) {
        companyModel * model = [self.dataArray objectAtIndex:i];
        model.status = 0;
    }
}

//标记已下载
-(void)finishDownload
{
    for (int i = 0; i<self.dataArray.count; i++) {
        companyModel * model = [self.dataArray objectAtIndex:i];
        if (model.status == 2) {
            model.status = 3;
        }
    }
}

-(void)downloadData
{
    CompanyModel * company = [CompanyModel MR_createEntity];
//    company.companyid = [self randomId];
    company.companyid = @"123";
    company.companyname = [self randomCompanyName];
    company.addtime = [NSDate date];
    company.lock_status = false;
    company.configuration = @"1-T,2-CD";
    
    for (int i = 0; i < 18; i++) {
        PersonnelModel *personnel = [PersonnelModel MR_createEntity];
        personnel.company = company;
        personnel.name = [self randomPersonName];
        personnel.department = @"后勤";
        personnel.companyid = company.companyid;
//        if (i%2 == 0) {
//            personnel.personnelid = [self randomId];
//        }
        personnel.firstletter = [GetLetter firstLetterOfString:personnel.name];
        personnel.edittime = [NSDate date];
        personnel.gender = i%2;
        personnel.lid = [UserManager getName];
        personnel.lname = [UserManager getName];
        personnel.status = i%3;
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)startTimer
{
    _times = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timefun) userInfo:nil repeats:YES];
}

-(void)timefun{
    if (_times == 5) {
        [_timer invalidate];
        [self finishDownload];
        [self.tableView reloadData];
    } else {
        _times ++;
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
