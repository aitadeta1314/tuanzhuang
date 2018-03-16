//
//  consultViewController.m
//  tuanzhuang
//
//  Created by red on 2018/1/22.
//  Copyright © 2018年 red. All rights reserved.
//

#import "consultViewController.h"
#import "personnelCell.h"

@interface consultViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UINavigationControllerDelegate,ZZNumberFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet ZZNumberField *searchTextfield;
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIView * maskLayerView;//搜索时出现的遮罩层

@property (strong, nonatomic) NSMutableArray * dataArray;
@end

@implementation consultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"参照他人";
    [self addBackButton];
    weakObjc(self);
    /*顶部搜索框相关布局--外部view*/
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.view).with.mas_offset(TOPNAVIGATIONBAR_H);
        make.left.mas_equalTo(weakself.view);
        make.right.mas_equalTo(weakself.view);
        make.height.mas_equalTo(TOPVIEW_H);
    }];
    self.topView.backgroundColor = RGBColor(212, 212, 212);
    
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
    [self.cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.searchTextfield);
        make.left.mas_equalTo(weakself.searchTextfield.mas_right).with.offset(SEARCH_X);
        make.width.mas_equalTo(CANCLE_W);
        make.bottom.mas_equalTo(weakself.searchTextfield);
    }];
    
    /*tableview布局*/
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.topView.mas_bottom);
        make.left.mas_equalTo(weakself.view);
        make.bottom.mas_equalTo(weakself.view);
        make.right.mas_equalTo(weakself.view);
    }];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sectionIndexColor = RGBColor(125, 125, 125);
    
    /*搜索时遮罩层初始布局*/
    [self.maskLayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.view).offset(TOPVIEW_H+TOPNAVIGATIONBAR_H);
        make.left.mas_equalTo(weakself.view);
        make.bottom.mas_equalTo(weakself.view);
        make.right.mas_equalTo(weakself.view);
    }];
    self.maskLayerView.hidden = YES;
}

#pragma mark - 数据处理
#pragma mark -- 懒加载
-(NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        NSPredicate *peopleFilter = [NSPredicate predicateWithFormat:@"status = 2 AND companyid = %@", self.companymodel.companyid];
        NSFetchRequest *peopleRequest = [PersonnelModel MR_requestAllWithPredicate:peopleFilter];
        [peopleRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstletter"ascending:YES]]];
        _dataArray = [NSMutableArray arrayWithArray:[self handleData:[PersonnelModel MR_executeFetchRequest:peopleRequest]]];
    }
    return _dataArray;
}

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
    [self datasWithSearchCondition:_searchTextfield.text];
}

#pragma mark - 按钮、手势方法
//”取消“搜索 按钮方法
- (IBAction)cancleSearchAction:(UIButton *)sender {
    [self operationCancelBtnWhenSearch:NO];
    _searchTextfield.text = @"";
    [_searchTextfield resignFirstResponder];
}

#pragma mark - 搜索数据
-(void)datasWithSearchCondition:(NSString *)condition
{
    [self.dataArray removeAllObjects];
    NSPredicate *peopleFilter;
    if (condition.length > 0) {
        peopleFilter = [NSPredicate predicateWithFormat:@"status = 2 AND name CONTAINS %@ AND companyid = %@", condition, self.companymodel.companyid];
    } else {
        peopleFilter = [NSPredicate predicateWithFormat:@"status = 2 AND companyid = %@", self.companymodel.companyid];
    }
    
    NSFetchRequest *peopleRequest = [PersonnelModel MR_requestAllWithPredicate:peopleFilter];
    [peopleRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstletter"ascending:YES]]];
    _dataArray = [NSMutableArray arrayWithArray:[self handleData:[PersonnelModel MR_executeFetchRequest:peopleRequest]]];
    
    [self.tableView reloadData];
}

#pragma mark - tableview delegate & datasource
#pragma mark -- 索引相关
//索引数组('A'-'Z')
-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray * indexArray = [[NSMutableArray alloc]init];
    
    for(char c = 'A';c<='Z';c++)
    {
        [indexArray addObject:[NSString stringWithFormat:@"%c",c]];
    }
    return indexArray;
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
    return 25;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerview = [[UIView alloc] init];
    UILabel * titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 50, 25)];
    titlelabel.text = [self.dataArray[section] valueForKey:@"firstletter"];
    headerview.backgroundColor = RGBColor(204, 204, 204);
    [headerview addSubview:titlelabel];
    return headerview;
}

#pragma mark -- tableview基本代理方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * array = [[self.dataArray objectAtIndex:indexPath.section] valueForKey:@"data"];
    PersonnelModel *model = [array objectAtIndex:indexPath.row];
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"您确定要参考%@的数据？",model.name] preferredStyle:UIAlertControllerStyleAlert];
    
    weakObjc(self);
    
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (weakself.copyPersonBlock) {
            weakself.copyPersonBlock(model);
            [weakself.navigationController popViewControllerAnimated:YES];
        }
        
    }];
    [sureAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alert addAction:cancleAction];
    [alert addAction:sureAction];
    [self presentViewController:alert animated:YES completion:nil];
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
