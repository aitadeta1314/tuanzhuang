//
//  UnfinishedViewController.m
//  tuanzhuang
//
//  Created by red on 2018/1/18.
//  Copyright © 2018年 red. All rights reserved.
//

#import "UnfinishedViewController.h"
#import "UnfinishedCell.h"
#import "PersonDetailContainerViewController.h"

static const NSInteger TOPBUTTONS_TAG = 1000;
static const CGFloat topview_h = 48.0;
static const CGFloat ignoreheight = 59;
static const CGFloat scrollline_h = 5.0;
static const CGFloat scrollline_w = 50.0;

@interface UnfinishedViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *allBtn;
@property (weak, nonatomic) IBOutlet UIButton *waitingBtn;
@property (weak, nonatomic) IBOutlet UIButton *processingBtn;
@property (weak, nonatomic) IBOutlet UIView *scrollLiveView;

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;

@property (nonatomic, strong) UISegmentedControl * segmentedControl;/**<*/

@property (strong, nonatomic) NSMutableArray * dataArray;
@property (nonatomic, strong) NSMutableArray * indexArray;/**<索引数组*/
@property (nonatomic, strong) NSMutableArray * sourceArray;/**<数据源*/
@property (nonatomic, strong) NSMutableArray * allArray;/**<全部*/
@property (nonatomic, strong) NSMutableArray * waitingArray;/**<待量体*/
@property (nonatomic, strong) NSMutableArray * processingArray;/**<进行中*/

@property (nonatomic, assign) NSInteger datatype;/**<数据类型：0全部；1待量体；2进行中；3已完成*/

@property (assign, nonatomic) NSInteger selectedNum;
@property (assign, nonatomic) BOOL edit;

@end

@implementation UnfinishedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"未完成数据";
    [self addBackButton];
    [self addRightButtonWithTitle:@"编辑"];
    self.selectedNum = 0;
    
    weakObjc(self);
    //顶部view布局
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.view).offset(TOPNAVIGATIONBAR_H);
        make.left.mas_equalTo(weakself.view);
        make.right.mas_equalTo(weakself.view);
        make.height.mas_equalTo(topview_h);
    }];
    self.topView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    self.topView.layer.shadowOffset = CGSizeMake(0,1);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    self.topView.layer.shadowOpacity = 0.3;//阴影透明度，默认0
    self.topView.layer.shadowRadius = 2;//阴影半径，默认3
    
    //顶部所有按钮以及滚动线条布局
    //“全部”按钮布局
    [self.allBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.topView);
        make.left.mas_equalTo(weakself.topView);
        make.bottom.mas_equalTo(weakself.topView);
        make.width.mas_equalTo(weakself.waitingBtn);
    }];
    self.allBtn.tag = TOPBUTTONS_TAG;
    self.allBtn.selected = YES;
    self.allBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    
    //“待量体”按钮布局
    [self.waitingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.topView);
        make.left.mas_equalTo(weakself.allBtn.mas_right);
        make.width.mas_equalTo(weakself.allBtn);
        make.bottom.mas_equalTo(weakself.topView);
    }];
    self.waitingBtn.tag = TOPBUTTONS_TAG+1;
    
    //“进行中”按钮布局
    [self.processingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.topView);
        make.left.mas_equalTo(weakself.waitingBtn.mas_right);
        make.width.mas_equalTo(weakself.waitingBtn);
        make.bottom.mas_equalTo(weakself.topView);
        make.right.mas_equalTo(weakself.topView);
    }];
    self.processingBtn.tag = TOPBUTTONS_TAG+2;
    
    //滚动线条布局
    [self.scrollLiveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.topView.mas_bottom).offset(-scrollline_h);
        make.width.mas_equalTo(scrollline_w);
        make.left.mas_equalTo(weakself.topView).offset((SCREEN_W/3.0-scrollline_w)/2.0);
        make.height.mas_equalTo(scrollline_h);
    }];
    self.scrollLiveView.layer.cornerRadius = scrollline_h/2.0;
    
    [self.tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.topView.mas_bottom);
        make.left.mas_equalTo(weakself.view);
        make.right.mas_equalTo(weakself.view);
        make.bottom.mas_equalTo(weakself.bottomButton.mas_top);
        make.height.mas_equalTo(SCREEN_H-TOPNAVIGATIONBAR_H-topview_h);
    }];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    _datatype = 0;
    
    /*忽略按钮布局*/
    [self.bottomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.view);
        make.top.mas_equalTo(weakself.tableview.mas_bottom);
        make.right.mas_equalTo(weakself.view);
        make.height.mas_equalTo(ignoreheight);
    }];
    self.bottomButton.backgroundColor = RGBColor(204, 204, 204);
    self.bottomButton.enabled = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self handleTopButtonsTitle];
    [self.tableview reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _dataArray = nil;
    _allArray = nil;
    _waitingArray = nil;
    _processingArray = nil;
    _sourceArray = nil;
}

#pragma mark - 懒加载、数组初始化
#pragma mark -- 编辑时顶部标签
-(UISegmentedControl *)segmentedControl
{
    if (_segmentedControl == nil) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"未忽略数据", @"已忽略数据"]];
        _segmentedControl.frame = CGRectMake(0, 0, SCREEN_W/4.0, 30);
        [_segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:RGBColor(255, 255, 255),NSForegroundColorAttributeName,[UIFont systemFontOfSize:18],NSFontAttributeName ,nil] forState:UIControlStateNormal];
        [_segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:RGBColor(0, 122, 255),NSForegroundColorAttributeName,[UIFont systemFontOfSize:18],NSFontAttributeName ,nil] forState:UIControlStateSelected];
        _segmentedControl.selectedSegmentIndex = 0;
        [_segmentedControl addTarget:self action:@selector(segmentSelectItem:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}

#pragma mark -- 当前数据量体状态下对应的选中数量
-(NSInteger)selectedNum
{
    NSInteger n = 0;
    for (int i = 0; i<self.dataArray.count; i++) {
        UnfinishedModel * model = [self.dataArray objectAtIndex:i];
        if (!model.selected) continue;
        n++;
    }
    _selectedNum = n;
    return _selectedNum;
}

#pragma mark - 数据处理
#pragma mark -- “数据源”数组
-(NSMutableArray *)sourceArray
{
    if (_sourceArray == nil) {
        NSPredicate *peopleFilter = [NSPredicate predicateWithFormat:@"status < 2 AND companyid = %@", self.companymodel.companyid];
        NSFetchRequest *peopleRequest = [PersonnelModel MR_requestAllWithPredicate:peopleFilter];
        [peopleRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstletter"ascending:YES]]];
        _sourceArray = [self handleSourceArray:[PersonnelModel MR_executeFetchRequest:peopleRequest]];
    }
    return _sourceArray;
}
//处理数据源数组内容格式
-(NSMutableArray *)handleSourceArray:(NSArray *)array
{
    NSMutableArray * handlearray = [[NSMutableArray alloc] init];
    for (PersonnelModel * pmodel in array) {
        UnfinishedModel * model = [[UnfinishedModel alloc] init];
        model.personModel = pmodel;
        [handlearray addObject:model];
    }
    return handlearray;
}

#pragma mark -- 当前量体状态数据对应的数组(cell加载用的数据)
-(NSMutableArray *)dataArray
{
    switch (_datatype) {
        case 0:
            _dataArray = self.allArray;
            break;
        case 1:
            _dataArray = self.waitingArray;
            break;
        case 2:
            _dataArray = self.processingArray;
            break;
        default:
            
            break;
    }
    return _dataArray;
}

#pragma mark -- "全部"数组
-(NSMutableArray *)allArray
{
    _allArray = [[NSMutableArray alloc] init];
    if (_edit) {//页面处于“编辑”状态
        if (self.segmentedControl.selectedSegmentIndex == 0) {//获取所有“未忽略”的数据(便于进行忽略操作)
            for (UnfinishedModel * model in self.sourceArray) {
                if (!model.personModel.ignored) {
                    [_allArray addObject:model];
                }
            }
        } else {//获取所有“已忽略”的数据(便于进行忽略操作)
            for (UnfinishedModel * model in self.sourceArray) {
                if (model.personModel.ignored) {
                    [_allArray addObject:model];
                }
            }
        }
    } else {//页面处于"非编辑"状态
        _allArray = self.sourceArray;
    }
    return _allArray;
}

#pragma mark -- "待量体"数组
-(NSMutableArray *)waitingArray
{
    _waitingArray = [[NSMutableArray alloc] init];
    for (UnfinishedModel * model in self.allArray) {
        if (model.personModel.status == 0) {
            [_waitingArray addObject:model];
        }
    }
    return _waitingArray;
}

#pragma mark -- "进行中"数组
-(NSMutableArray *)processingArray
{
    _processingArray = [[NSMutableArray alloc] init];
    for (UnfinishedModel * model in self.allArray) {
        if (model.personModel.status == 1) {
            [_processingArray addObject:model];
        }
    }
    return _processingArray;
}

#pragma mark - 重写父类方法
#pragma mark -- 重写导航栏左侧按钮方法(全选按钮)
-(void)leftButtonPress
{
    BOOL selectsatus;
    if (self.selectedNum == _dataArray.count) {
        selectsatus = NO;
    } else {
        selectsatus = YES;
    }
    
    //注意 此处要用_dataArray，因为每次点击“全选/全不选”并非是对所有的数据进行操作
    //而是只针对当前量体状态多对应的数据
    for (UnfinishedModel * model in _dataArray) {
        model.selected = selectsatus;
    }
    [self handleLeftButton];
    [self handleBottomButton];
    [self.tableview reloadData];
}

#pragma mark -- 重写导航栏右侧按钮方法(编辑/完成)
-(void)rightButtonPress
{
    CGFloat tableview_h = 0;
    self.edit = !self.edit;//修改编制状态
    if (self.edit) {
        [self changeRightButtonTile:@"完成"];
        tableview_h = self.tableview.frame.size.height-ignoreheight;
        self.navigationItem.titleView = self.segmentedControl;
    } else {
        [self changeRightButtonTile:@"编辑"];
        for (UnfinishedModel * model in _allArray) {
            model.selected = NO;
        }
        tableview_h = self.tableview.frame.size.height+ignoreheight;
        self.navigationItem.titleView = nil;
    }
    [self.tableview mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(tableview_h);
    }];
    [self handleLeftButton];
    [self handleTopButtonsTitle];
    [self handleBottomButton];
    [self.tableview reloadData];
}

#pragma mark -- 重写返回按钮点击方法
-(void)backButtonPressed
{
    BOOL haveignored = [self allDataHaveIgnored];
    NSString * message = haveignored ? @"数据处理完成,确定上传？" : @"请处理未完成数据";
    weakObjc(self);
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (haveignored) {
            
        } else {
            for (UnfinishedModel * model in weakself.sourceArray) {
                if (model.personModel.ignored) {
                    model.personModel.ignored = NO;
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                }
            }
            [weakself.navigationController popViewControllerAnimated:YES];
        }
    }];
    UIAlertAction * sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (haveignored) {
            [weakself.navigationController popViewControllerAnimated:YES];
        } else {
            
        }
    }];
    [sureAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alert addAction:cancleAction];
    [alert addAction:sureAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 按钮、手势方法
//顶部按钮点击方法
- (IBAction)topBtnAction:(UIButton *)sender {
    NSInteger index = sender.tag - TOPBUTTONS_TAG;
    [self handleTopButtonsLayoutWithIndex:index];
    _datatype = index;
    [self handleLeftButton];
    [self handleBottomButton];
    [self.tableview reloadData];
}

//底部”忽略/恢复“按钮方法
- (IBAction)bottomButtonAction:(id)sender {
    weakObjc(self);
    NSString * message;
    BOOL ignore = _segmentedControl.selectedSegmentIndex == 0;
    if (ignore) {
        message = @"您确定要忽略选中的数据？";
    } else {
        message = @"您确定要恢复选中的数据？";
    }
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (UnfinishedModel * model in _allArray) {
            if (model.selected) {
                if (model.personModel.ignored != ignore) {
                    model.personModel.ignored = !model.personModel.ignored;
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                }
            }
        }
        [weakself rightButtonPress];
        [weakself.tableview reloadData];
    }];
    [sureAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alert addAction:cancleAction];
    [alert addAction:sureAction];
    [self presentViewController:alert animated:YES completion:nil];
}

//编辑状态下，导航栏处”标签“的点击方法
-(void)segmentSelectItem:(id)sender
{
    [self handleLeftButton];
    [self handleTopButtonsTitle];
    [self handleBottomButton];
    [self.tableview reloadData];
}

#pragma mark - 私有逻辑处理
#pragma mark -- 处理左侧按钮
-(void)handleLeftButton
{
    if (_edit) {
        if (self.selectedNum == self.dataArray.count && self.selectedNum > 0) {
            [self changeLeftButtonTile:@"全不选"];
        } else {
            [self changeLeftButtonTile:@"全选"];
        }
    } else {
        [self removeLeftBtn];
        [self addBackButton];
    }
}

#pragma mark -- 处理底部按钮
-(void)handleBottomButton
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self.bottomButton setTitle:@"忽略" forState:UIControlStateNormal];
    } else {
        [self.bottomButton setTitle:@"恢复" forState:UIControlStateNormal];
    }
    if (self.selectedNum > 0) {
        self.bottomButton.enabled = YES;
        self.bottomButton.backgroundColor = self.segmentedControl.selectedSegmentIndex == 0 ? RGBColor(255, 0, 0) : RGBColor(0, 122, 255);
    } else {
        self.bottomButton.enabled = NO;
        self.bottomButton.backgroundColor = RGBColor(204, 204, 204);
    }
}
#pragma mark -- 判断是否所有数据均已忽略、处理完毕
-(BOOL)allDataHaveIgnored
{
    NSInteger n = 0;
    for (UnfinishedModel * model in self.sourceArray) {
        if (model.personModel.ignored) {
            n++;
        }
    }
    return n == self.sourceArray.count;
}

#pragma mark - 顶部按钮相关操作
#pragma mark -- 顶部按钮点击后动态效果
//顶部按钮栏”滑块“移动处理方法
//顶部按钮栏 按钮title处理方法
-(void)handleTopButtonsLayoutWithIndex:(NSInteger)index
{
    weakObjc(self);
    [UIView animateWithDuration:0.2 animations:^{
        [weakself.scrollLiveView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakself.topView).offset(index*SCREEN_W/3.0+(SCREEN_W/3.0-scrollline_w)/2.0);
        }];
        [weakself.scrollLiveView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        weakself.allBtn.selected = index == 0;
        weakself.allBtn.titleLabel.font = index == 0 ? [UIFont systemFontOfSize:16] : [UIFont systemFontOfSize:14];
        
        weakself.waitingBtn.selected = index == 1;
        weakself.waitingBtn.titleLabel.font = index == 1 ? [UIFont systemFontOfSize:16] : [UIFont systemFontOfSize:14];
        
        weakself.processingBtn.selected = index == 2;
        weakself.processingBtn.titleLabel.font = index == 2 ? [UIFont systemFontOfSize:16] : [UIFont systemFontOfSize:14];
    }];
}

#pragma mark -- 设置 顶部按钮 点击后所对应的 title
-(void)handleTopButtonsTitle
{
    [self.allBtn setTitle:[NSString stringWithFormat:@" 全部（%ld)",[self numberWithType:nil]] forState:UIControlStateNormal];
    [self.waitingBtn setTitle:[NSString stringWithFormat:@" 待量体（%ld)",[self numberWithType:@"0"]] forState:UIControlStateNormal];
    [self.processingBtn setTitle:[NSString stringWithFormat:@" 进行中（%ld)",[self numberWithType:@"1"]] forState:UIControlStateNormal];
}

#pragma mark -- 获取各个量体状态下，数据所对应的数量
-(NSInteger)numberWithType:(NSString *)type
{
    NSInteger number = 0;
    if (type.length == 0) {
        number = self.allArray.count;
    } else {
        number = [type isEqualToString:@"0"] ? self.waitingArray.count : self.processingArray.count;
    }
    return number;
}

#pragma mark - tableview Delegate & DataSource
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UnfinishedModel * model = _dataArray[indexPath.row];
    if (_edit) {
        model.selected = !model.selected;
        [self handleLeftButton];
        [self handleBottomButton];
        [self.tableview reloadData];
    } else {
        PersonDetailContainerViewController *detailViewController = [[PersonDetailContainerViewController alloc] init];
        detailViewController.personModel = model.personModel;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * ID = @"personnelCell";
    UnfinishedCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UnfinishedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UnfinishedModel * model = [self.dataArray objectAtIndex:indexPath.row];
    [cell cellWithData:model multSelect:_edit];
    return cell;
}

#pragma mark - tableview cell 左滑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return !_edit;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    weakObjc(self);
    UnfinishedModel * model = _dataArray[indexPath.row];
    NSString * title = model.personModel.ignored ? @"恢复":@"忽略";
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        model.personModel.ignored = !model.personModel.ignored;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [weakself.tableview reloadData];
    }];
    if (!model.personModel.ignored) {
        action.backgroundColor = RGBColor(255, 0, 0);
    } else {
        action.backgroundColor = skyColor;
    }
    return @[action];
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
