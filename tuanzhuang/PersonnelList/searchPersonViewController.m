//
//  searchPersonViewController.m
//  tuanzhuang
//
//  Created by red on 2017/12/6.
//  Copyright © 2017年 red. All rights reserved.
//

#import "searchPersonViewController.h"
#import "personnelCell.h"
#import "PersonDetailContainerViewController.h"

static const CGFloat cellheight = 84;

@interface searchPersonViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UINavigationControllerDelegate,ZZNumberFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet ZZNumberField *searchTextfield;
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;
@property (weak, nonatomic) IBOutlet UIView *shadowLineView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIView * maskLayerView;//搜索时出现的遮罩层
@property (nonatomic, strong) UILabel * noticeLabel;/**<搜索结果提示语*/
@property (strong, nonatomic) NSMutableArray * dataArray;

@end

@implementation searchPersonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.delegate = self;
    
    weakObjc(self);
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.view).offset(STATUSBAR_H);
        make.left.mas_equalTo(weakself.view);
        make.right.mas_equalTo(weakself.view);
        make.height.mas_equalTo(TOPVIEW_H);
    }];

    [self.searchTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.topView).offset(SEARCH_Y);
        make.left.mas_equalTo(weakself.topView).offset(SEARCH_X);
        make.height.mas_equalTo(SEARCH_H);
        make.right.mas_equalTo(weakself.cancleBtn.mas_left).offset(-SEARCH_X);
    }];
    self.searchTextfield.layer.cornerRadius = 5;
    self.searchTextfield.delegate = self;
    self.searchTextfield.numDelegate = self;
    self.searchTextfield.clearButtonMode = UITextFieldViewModeAlways;
    UIView * leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 20)];
    self.searchTextfield.leftView = leftView;
    self.searchTextfield.leftViewMode = UITextFieldViewModeAlways;
    self.searchTextfield.keyboard = KEYBOARDTYPE_WRITINGPAD;
    self.searchTextfield.inputAccessoryView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.searchTextfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    [self.cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.searchTextfield);
        make.right.mas_equalTo(weakself.topView.mas_right).offset(-SEARCH_X);
        make.width.mas_equalTo(CANCLE_W);
        make.height.mas_equalTo(SEARCH_H);
    }];
    
    [self.shadowLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.topView.mas_bottom);
        make.left.mas_equalTo(weakself.topView);
        make.right.mas_equalTo(weakself.topView);
        make.height.mas_equalTo(1);
    }];
    self.shadowLineView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    self.shadowLineView.layer.shadowOffset = CGSizeMake(0,0);//shadowOffset阴影偏移,x向右偏移，y向下偏移，默认(0, -3),这个跟shadowRadius配合使用
    self.shadowLineView.layer.shadowOpacity = 0.3;//阴影透明度，默认0
    self.shadowLineView.layer.shadowRadius = 2;//阴影半径，默认3
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.shadowLineView.mas_bottom).offset(2);
        make.left.mas_equalTo(weakself.view);
        make.bottom.mas_equalTo(weakself.view);
        make.right.mas_equalTo(weakself.view);
    }];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.maskLayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.view).offset(TOPVIEW_H+STATUSBAR_H);
        make.left.equalTo(weakself.view);
        make.bottom.equalTo(weakself.view);
        make.right.equalTo(weakself.view);
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchTextfield becomeFirstResponder];
}

#pragma mark - 搜索数据
-(void)datasWithSearchCondition:(NSString *)condition
{
    NSPredicate *peopleFilter;
    if (condition.length > 0) {
        peopleFilter = [NSPredicate predicateWithFormat:@"name CONTAINS %@ AND companyid = %@", condition, self.companymodel.companyid];
    } else {
        peopleFilter = [NSPredicate predicateWithFormat:@"companyid = %@", self.companymodel.companyid];
    }
    
    NSFetchRequest *peopleRequest = [PersonnelModel MR_requestAllWithPredicate:peopleFilter];
    [peopleRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstletter"ascending:YES]]];
    self.dataArray = [NSMutableArray arrayWithArray:[PersonnelModel MR_executeFetchRequest:peopleRequest]];
    [self.tableView reloadData];
}

#pragma mark - 初始化数据
-(NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

#pragma mark - 懒加载
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

-(UILabel *)noticeLabel
{
    if (_noticeLabel == nil) {
        _noticeLabel = [[UILabel alloc] init];
        _noticeLabel.textColor = [UIColor whiteColor];
        _noticeLabel.textAlignment = NSTextAlignmentCenter;
        _noticeLabel.font = [UIFont systemFontOfSize:16];
        [self.maskLayerView addSubview:_noticeLabel];
        [_noticeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.maskLayerView).offset(40);
            make.left.equalTo(self.maskLayerView);
            make.right.equalTo(self.maskLayerView);
        }];
    }
    return _noticeLabel;
}

#pragma mark - 私有方法
//显示遮罩层
-(void)showMasklayerView
{
    weakObjc(self);
    [self.maskLayerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.view).offset(TOPVIEW_H+STATUSBAR_H);
    }];
}

//隐藏遮罩层
-(void)hideMasklayerView
{
    weakObjc(self);
    [self.maskLayerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.view).offset(SCREEN_H);
    }];
}

#pragma mark - ZZNumberFieldDelegate
- (void)didSearchClicked {
    [self.searchTextfield resignFirstResponder];
    [self datasWithSearchCondition:self.searchTextfield.text];
    if (self.dataArray.count > 0) {
        [self hideMasklayerView];
        self.noticeLabel.text = @"";
    } else {
        self.noticeLabel.text = @"未搜到相关人员";
    }
    
}

#pragma mark - textfield delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self showMasklayerView];
    return YES;
}

#pragma mark - tableview delegate & datasource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellheight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * ID = @"personnelCell";
    personnelCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[personnelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    PersonnelModel * model = [self.dataArray objectAtIndex:indexPath.row];
    [cell cellWithData:model linehide:NO needoffset:YES];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    PersonDetailContainerViewController * detailVC = [[PersonDetailContainerViewController alloc] init];
    PersonnelModel *model = [_dataArray objectAtIndex:indexPath.row];
    detailVC.personModel = model;
    detailVC.companyModel = self.companymodel;
    [self.navigationController pushViewController:detailVC animated:YES];
    NSMutableArray * vcsArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [vcsArray removeObjectAtIndex:vcsArray.count-2];
    self.navigationController.viewControllers = vcsArray;
}

#pragma mark - UINavigationControllerDelegate
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
}

- (void)dealloc {
    self.navigationController.delegate = nil;
}

#pragma mark - 按钮、手势方法
- (IBAction)cancleBtnAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
