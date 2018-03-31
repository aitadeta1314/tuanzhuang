//
//  PersonnelListViewController.m
//  tuanzhuang
//
//  Created by red on 2017/12/4.
//  Copyright © 2017年 red. All rights reserved.
//

#import "PersonnelListViewController.h"
#import "personnelCell.h"
#import "searchPersonViewController.h"
#import "PersonDetailContainerViewController.h"
#import "SynchronizeData.h"
#import "NSManagedObject+Coping.h"

static const NSInteger TOPBUTTONS_TAG = 1000;
static const CGFloat topview_h = 48.0;

static const CGFloat scrollline_h = 5.0;
static const CGFloat scrollline_w = 50.0;

@interface PersonnelListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *allBtn;
@property (weak, nonatomic) IBOutlet UIButton *waitingBtn;
@property (weak, nonatomic) IBOutlet UIButton *processingBtn;
@property (weak, nonatomic) IBOutlet UIButton *finishedBtn;
@property (weak, nonatomic) IBOutlet UIView *scrollLiveView;
@property (weak, nonatomic) IBOutlet UIButton * xinjianBtn;

@property (strong, nonatomic) NSMutableArray * dataArray;
@property (nonatomic, strong) NSMutableArray * indexArray;/**<索引数组*/
@property (nonatomic, strong) NSMutableArray * allArray;/**<全部*/
@property (nonatomic, strong) NSMutableArray * waitingArray;/**<待量体*/
@property (nonatomic, strong) NSMutableArray * processingArray;/**<进行中*/
@property (nonatomic, strong) NSMutableArray * finishedArray;/**<已完成*/

@property (nonatomic, assign) NSInteger datatype;/**<数据类型：0全部；1待量体；2进行中；3已完成*/

@end

@implementation PersonnelListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self addBackButton];
    [self addRightButtonWithImage:@"search"];
    
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
    }];
    self.processingBtn.tag = TOPBUTTONS_TAG+2;
    
    //”已完成“按钮布局
    [self.finishedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.topView);
        make.left.mas_equalTo(weakself.processingBtn.mas_right);
        make.width.mas_equalTo(weakself.processingBtn);
        make.bottom.mas_equalTo(weakself.topView);
        make.right.mas_equalTo(weakself.topView);
    }];
    self.finishedBtn.tag = TOPBUTTONS_TAG+3;
    
    //滚动线条布局
    [self.scrollLiveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.topView.mas_bottom).offset(-scrollline_h);
        make.width.mas_equalTo(scrollline_w);
        make.left.mas_equalTo(weakself.topView).offset((SCREEN_W/4-scrollline_w)/2.0);
        make.height.mas_equalTo(scrollline_h);
    }];
    self.scrollLiveView.layer.cornerRadius = scrollline_h/2.0;
    
    //tableview布局
    [self.tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.topView.mas_bottom);
        make.left.mas_equalTo(weakself.view);
        make.bottom.mas_equalTo(weakself.xinjianBtn.mas_top);
        make.right.mas_equalTo(weakself.view);
    }];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionIndexColor = RGBColor(125, 125, 125);
    
    //"新建数据"按钮布局
    [self.xinjianBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.view);
        make.bottom.mas_equalTo(weakself.view);
        make.right.mas_equalTo(weakself.view);
        make.height.mas_equalTo(60);
    }];
    _datatype = 0;
    
    //清除无用的缓存数据
    [[CommonData shareCommonData] clearTempPersonDataByCompany:self.companymodel];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //获取公司所有人员基本信息数组
    [self handleButtonTitle];
    [self.tableview reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _dataArray = nil;
    _allArray = nil;
    _waitingArray = nil;
    _processingArray = nil;
    _finishedArray = nil;
}

#pragma mark - 懒加载、数组初始化
#pragma mark -- 数据源数组
-(NSMutableArray *)dataArray
{
    switch (_datatype) {
        case 0:
            _dataArray = self.allArray;
            break;
        case 1:
            _dataArray = self.dailiangtiArray;
            break;
        case 2:
            _dataArray = self.jinxingArray;
            break;
        default:
            _dataArray = self.wanchengArray;
            break;
    }
    return _dataArray;
}

#pragma mark -- "全部"数组
-(NSMutableArray *)allArray
{
    if (_allArray == nil) {
        _allArray = [NSMutableArray arrayWithArray:[self typerArray:-1]];
    }
    return _allArray;
}

#pragma mark -- "待量体"数组
-(NSMutableArray *)dailiangtiArray
{
    if (_waitingArray == nil) {
        _waitingArray = [NSMutableArray arrayWithArray:[self typerArray:0]];
    }
    return _waitingArray;
}

#pragma mark -- "进行中"数组
-(NSMutableArray *)jinxingArray
{
    if (_processingArray == nil) {
        _processingArray = [NSMutableArray arrayWithArray:[self typerArray:1]];
    }
    return _processingArray;
}

#pragma mark -- "已完成"数组
-(NSMutableArray *)wanchengArray
{
    if (_finishedArray == nil) {
        _finishedArray = [NSMutableArray arrayWithArray:[self typerArray:2]];
    }
    return _finishedArray;
}

-(NSArray *)typerArray:(int)type
{
    NSPredicate *peopleFilter;
    switch (type) {
        case 0:
        {
            peopleFilter = [NSPredicate predicateWithFormat:@"status = 0 AND company = %@", self.companymodel];
        }
            break;
        case 1:
        {
            peopleFilter = [NSPredicate predicateWithFormat:@"status = 1 AND company = %@", self.companymodel];
        }
            break;
        case 2:
        {
            peopleFilter = [NSPredicate predicateWithFormat:@"status = 2 AND company = %@", self.companymodel];
        }
            break;
        default:
        {
            peopleFilter = [NSPredicate predicateWithFormat:@"company = %@", self.companymodel];
        }
            break;
    }
    NSFetchRequest *peopleRequest = [PersonnelModel MR_requestAllWithPredicate:peopleFilter];
    NSSortDescriptor * sort0 = [NSSortDescriptor sortDescriptorWithKey:@"firstletter"ascending:YES];
    NSSortDescriptor * sort1 = [NSSortDescriptor sortDescriptorWithKey:@"name"ascending:NO];
    NSArray * sortDescriptors = @[sort0,sort1];
    [peopleRequest setSortDescriptors:sortDescriptors];
    return [self handleData:[PersonnelModel MR_executeFetchRequest:peopleRequest]];
}

#pragma mark -- 索引数组
-(NSMutableArray *)indexArray
{
    _indexArray = [[NSMutableArray alloc] init];
    for (NSDictionary * dic in self.dataArray) {
        NSString *filterLetter = [dic valueForKey:@"firstletter"];
        
        if (filterLetter.isValidString) {
            [_indexArray addObject:filterLetter];
        }
        
    }
    return _indexArray;
}

#pragma mark - 数据处理
#pragma mark -- 将数据按姓名首字母分组
-(NSArray *)handleData:(NSArray *)personArray
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    NSMutableArray * tmpArray = [NSMutableArray arrayWithArray:personArray];
    while (tmpArray.count > 0) {
        NSMutableDictionary * groupdic = [[NSMutableDictionary alloc] init];
        int k = 0;
        int q = k+1;
        PersonnelModel * pmodel_k = tmpArray[k];
        [groupdic setValue:pmodel_k.firstletter forKey:@"firstletter"];
        for (int i = q; i < tmpArray.count; i++) {
            PersonnelModel * pmodel_i = tmpArray[i];
            if (![pmodel_k.firstletter isEqualToString:pmodel_i.firstletter]) {
                break;
            }
            q++;
        }
        NSArray * subarray = [NSArray arrayWithArray:[tmpArray subarrayWithRange:NSMakeRange(k, q-k)]];
        [groupdic setValue:subarray forKey:@"data"];
        [array addObject:groupdic];
        [tmpArray removeObjectsInRange:NSMakeRange(k, q-k)];
    }
    return array;
}

#pragma mark - 重写父类方法
-(void)rightButtonPress
{
    searchPersonViewController * searchVC = VCFromBundleWithIdentifier(@"searchPersonViewController");
    searchVC.companymodel = self.companymodel;
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark - tableview delegate & datasource
#pragma mark -- 索引相关
//索引数组('A'-'Z')
-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.indexArray;
}

//索引title
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *dict = self.dataArray[section];
    NSString *title = dict[@"firstletter"];
    return title;
}

//点击索引方法
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([title isEqualToString:UITableViewIndexSearch])
    {
        [tableView setContentOffset:CGPointZero animated:NO];//tabview移至顶部
        return NSNotFound;
    } else {
        [tableView setEditing:NO];
        [self showHUDMessage:title andDelay:0.2];
        for (int i = 0; i < self.dataArray.count; i++) {
            NSDictionary * dict = self.dataArray[i];
            if ([[dict valueForKey:@"firstletter"] isEqualToString:title]) {
                return i;
            }
        }
        return NSNotFound;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerview = [[UIView alloc] init];
    UILabel * titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 50, 20)];
    titlelabel.text = [self.dataArray[section] valueForKey:@"firstletter"];
    titlelabel.font = [UIFont systemFontOfSize:16];
    headerview.backgroundColor = RGBColor(204, 204, 204);
    [headerview addSubview:titlelabel];
    return headerview;
}

#pragma mark -- tableview基本代理方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonDetailContainerViewController *detailViewController = [[PersonDetailContainerViewController alloc] init];
    
    NSArray * array = [[self.dataArray objectAtIndex:indexPath.section] valueForKey:@"data"];
    PersonnelModel *model = [array objectAtIndex:indexPath.row];
    
    detailViewController.personModel = model;
    detailViewController.companyModel = self.companymodel;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * array = [self.dataArray[section] valueForKey:@"data"];
    return array.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * ID = @"personnelCell";
    personnelCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[personnelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray * array = [[self.dataArray objectAtIndex:indexPath.section] valueForKey:@"data"];
    PersonnelModel * model = [array objectAtIndex:indexPath.row];
    [cell cellWithData:model linehide:array.count-1 == indexPath.row needoffset:NO];
    return cell;
}

#pragma mark -- cell左滑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    weakObjc(self);
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"创建副本" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSArray * array = [[self.dataArray objectAtIndex:indexPath.section] valueForKey:@"data"];
        PersonnelModel * pmodel = [array objectAtIndex:indexPath.row];
        
        PersonDetailContainerViewController *detailViewController = [[PersonDetailContainerViewController alloc] init];
        detailViewController.companyModel = self.companymodel;
        detailViewController.personModel = nil;
        detailViewController.personModel_copy = pmodel;
        [weakself.navigationController pushViewController:detailViewController animated:YES];
    }];
    action.backgroundColor = RGBColor(0, 122, 255);
    return @[action];
}

#pragma mark - 按钮、手势方法
//顶部按钮点击方法
- (IBAction)topBtnAction:(UIButton *)sender {
    NSInteger index = sender.tag - TOPBUTTONS_TAG;
    [self handleTopButtonsLayoutWithIndex:index];
    _datatype = index;
    [self.tableview reloadData];
}

- (IBAction)xinjianBtnAction:(UIButton *)sender {
    PersonDetailContainerViewController *detailViewController = [[PersonDetailContainerViewController alloc] init];
    detailViewController.companyModel = self.companymodel;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - 顶部按钮相关操作
#pragma mark -- 顶部按钮点击效果
-(void)handleTopButtonsLayoutWithIndex:(NSInteger)index
{
    weakObjc(self);
    [UIView animateWithDuration:0.2 animations:^{
        [weakself.scrollLiveView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakself.topView).offset(index*SCREEN_W/4.0+(SCREEN_W/4-scrollline_w)/2.0);
        }];
        [weakself.scrollLiveView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        weakself.allBtn.selected = index == 0;
        weakself.allBtn.titleLabel.font = index == 0 ? [UIFont systemFontOfSize:16] : [UIFont systemFontOfSize:14];
        
        weakself.waitingBtn.selected = index == 1;
        weakself.waitingBtn.titleLabel.font = index == 1 ? [UIFont systemFontOfSize:16] : [UIFont systemFontOfSize:14];
        
        weakself.processingBtn.selected = index == 2;
        weakself.processingBtn.titleLabel.font = index == 2 ? [UIFont systemFontOfSize:16] : [UIFont systemFontOfSize:14];
        
        weakself.finishedBtn.selected = index == 3;
        weakself.finishedBtn.titleLabel.font = index == 3 ? [UIFont systemFontOfSize:16] : [UIFont systemFontOfSize:14];
    }];
}

#pragma mark -- 顶部按钮 title
-(void)handleButtonTitle
{
    [self.allBtn setTitle:[NSString stringWithFormat:@" 全部（%ld)",[self numberWithType:nil]] forState:UIControlStateNormal];
    [self.waitingBtn setTitle:[NSString stringWithFormat:@" 待量体（%ld)",[self numberWithType:@"0"]] forState:UIControlStateNormal];
    [self.processingBtn setTitle:[NSString stringWithFormat:@" 进行中（%ld)",[self numberWithType:@"1"]] forState:UIControlStateNormal];
    [self.finishedBtn setTitle:[NSString stringWithFormat:@" 已完成（%ld)",[self numberWithType:@"2"]] forState:UIControlStateNormal];
}

#pragma mark -- 获取各个状态对应的数量
-(NSInteger)numberWithType:(NSString *)type
{
    NSInteger number = 0;
    NSPredicate *doneFilter;
    if ([type isEqualToString:@"0"]) {
        doneFilter = [NSPredicate predicateWithFormat:@"status  == 0 AND company == %@",self.companymodel];
    } else if ([type isEqualToString:@"1"]) {
        doneFilter = [NSPredicate predicateWithFormat:@"status  == 1 AND company == %@",self.companymodel];
    } else if ([type isEqualToString:@"2"]) {
        doneFilter = [NSPredicate predicateWithFormat:@"status  == 2 AND company == %@",self.companymodel];
    } else {
        doneFilter = [NSPredicate predicateWithFormat:@"company == %@",self.companymodel];
    }
    number = [PersonnelModel MR_findAllWithPredicate:doneFilter].count;
    return number;
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
