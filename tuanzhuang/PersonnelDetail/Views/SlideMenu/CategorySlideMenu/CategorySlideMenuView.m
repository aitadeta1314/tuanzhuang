//
//  CategorySlideMenuView.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/22.
//  Copyright © 2017年 red. All rights reserved.
//

#import "CategorySlideMenuView.h"
#import "CategoryCollectionViewCell.h"

#define CELL_ITEM_SIZE  CGSizeMake(172, 44)

static const CGFloat minimumInteritemSpacing = 12.0f;
static const CGFloat minimumLineSpacing = 20.0f;


@interface CategorySlideMenuView()<UICollectionViewDelegate,UICollectionViewDataSource>{
    NSArray *_categoryCodes;
}

@property(nonatomic,strong) NSMutableArray *countArray;

@property(nonatomic,strong) UICollectionView *collectionView;

@end

@implementation CategorySlideMenuView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self configDefaultDataSource];
        [self addContentCollectionView];
        
        [self reloadData];
    }
    
    return self;
}

#pragma mark - Public Methods

-(void)reloadData{
    [self.collectionView reloadData];
}

#pragma mark - Private Add Subviews Helper Methods
-(void)addContentCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    layout.itemSize = CELL_ITEM_SIZE;
    layout.minimumInteritemSpacing = minimumInteritemSpacing;
    layout.minimumLineSpacing = minimumLineSpacing;
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView setContentInset:UIEdgeInsetsMake(4, 40, 0, 40)];
    
    [self.collectionView registerClass:[CategoryCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([CategoryCollectionViewCell class])];
    
    [self.contentView addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(20, 0, 0, 60)).priorityHigh();
    }];
}


#pragma mark - CollectionView DataSource Methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{

    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return  [_categoryCodes count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CategoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CategoryCollectionViewCell class]) forIndexPath:indexPath];
    
    NSString *categoryCode = _categoryCodes[indexPath.row];

    cell.title = categoryCode;
    
    NSDictionary *configDic = [PersonnelModel convertDicByCategoryConfigStr:self.personModel.category_config];
    
    cell.count = [[configDic objectForKey:categoryCode] integerValue];
    
    __weak typeof(self) weakSelf = self;
    
    cell.changedBlock = ^(NSInteger newCount, UILabel *titleLabel) {
        [weakSelf CategoryChangedCount:newCount atIndexPath:indexPath andLable:titleLabel];
    };
    
    return cell;
}


#pragma mark - Category Cell Count Changed Delegate

-(void)CategoryChangedCount:(NSInteger)count atIndexPath:(NSIndexPath *)indexPath andLable:(UILabel *)categoryLabel{
    
    NSString *cateCode = [_categoryCodes objectAtIndex:indexPath.row];
    
    if (![self.personModel canConfigCategory:cateCode]) {
        count = 0;
    }
    
    //设置品类配置中的数量
    [self.personModel setConfigCategoryCount:count byCategoryCode:cateCode];
    
    if ([cateCode isEqualToString:Category_Code_A] || [cateCode isEqualToString:Category_Code_B]) {
        NSInteger count_T = [self.personModel getConfigCategoryCount:Category_Code_T];
        count += count_T;
    }
    
    [self.personModel setCategoryCount:count byCategoryCode:cateCode];
    [self reloadData];
    
    
    if (self.countChangedBlock) {
        self.countChangedBlock(cateCode, count, categoryLabel);
    }
}


-(BOOL)resignFirstResponder{
    
    
    for (UIView *view in self.contentView.subviews) {
        if ([view respondsToSelector:@selector(resignFirstResponder)]) {
            [view resignFirstResponder];
        }
    }
    
    return [super resignFirstResponder];
}

#pragma mark - Private Helper Methods
-(void)configDefaultDataSource{
    _categoryCodes = [Category_Code_Array_Str componentsSeparatedByString:@","];
}





@end
