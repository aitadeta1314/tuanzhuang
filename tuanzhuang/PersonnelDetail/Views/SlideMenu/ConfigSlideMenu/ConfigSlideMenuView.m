//
//  ConfigSlideMenuView.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/10.
//  Copyright © 2018年 red. All rights reserved.
//

#import "ConfigSlideMenuView.h"
#import "CustomCollectionFlowLayout.h"
#import "LabelCollectionViewCell.h"
#import "HeaderLabelCollectionReusableView.h"

static NSString * const Identifier_CollectionView_Cell = @"collectionview_cell_identifier";
static NSString * const Identifier_Collectionview_Header = @"collectionview_header_identifier";

@interface ConfigSlideMenuView()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong) UICollectionView *collectionView;

@property(nonatomic,strong) NSArray *bodyCategoryArray;

@property(nonatomic,strong) NSArray *clothesCategoryArray;

@property(nonatomic,strong) NSMutableArray *titleArray;

@end

@implementation ConfigSlideMenuView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self layoutCollectionView];
    }
    
    return self;
    
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self layoutCollectionView];
    }
    
    return self;
    
}

-(void)reloadData{
    
    self.titleArray = [NSMutableArray array];
    int sectionCount = 2;
    
    for (int i=0; i<sectionCount; i++) {
        self.titleArray[i] = [self getCategoryTitleArray:i];
    }
    
    [self.collectionView reloadData];
    
    if (self.changedBlock) {
        self.changedBlock(self.titleArray[0], self.titleArray[1]);
    }
}

-(void)layoutCollectionView{
    
    CustomCollectionFlowLayout *flowlayout = [[CustomCollectionFlowLayout alloc] init];
    flowlayout.itemSize = CGSizeMake(60, 34);
    flowlayout.minimumLineSpacing = 4.0f;
    flowlayout.minimumInteritemSpacing = 20.0f;
    flowlayout.sectionInset = UIEdgeInsetsMake(20, 18, 20, 18);
    flowlayout.headerReferenceSize = CGSizeMake(82, 34);
    flowlayout.headerAlignTop = YES;
    flowlayout.headerSpacing = 30.0f;
    
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.contentView.bounds collectionViewLayout:flowlayout];
    
    self.collectionView.scrollEnabled = NO;
    
    [self.contentView addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, Slide_Content_Padding_Left + 20.0, 0, Slide_Menu_Width)).priorityHigh();
    }];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerClass:[LabelCollectionViewCell class] forCellWithReuseIdentifier:Identifier_CollectionView_Cell];
    [self.collectionView registerClass:[HeaderLabelCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:Identifier_Collectionview_Header];
}

#pragma mark - UICollectionView DataSource Methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (section < [self.titleArray count]) {
        
        NSArray *tempArray = self.titleArray[section];
        
        return [tempArray count];
    }else{
        return 0;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    LabelCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier_CollectionView_Cell forIndexPath:indexPath];
    
    cell.titleLabel.font = [UIFont systemFontOfSize:14.0];
    cell.titleLabel.backgroundColor = COLOR_PERSION_INFO_SELECTED;
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;
    cell.titleLabel.textColor = [UIColor whiteColor];
    
    cell.titleLabel.layer.cornerRadius = 5.0;
    cell.titleLabel.layer.masksToBounds = YES;
    
    
    NSString *title = self.titleArray[indexPath.section][indexPath.row];
    
    cell.titleLabel.text = title;
    
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{

    if (kind == UICollectionElementKindSectionHeader) {
        NSString *identifier = Identifier_Collectionview_Header;
        
        HeaderLabelCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:identifier forIndexPath:indexPath];
        
        headerView.titleLabel.textColor = [UIColor blackColor];;
        headerView.titleLabel.font = [UIFont systemFontOfSize:20.0 weight:1];
        
        if (indexPath.section == 0) {
            headerView.titleLabel.text = @"净体量体";
        }else{
            headerView.titleLabel.text = @"成衣量体";
        }
        
        
        return headerView;
    }
    return nil;
}

#pragma mark - UICollectionView Delegate Methods
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CategorySizeType type = [self getCategorySizeTypeAtSection:indexPath.section];
    
    type = (type == CategorySizeType_Body) ? CategorySizeType_Clothes : CategorySizeType_Body;
    
    [self setCategorySizeType:type atIndexPath:indexPath];
    
    [self.personModel setPersonSatus_Progressing];
    
    [self reloadData];
}

#pragma mark - DataSource Helper Methods
-(void)setCategorySizeType:(CategorySizeType)type atIndexPath:(NSIndexPath *)indexPath{
    
    NSString *title = self.titleArray[indexPath.section][indexPath.row];
    
    NSArray *titleArray = [title componentsSeparatedByString:@"/"];
    
    if ([titleArray containsObject:Category_Code_T]) {
        [self.personModel setCategorySizeType:type byCategoryCode:Category_Code_A];
        [self.personModel setCategorySizeType:type byCategoryCode:Category_Code_B];
    }else{
        for (NSString *code in titleArray) {
            [self.personModel setCategorySizeType:type byCategoryCode:code];
        }
    }
}

-(NSArray *)getCategoryTitleArray:(NSInteger)section{
    
    NSInteger type = [self getCategorySizeTypeAtSection:section];
    
    NSArray *categoryArray = [self.personModel getCategorySizeType:type];
    
    NSMutableArray *titleArray = [NSMutableArray array];
    
    for (CategoryModel *model in categoryArray) {
        
        NSString *title = [self getTitleByCategoryCode:model.cate];
        
        if (![titleArray containsObject:title]) {
            [titleArray addObject:title];
        }
    }
    
    return titleArray;
}

-(NSString *)getTitleByCategoryCode:(NSString *)code{
    
    NSString *title = code;
    
    if ([code isEqualToString:Category_Code_A] || [code isEqualToString:Category_Code_B]) {
        //T 、T/A 、T/B、T/A/B
        title = [self getTitleT_A_B];
    }else if ([code isEqualToString:Category_Code_CY] || [code isEqualToString:Category_Code_CD]){
        //CY/CD
        title = [self getTitleCY_CD];
    }
    
    return title;
}

-(NSString *)getTitleCY_CD{
    
    NSString *title;
    
    NSInteger count_CY = [self.personModel getConfigCategoryCount:Category_Code_CY];
    
    NSInteger count_CD = [self.personModel getConfigCategoryCount:Category_Code_CD];
    
    NSMutableArray *titleArray = [NSMutableArray array];
    
    if (count_CY) {
        [titleArray addObject:Category_Code_CY];
    }
    
    if (count_CD) {
        [titleArray addObject:Category_Code_CD];
    }
    
    title = [titleArray componentsJoinedByString:@"/"];
    
    return title;
}

-(NSString *)getTitleT_A_B{
    NSString *title;
    
    NSInteger count_T = [self.personModel getConfigCategoryCount:Category_Code_T];
    
    NSInteger count_A = [self.personModel getConfigCategoryCount:Category_Code_A];
    
    NSInteger count_B = [self.personModel getConfigCategoryCount:Category_Code_B];
    
    NSMutableArray *titleArray = [NSMutableArray array];
    
    if (count_T) {
        [titleArray addObject:Category_Code_T];
    }
    
    if (count_A) {
        [titleArray addObject:Category_Code_A];
    }
    
    if (count_B){
        [titleArray addObject:Category_Code_B];
    }
    
    title = [titleArray componentsJoinedByString:@"/"];
    
    
    return title;
}

-(CategorySizeType)getCategorySizeTypeAtSection:(NSInteger)section{
    
    if (0 == section) {
        return CategorySizeType_Body;
    }
    
    return CategorySizeType_Clothes;
}




@end
