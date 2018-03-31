//
//  ClothesCountViewController.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/8.
//  Copyright © 2018年 red. All rights reserved.
//

#import "ClothesCountViewController.h"
#import "SeasonCountCollectionViewCell.h"

@interface ClothesCountViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    NSInteger _selectedIndex;
}

@property(nonatomic,strong) UICollectionView *collectionView;

@end

@implementation ClothesCountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupCollectionView];
}

-(void)setupCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [self.view addSubview:self.collectionView];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([SeasonCountCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([SeasonCountCollectionViewCell class])];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    //初始化当前选中项
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods

-(void)reloadData{
    _selectedIndex = 0;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView DataSource Methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.categoryArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SeasonCountCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SeasonCountCollectionViewCell class]) forIndexPath:indexPath];
    
    if (_selectedIndex == indexPath.row) {
        cell.isOpen = YES;
    }else{
        cell.isOpen = NO;
    }
    
    CategoryModel *categoryModel = self.categoryArray[indexPath.row];
    
    cell.maxCount = categoryModel.count;
    
    [cell configCategoryCode:categoryModel.cate summerCount:categoryModel.summerCount winterCount:categoryModel.winterCount];
    
    weakObjc(self);
    cell.openBlock = ^{
        [weakself showCollectionViewCellAtIndexPath:indexPath];
    };
    
    cell.changedBlock = ^(NSString *categoryCode, NSInteger summerCount, NSInteger winterCount) {
        [weakself setCategorySummerCount:summerCount andWinterCount:winterCount atIndexPath:indexPath];
    };
    
    return cell;
}

#pragma mark - CollectionView Delegate Methods
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize size = CGSizeMake(52, 70);
    
    if (_selectedIndex == indexPath.row) {
        size = CGSizeMake(382, 70);
    }
    
    return size;
}

#pragma mark - Private Helper Methods
-(void)showCollectionViewCellAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableArray *array = [NSMutableArray array];
    
    if (_selectedIndex != indexPath.row) {
        [array addObject:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
        [array addObject:indexPath];
        _selectedIndex = indexPath.row;
        
        [self.collectionView reloadItemsAtIndexPaths:array];
        
        [self changedActionnAtIndexPath:indexPath];
    }
}

-(void)setCategorySummerCount:(NSInteger)summerCount andWinterCount:(NSInteger)winterCount atIndexPath:(NSIndexPath *)indexPath{
    
    CategoryModel *category = self.categoryArray[indexPath.row];
    
    NSInteger totalCount = category.count;
    NSInteger seasonCount = summerCount + winterCount;
    
    if (totalCount == seasonCount) {
        category.summerCount = summerCount;
        category.winterCount = winterCount;
        
        //[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        [self changedActionnAtIndexPath:indexPath];
    }
}

/**
 * 选择不同的品类、设置品类的数量触发
 ***/
-(void)changedActionnAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.changedBlock) {
        
        CategoryModel *category = self.categoryArray[indexPath.row];
        
        self.changedBlock(category);
    }
}

@end
