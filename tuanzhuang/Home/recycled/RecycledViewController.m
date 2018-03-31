//
//  RecycledViewController.m
//  tuanzhuang
//
//  Created by Fenly on 2018/3/26.
//  Copyright © 2018年 red. All rights reserved.
//

#import "RecycledViewController.h"
#import "RecycledCollectionViewCell.h"

#define recycledCellIdentify  @"recycledCollectionCellIdentify"
#define bottomViewHeight         60  // 底部view高度

@interface RecycledViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, ZZNumberFieldDelegate>

/**
 collectionView
 */
@property (nonatomic, strong) UICollectionView *collectionView;
/**
 数据源数组
 */
@property (nonatomic, strong) NSMutableArray *dataSource;
/**
 右上角显示选择（NO,表示没有选择），取消（YES,表示正在选择）
 */
@property (assign, nonatomic) BOOL toSelect;
/**
 底部view
 */
@property (nonatomic, strong) UIView *bottomView;
/**
 全部删除
 */
@property (nonatomic, strong) UIButton *deleteAllBtn;
/**
 全部恢复
 */
@property (nonatomic, strong) UIButton *recoverBtn;
/**
 选中的文档个数
 */
@property (nonatomic, assign) NSInteger selectedFileNumber;
/**
 搜索模块
 */
@property (nonatomic, strong) UIView *topView;
@property (strong, nonatomic) ZZNumberField *searchTextfield;
@property (nonatomic, strong) UIButton *cancleBtn;
@property (strong, nonatomic) UILabel *unSearchLb;
@end

@implementation RecycledViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"回收站";
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.toSelect = NO;
    self.selectedFileNumber = 0;
    [self layoutViewForPage];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self addArray];
}

- (void)layoutViewForPage {
    [self.view addSubview:self.topView];
    [self.topView addSubview:self.searchTextfield];
    [self.topView addSubview:self.cancleBtn];
    [self layoutRightBarButtonItem];
    [self layoutCollectionView];
    [self.view addSubview:self.unSearchLb];
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.deleteAllBtn];
    [self.bottomView addSubview:self.recoverBtn];
}

- (void)addArray {
    [self.dataSource removeAllObjects];
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"del == YES"];
    NSFetchRequest * request = [CompanyModel MR_requestAllWithPredicate:filter];
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"delTime" ascending:NO];
    [request setSortDescriptors:@[sort]];
    NSArray * companyarray = [CompanyModel MR_executeFetchRequest:request];
    if (companyarray.count == 0) {
        return;
    }
    
    for ( int i = 0; i<companyarray.count; i++) {
        HomeModel *model = [[HomeModel alloc] init];
        model.companyModel = companyarray[i];
        model.isSelected = NO;
        [self.dataSource addObject:model];
    }
    [self.collectionView reloadData];
    
}

- (void)layoutRightBarButtonItem {
    [self addRightButtonWithTitle:@"选择"];
}

/**
 布局collectionView
 */
- (void)layoutCollectionView {
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    // collectionview
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, TOPVIEW_H, SCREEN_W, SCREEN_H-TOPVIEW_H-TOPNAVIGATIONBAR_H) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"RecycledCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:recycledCellIdentify];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
}

#pragma mark - <UICollectionViewDelegate,UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RecycledCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:recycledCellIdentify forIndexPath:indexPath];
    cell.homeModel = self.dataSource[indexPath.row];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    HomeModel *model = self.dataSource[indexPath.row];
    if (self.toSelect) {
        // 选择状态  更新HomeModel中isSelected字段
        model.isSelected = !model.isSelected;
        [self.collectionView reloadData];
        self.title = [NSString stringWithFormat:@"已选中%ld个文档",self.selectedFileNumber];
    } else {
        // 未选择状态 直接弹框
        [self recoverWithCompanymodel:model];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(0.272*SCREEN_W, 0.272*SCREEN_W);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.046*SCREEN_W;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.046*SCREEN_W, 0.046*SCREEN_W, 0.046*SCREEN_W, 0.046*SCREEN_W);
}
#pragma mark - 重写父类方法
- (void)rightButtonPress {
    self.toSelect = !self.toSelect;
    if (self.toSelect) {
        [self changeRightButtonTile:@"取消"];
        // 弹出bottomView
        [UIView animateWithDuration:0.5 animations:^{
            self.bottomView.frame = CGRectMake(0, CGRectGetMaxY(self.collectionView.frame)-bottomViewHeight, SCREEN_W, bottomViewHeight);
        } completion:^(BOOL finished) {
            
        }];
    } else {
        self.selectedFileNumber = 0;
        self.title = @"回收站";
        [self changeRightButtonTile:@"选择"];
        for (HomeModel *homeModel in self.dataSource) {
            homeModel.isSelected = NO;
        }
        [self.collectionView reloadData];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.bottomView.frame = CGRectMake(0, CGRectGetMaxY(self.collectionView.frame), SCREEN_W, bottomViewHeight);
        } completion:^(BOOL finished) {
            [self.deleteAllBtn setTitle:@"全部删除" forState:UIControlStateNormal];
            [self.recoverBtn setTitle:@"全部恢复" forState:UIControlStateNormal];
        }];
    }
}
#pragma mark - 私有方法
-(void)changeRightButtonTile:(NSString *)title
{
    [self removeRightBtn];
    [self addRightButtonWithTitle:title];
}

#pragma mark -- 获取已选中元素的数量
-(NSInteger)selectedFileNumber
{
    _selectedFileNumber = 0;
    for (HomeModel *homeModel in self.dataSource) {
        if (homeModel.isSelected) {
            _selectedFileNumber ++;
        }
    }
    [self.deleteAllBtn setTitle:_selectedFileNumber == 0?@"全部删除":@"删除" forState:UIControlStateNormal];
    [self.recoverBtn setTitle:_selectedFileNumber == 0?@"全部恢复":@"恢复" forState:UIControlStateNormal];
    return _selectedFileNumber;
}

#pragma mark -- “恢复”操作之前的“重复”验证操作
//批量恢复时，要考虑两种重复情况:1)所选的元素彼此间是否重复；2)所选的元素是否与任务列表的数据重复。
//批量恢复时，判断已选择的数据中是否有重复的，all==yes，是全部恢复；all==no是批量恢复
-(BOOL)checkRepeatInDataSourceAll:(BOOL)all
{
    NSMutableArray * tempArray = [[NSMutableArray alloc] init];
    for (HomeModel *homeModel in self.dataSource) {
        if (all || homeModel.isSelected) {
            for (HomeModel * tempModel in tempArray) {
                if ([homeModel.companyModel.companyid isEqualToString:tempModel.companyModel.companyid]) {
                    return YES;
                }
            }
            [tempArray addObject:homeModel];
        }
    }
    return NO;
}

//批量恢复时，判断“Home”页任务列表里是否有重复的
-(BOOL)checkRepeatInMissionListAll:(BOOL)all
{
    for (HomeModel *homeModel in self.dataSource) {
        if (all || homeModel.isSelected) {
            if ([self checkRepeatInMissionListWithCompanyid:homeModel.companyModel.companyid]) {
                return YES;
            }
        }
    }
    return NO;
}

//单项恢复时，判断“Home”页任务列表里是否有重复的
-(BOOL)checkRepeatInMissionListWithCompanyid:(NSString *)companyid
{
    NSInteger number = [CompanyModel MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"del == NO AND companyid = %@",companyid]];
    return number > 0;
}

#pragma mark -- “恢复”操作
//批量"恢复"操作：all==yes，是全部恢复；all==no是批量恢复
-(void)recoverBatchHandleAll:(BOOL)all
{
    //验证重复
    BOOL isrepeat = NO;
    NSString * title = @"恢复";
    NSString * message = all ? @"全部文档" : [NSString stringWithFormat:@"恢复选中的%ld个文档",self.selectedFileNumber];
    NSString * noTitle = @"否";
    NSString * yesTitle = @"是";
    if ([self checkRepeatInDataSourceAll:all]) {
        isrepeat = YES;
        title = @"恢复失败";
        message = @"选中文档存在重名文档!";
        yesTitle = @"确定";
    } else if ([self checkRepeatInMissionListAll:all]) {
        isrepeat = YES;
        title = @"恢复失败";
        message = @"任务列表中已存在该文档，请删除已存在的文档后再进行恢复操作!";
        yesTitle = @"确定";
    }
    weakObjc(self);
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:noTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:yesTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (!isrepeat) {
            for (int i = 0; i < weakself.dataSource.count; i++) {
                HomeModel *homeModel = weakself.dataSource[i];
                if (all || homeModel.isSelected) {
                    homeModel.companyModel.del = NO;
                    [weakself.dataSource removeObjectAtIndex:i];
                    i--;
                }
            }
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            [weakself.collectionView reloadData];
        }
    }];
    [alertVC addAction:yesAction];
    if (!isrepeat) {
        [alertVC addAction:noAction];
    }
    [self presentViewController:alertVC animated:YES completion:nil];
}

//单项“恢复”操作
-(void)recoverWithCompanymodel:(HomeModel *)homemodel
{
    weakObjc(self);
    //验证重复
    BOOL isrepeat = [self checkRepeatInMissionListWithCompanyid:homemodel.companyModel.companyid];
    //设置alert 标题、提示语、按钮内容
    NSString * title = isrepeat ? @"恢复失败" : @"恢复";
    NSString * message = isrepeat ? @"任务列表中已存在该文档，请删除已存在的文档后再进行恢复操作!" : homemodel.companyModel.missionname;
    NSString * yesTitle = isrepeat ? @"确定" : @"是";
    NSString * noTitle = @"否";
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:noTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:yesTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (!isrepeat) {
            homemodel.companyModel.del = NO;
            [weakself.dataSource removeObject:homemodel];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
        [weakself.collectionView reloadData];
    }];
    [alertVC addAction:yesAction];
    if (!isrepeat) {
        [alertVC addAction:noAction];
    }
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - 懒加载
//初始化数据源数组
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

//底部批处理编辑栏
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.collectionView.frame), SCREEN_W, bottomViewHeight)];
        _bottomView.backgroundColor = systemGrayColor;
    }
    return _bottomView;
}

//“全部删除”按钮
- (UIButton *)deleteAllBtn {
    if (!_deleteAllBtn) {
        _deleteAllBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, 0, 100, CGRectGetHeight(self.bottomView.frame))];
        [_deleteAllBtn addTarget:self action:@selector(deleteAllBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_deleteAllBtn setTitle:@"全部删除" forState:UIControlStateNormal];
        [_deleteAllBtn setTitleColor:SYSTEM_BLUE_COLOR forState:UIControlStateNormal];
        _deleteAllBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    }
    return _deleteAllBtn;
}

//“全部恢复”按钮
- (UIButton *)recoverBtn {
    if (!_recoverBtn) {
        _recoverBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_W - 140, 0, 100, CGRectGetHeight(self.bottomView.frame))];
        [_recoverBtn addTarget:self action:@selector(recoverAllBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_recoverBtn setTitle:@"全部恢复" forState:UIControlStateNormal];
        [_recoverBtn setTitleColor:SYSTEM_BLUE_COLOR forState:UIControlStateNormal];
        _recoverBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    }
    return _recoverBtn;
}

//顶部搜索View
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, TOPVIEW_H)];
        _topView.backgroundColor = RGBColor(204, 204, 204);
    }
    return _topView;
}

//搜索textfield
- (ZZNumberField *)searchTextfield {
    if (!_searchTextfield) {
        _searchTextfield = [[ZZNumberField alloc] initWithFrame:CGRectMake(SEARCH_X, SEARCH_Y, SCREEN_W-2*SEARCH_X, SEARCH_H)];
        _searchTextfield.keyboard = KEYBOARDTYPE_WRITINGPAD;
        _searchTextfield.backgroundColor = RGBColor(255, 255, 255);
        _searchTextfield.layer.cornerRadius = 5;
        _searchTextfield.delegate = self;
        _searchTextfield.numDelegate = self;
        _searchTextfield.clearButtonMode = UITextFieldViewModeAlways;
        _searchTextfield.placeholder = @"搜 索";
        [_searchTextfield setValue:RGBColor(204, 204, 204) forKeyPath:@"_placeholderLabel.textColor"];
        [_searchTextfield setValue:[UIFont boldSystemFontOfSize:16] forKeyPath:@"_placeholderLabel.font"];
        _searchTextfield.textAlignment = NSTextAlignmentCenter;
        UIView * leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 20)];
        _searchTextfield.leftView = leftView;
        _searchTextfield.leftViewMode = UITextFieldViewModeAlways;
        _searchTextfield.inputAccessoryView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _searchTextfield;
}

//取消搜索按钮
- (UIButton *)cancleBtn {
    if (!_cancleBtn) {
        _cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_W-CANCLE_W-SEARCH_X, CGRectGetMinY(self.searchTextfield.frame), CANCLE_W, CGRectGetHeight(self.searchTextfield.frame))];
        _cancleBtn.hidden = YES;
        [_cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _cancleBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        [_cancleBtn addTarget:self action:@selector(cancleSearchAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancleBtn;
}

//搜索不到数据提示label
- (UILabel *)unSearchLb {
    if (!_unSearchLb) {
        _unSearchLb = [[UILabel alloc] init];
        _unSearchLb.text = @"未搜到相关公司";
        _unSearchLb.font = [UIFont systemFontOfSize:16];
        _unSearchLb.textAlignment = NSTextAlignmentCenter;
        _unSearchLb.textColor = systemGrayColor;
        _unSearchLb.frame = CGRectMake(0, self.topView.frame.size.height+self.topView.frame.origin.y, SCREEN_W, 50);
        _unSearchLb.hidden = YES;
    }
    return _unSearchLb;
}

#pragma mark - 搜索相关处理
#pragma mark -- textfielddelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self operationCancelBtnWhenSearch:YES];
}

#pragma mark -- ZZNumberFieldDelegate
- (void)didSearchClicked {
    [self addArray];
    [_searchTextfield resignFirstResponder];
    if (self.searchTextfield.text.length > 0) {
        for (NSInteger i = 0; i < self.dataSource.count; i ++) {
            HomeModel *model = self.dataSource[i];
            if (![model.companyModel.missionname containsString:self.searchTextfield.text]) {
                [self.dataSource removeObjectAtIndex:i];
                i--;
            }
        }
    }
    self.unSearchLb.hidden = self.dataSource.count > 0;
    [self.collectionView reloadData];
}
//取消按钮点击方法
- (void)cancleSearchAction {
    [self operationCancelBtnWhenSearch:NO];
    self.searchTextfield.text = @"";
    [self.searchTextfield resignFirstResponder];
    [self addArray];
    self.unSearchLb.hidden = YES;
    [self.collectionView reloadData];
}
//搜索时处理“取消”按钮
-(void)operationCancelBtnWhenSearch:(BOOL)operation
{
    if (operation) {
        //显示“取消”按钮
        [UIView animateWithDuration:0.2 animations:^{
            _searchTextfield.frame = CGRectMake(_searchTextfield.frame.origin.x, _searchTextfield.frame.origin.y, SCREEN_W-2*SEARCH_X-80-5, _searchTextfield.frame.size.height);
        } completion:^(BOOL finished) {
            _cancleBtn.hidden = NO;
        }];
    } else {
        //隐藏“取消”按钮
        _cancleBtn.hidden = YES;
        [UIView animateWithDuration:0.2 animations:^{
            _searchTextfield.frame = CGRectMake(_searchTextfield.frame.origin.x, _searchTextfield.frame.origin.y, _searchTextfield.frame.size.width+80+5, _searchTextfield.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark - 删除、恢复 按钮点击方法
#pragma mark -- 全部删除/批量删除
- (void)deleteAllBtnClick:(UIButton *)sender {
    weakObjc(self);
    BOOL deletAll = [sender.currentTitle isEqualToString:@"全部删除"];
    NSString * title = deletAll ? @"删除全部文档" : [NSString stringWithFormat:@"删除%ld个文档",self.selectedFileNumber];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:@"这些文档将被删除 此操作不可撤销" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (int i = 0; i<weakself.dataSource.count; i++) {
            HomeModel *homeModel = weakself.dataSource[i];
            if (deletAll || homeModel.isSelected) {
                [homeModel.companyModel MR_deleteEntity];
                [weakself.dataSource removeObjectAtIndex:i];
                i--;
            }
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [weakself.collectionView reloadData];
    }];
    [alertVC addAction:yesAction];
    [alertVC addAction:noAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark -- 全部恢复/批量恢复 按钮点击方法
- (void)recoverAllBtnClick:(UIButton *)sender {
    [self recoverBatchHandleAll:[sender.currentTitle isEqualToString:@"全部恢复"]];
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
