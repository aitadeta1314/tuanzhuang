//
//  ClothesSizeViewController.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/28.
//  Copyright © 2017年 red. All rights reserved.
//

#import "ClothesSizeViewController.h"
#import "SizeTableViewCell.h"
#import "PPNumberButton.h"
#import "ClothesCountViewController.h"
#import "ClothesSizeInputView.h"
#import "PositionSizeRangeModel.h"
#import "PersonnelModel+Helper.h"

#import "NSManagedObject+Coping.h"



#define TITLE_FONT [UIFont systemFontOfSize:22.0]
#define DETAIL_FONT [UIFont systemFontOfSize:16.0]

static const CGFloat ClothesCountHeight = 70.0f;

#define EDGE_INSET_TABLE_VIEW UIEdgeInsetsMake(ClothesCountHeight, 1, 0, 486)

@interface ClothesSizeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic,strong) ClothesCountViewController *clothesCountController;

@property(nonatomic,strong) ClothesSizeInputView *sizeInputView;

@property(nonatomic,strong) NSArray *postionsArray;

@property(nonatomic,strong) CategoryModel *currentCategory;

@property(nonatomic,assign) NSInteger selectedIndex;

@property(nonatomic,strong) LockConverView *converView;

@end

@implementation ClothesSizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self layoutClothesCountView];
    [self layoutTableView];
    [self layoutSizeInputView];
    [self layoutConverView];
    
    weakObjc(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself reloadData];
    });
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)layoutConverView{
    
    self.converView = [[LockConverView alloc] init];
    [self.view addSubview:self.converView];
    
    [self.converView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(ClothesCountHeight,0,0,0));
    }];
    
    weakObjc(self);
    self.converView.unLockBlock = ^{
        if (weakself.unLockBlock) {
            weakself.unLockBlock();
        }
    };
    
    self.converView.hidden = !self.showLockView;
    
}

-(void)layoutTableView{
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerClass:[SizeTableViewCell class] forCellReuseIdentifier:NSStringFromClass([SizeTableViewCell class])];
    
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(EDGE_INSET_TABLE_VIEW);
    }];
}

-(void)layoutClothesCountView{
    
    self.clothesCountController = [[ClothesCountViewController alloc] init];
    
    [self.view addSubview:self.clothesCountController.view];
    
    [self.clothesCountController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.offset(0);
        make.height.mas_equalTo(ClothesCountHeight);
    }];
    
    weakObjc(self);
    self.clothesCountController.changedBlock = ^(CategoryModel *category) {
        weakself.currentCategory = category;
        [weakself reloadClothesSizeTableView];
    };
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = COLOR_TABLE_CELL_BORDER;
    
    [self.view addSubview:lineView];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.left.and.right.offset(0);
        make.top.offset(ClothesCountHeight-1);
    }];
    
}

-(void)layoutSizeInputView{
    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ClothesSizeInputView class]) owner:self options:nil];
    
    self.sizeInputView = nibArray[0];
    
    [self.view addSubview:self.sizeInputView];
    
    [self.sizeInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(ClothesCountHeight);
        make.left.equalTo(self.tableView.mas_right);
        make.bottom.and.right.offset(0);
    }];
    
    weakObjc(self);
    self.sizeInputView.changedBlock = ^(NSInteger summerSize, NSInteger winterSize) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakself.selectedIndex inSection:0];
        
        [weakself setPositionSummerSize:summerSize andWinterSize:winterSize AtIndexPath:indexPath];
        [weakself.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    
    UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = COLOR_TABLE_CELL_BORDER;
    
        [self.sizeInputView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.top.and.bottom.offset(0);
            make.width.mas_equalTo(1);
        }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods
-(void)reloadData{
    
    NSArray *categoryArray = [self.personModel getCategorySizeType:CategorySizeType_Clothes];
    
    self.clothesCountController.categoryArray = categoryArray;
    [self.clothesCountController reloadData];
    
    
    if ([categoryArray count]) {
        self.currentCategory = categoryArray[0];
    }
    
    [self reloadClothesSizeTableView];
    
}

-(void)reloadClothesSizeTableView{
    
    if (self.currentCategory) {
        self.postionsArray = [PositionSizeRangeModel getClothesPositionSizeRangeArray:self.currentCategory.cate bySex:self.personModel.gender];
        
    }else{
        self.postionsArray = nil;
    }
    
    _selectedIndex = -1;
    [self.sizeInputView reset];
    
    [self.tableView reloadData];
}

-(void)setShowLockView:(BOOL)showLockView{
    _showLockView = showLockView;
    
    self.converView.hidden = !showLockView;
}

#pragma mark - UITableView DataSource Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.postionsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SizeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SizeTableViewCell class])];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    PositionSizeRangeModel *rangeModel = self.postionsArray[indexPath.row];
    
    //获取范围
    NSInteger maxSize = 0,minSize = 0;
    [self getPositionRangeMin:&maxSize andRangeMax:&minSize atIndexPath:indexPath];
    
    //是否为必需项
    BOOL isRequired = [self getRequiredAtIndexPath:indexPath];
    
    //cell显示的冬季与夏季尺寸内容
    NSString *sizeStr = [self getPositionSizeDescriptionAtIndexPath:indexPath];
    
    [cell setClothSizeTitle:rangeModel.position andSizeValue:sizeStr andMinSize:maxSize andMaxSize:minSize isRequired:isRequired];
    
    [self setSelectedStatusCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableView Delegte Methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 66.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self reloadSizeInputViewAtIndexPath:indexPath];
    
    NSMutableArray *array = [NSMutableArray array];
    if (_selectedIndex >= 0 && _selectedIndex != indexPath.row) {
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
        [array addObject:oldIndexPath];
    }
    
    _selectedIndex = indexPath.row;
    
    [array addObject:indexPath];
    
    [tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
}

-(void)setSelectedStatusCell:(SizeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    
    cell.status = BodySizeCellStatus_Normal;
    
    if (_selectedIndex == indexPath.row) {
        cell.status = BodySizeCellStatus_Selected;
    }
}

-(NSArray *)getReloadRowsAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableArray *array = [NSMutableArray array];
    
    if (_selectedIndex >=0 && _selectedIndex != indexPath.row) {
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
        [array addObject:oldIndexPath];
    }
    
    _selectedIndex = indexPath.row;
    [array addObject:indexPath];
    
    return array;
}

-(void)reloadSizeInputViewAtIndexPath:(NSIndexPath *)indexPath{
    
    PositionModel *positionModel = [self getPositionModelAtIndexPath:indexPath];
    
    //获取量体部位的范围
    NSInteger min=0,max=0;
    [self getPositionRangeMin:&min andRangeMax:&max atIndexPath:indexPath];
    
    //获取冬季与夏季的尺寸
    NSInteger summer=0,winter=0;
    if (positionModel) {
        summer = positionModel.size;
        winter = positionModel.size_winter;
    }
    
    [self.sizeInputView setSummerSize:summer winterSize:winter minSize:min maxSize:max];
    
    //根据冬季与夏季的数量，显示输入框
    if (0 == self.currentCategory.summerCount) {
        self.sizeInputView.maxSummerSize = 0;
        self.sizeInputView.summerSize = 0;
    }else if (0 == self.currentCategory.winterCount){
        self.sizeInputView.maxWinterSize = 0;
        self.sizeInputView.winterSize = 0;
    }
}

#pragma mark - Data Operation Methods
-(NSString *)getPositionBLCodeAtIndexPath:(NSIndexPath *)indexPath{
    
    PositionSizeRangeModel *rangeModel = [self.postionsArray objectAtIndex:indexPath.row];
    
    NSString *blcode = rangeModel.blcode;
    
    if (0 == self.personModel.gender) {
        blcode = rangeModel.wblcode;
    }
    
    return blcode;
}

-(PositionModel *)getPositionModelAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *blcode = [self getPositionBLCodeAtIndexPath:indexPath];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"blcode = %@",blcode];
    
    NSArray *positions = [[self.currentCategory.position filteredSetUsingPredicate:predicate]sortedArrayUsingDescriptors:@[]];
    
    PositionModel *positionModel;
    if([positions count]) {
        positionModel = positions[0];
    }
    
    return positionModel;
}

-(void)setPositionSummerSize:(NSInteger)summer andWinterSize:(NSInteger)winter AtIndexPath:(NSIndexPath *)indexPath{
    
    PositionModel *positionModel = [self getPositionModelAtIndexPath:indexPath];
    PositionSizeRangeModel *rangeModel = self.postionsArray[indexPath.row];
    
    if (!positionModel) {
        positionModel = [PositionModel MR_createEntity];
        positionModel.blcode = [self getPositionBLCodeAtIndexPath:indexPath];
        positionModel.type = CategorySizeType_Clothes;
        positionModel.category = self.currentCategory;
        positionModel.positionname = rangeModel.position;
    }
    
    if (0 == positionModel.size && 0 == positionModel.size_winter) {
        //初始化赋值
        positionModel.size = summer;
        positionModel.size_winter = winter;
    }else{
        if (self.currentCategory.summerCount > 0) {
            positionModel.size = summer;
        }
        
        if (self.currentCategory.winterCount > 0) {
            positionModel.size_winter = winter;
        }
    }
    
    //同步处理CY、CD的尺寸
    [self.personModel syncAssociationCategory:self.currentCategory andPositionSize:positionModel];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

-(void)getPositionRangeMin:(NSInteger *)min andRangeMax:(NSInteger *)max atIndexPath:(NSIndexPath *)indexPath{
    
    PositionSizeRangeModel *rangeModel = self.postionsArray[indexPath.row];
    
    NSInteger maxSize = rangeModel.manMax;
    NSInteger minSize = rangeModel.manMin;
    
    if (0 == self.personModel.gender) {
        maxSize = rangeModel.womanMax;
        minSize = rangeModel.womanMin;
    }
    
    *min = minSize;
    *max = maxSize;
}

-(BOOL)getRequiredAtIndexPath:(NSIndexPath *)indexPath{
    PositionSizeRangeModel *rangeModel = self.postionsArray[indexPath.row];
    
    BOOL isRequied = NO;
    if (rangeModel.required.isValidString && rangeModel.required) {
        isRequied = YES;
    }
    
    return isRequied;
}

-(NSString *)getPositionSizeDescriptionAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *description;
    
    PositionModel *positionModel = [self getPositionModelAtIndexPath:indexPath];
    
    //夏季尺寸与冬季尺寸
    NSInteger summerSize = 0,winterSize = 0;
    if (positionModel) {
        summerSize = positionModel.size;
        winterSize = positionModel.size_winter;
    }
    
    NSMutableArray *tempArray = [NSMutableArray array];
    
    if (self.currentCategory.summerCount > 0 && summerSize > 0) {
        [tempArray addObject:[NSString stringWithFormat:@"夏:%ld",summerSize]];
    }
    
    if (self.currentCategory.winterCount > 0 && winterSize > 0) {
        [tempArray addObject:[NSString stringWithFormat:@"冬:%ld",winterSize]];
    }
    
    description = [tempArray componentsJoinedByString:@"/"];
    
    return description;
    
}

@end
