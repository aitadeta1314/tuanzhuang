//
//  BodySizeAddtionalViewController.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/27.
//  Copyright © 2017年 red. All rights reserved.
//

#import "BodySizeAddtionalViewController.h"
#import "NSManagedObject+Coping.h"
#import "PersonnelModel+Helper.h"
#import "CategoryModel+Helper.h"
#import "AdditionModel+Helper.h"

#import "AdditionalTableViewCell.h"

@interface BodySizeAddtionalViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic,strong) NSMutableSet *showPickerViews;

@property(nonatomic,strong) NSArray *addtionArray;

@property(nonatomic,strong) NSMutableArray *titleArray;

@end

@implementation BodySizeAddtionalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showPickerViews = [NSMutableSet set];
    [self layoutTableView];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self reloadData];
}

-(void)layoutTableView{
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([AdditionalTableViewCell class]) bundle:nil];
    
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NSStringFromClass([AdditionalTableViewCell class])];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 46, 0, 46);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods

-(void)reloadData{
    
    NSArray *categoryArray = [self.personModel getCategorySizeType:CategorySizeType_Body];
    
    NSMutableArray *tempArray = [NSMutableArray array];
    self.titleArray = [NSMutableArray array];
    
    for (CategoryModel *category in categoryArray) {
        [tempArray addObjectsFromArray:[category.addition sortedArrayUsingDescriptors:@[]]];
        
        NSString *categoryTitle = category.name;
        
        for (int i=0; i<[category.addition count]; i++) {
            [self.titleArray addObject:[NSString stringWithFormat:@"%@%d",categoryTitle,(i+1)]];
        }
    }
    
    self.addtionArray = [NSArray arrayWithArray:tempArray];
    
    [self.tableView reloadData];
    
}

#pragma mark - UITableView DataSource Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.addtionArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AdditionalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AdditionalTableViewCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    AdditionModel *addtion = [self.addtionArray objectAtIndex:indexPath.row];
    
    //配置数据
    [self configAddition:addtion toCell:cell atIndexPath:indexPath];
    
    __weak typeof(self) weakSelf = self;
    
    cell.pickerViewDisplayBlock = ^(BOOL show) {
        [weakSelf pickerViewShow:show atIndexPath:indexPath];
    };
    
    cell.changedBlock = ^(NSArray<AdditionModel *> *changedAdditions) {
        [weakSelf additionValueChangedAction:changedAdditions];
    };
    
    return cell;
}

-(void)configAddition:(AdditionModel *)addition toCell:(AdditionalTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    
    NSString *title = self.titleArray[indexPath.row];
    [cell setTitle:title andAddtionModel:addition];
}

#pragma mark - UITableView Delegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AdditionModel *addtion = self.addtionArray[indexPath.row];
    
    return [AdditionalTableViewCell getCellHeightByAddition:addtion];
}

#pragma mark - ScrollView Delegate Methods
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    NSSet *tempSet = [self.showPickerViews copy];
    
    for (NSNumber *itemNum in tempSet) {
        AdditionalTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[itemNum integerValue] inSection:0]];
        [cell hiddenPickerView];
    }
}

#pragma mark - Cell Helper Methods
-(void)pickerViewShow:(BOOL)show atIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger row = indexPath.row;
    
    if (show) {
        [self.showPickerViews addObject:@(row)];
    }else{
        [self.showPickerViews removeObject:@(row)];
    }
}

#pragma mark - Data Model Operation Methods
-(void)additionValueChangedAction:(NSArray *)additionArray{
    
    NSMutableArray *indexPathArray = [NSMutableArray array];
    
    for (AdditionModel *model in additionArray) {
        NSInteger index = [self.addtionArray indexOfObject:model];
        NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [indexPathArray addObject:_indexPath];
        
        AdditionalTableViewCell *cell = [self.tableView cellForRowAtIndexPath:_indexPath];
        
        [self configAddition:model toCell:cell atIndexPath:_indexPath];
    }
    
    //[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

@end
