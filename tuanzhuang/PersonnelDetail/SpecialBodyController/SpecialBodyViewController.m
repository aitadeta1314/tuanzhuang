//
//  SpecialBodyViewController.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/4.
//  Copyright © 2018年 red. All rights reserved.
//

#import "SpecialBodyViewController.h"
#import "CustomCollectionFlowLayout.h"
#import "LabelCollectionViewCell.h"
#import "HeaderLabelCollectionReusableView.h"
#import "PersonnelModel+Helper.h"

#import "SpecialBodyOptionModel.h"

static NSString * const Identifier_Cell = @"identifier_cell";
static NSString * const Identifier_Header = @"identifier_header";
static NSString * const Separated_Str = @",";

#define TEXT_COLOR_NORMAL       [UIColor grayColor]
#define TEXT_COLOR_SELECTED     [UIColor whiteColor]

@interface SpecialBodyViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property(nonatomic,strong) UICollectionView *collectionView;

@property(nonatomic,strong) NSArray *dataArray;

@property(nonatomic,strong) NSMutableArray *selectedIndexPath;

@end

@implementation SpecialBodyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.selectedIndexPath = [NSMutableArray array];
    [self layoutCollectionView];
    
    weakObjc(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)layoutCollectionView{
    
    CustomCollectionFlowLayout *layout = [[CustomCollectionFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(180, 42);
    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = 16;
    layout.sectionInset = UIEdgeInsetsMake(20, 40, 20, 40);
    layout.headerReferenceSize = CGSizeMake(100, 42);
    layout.headerSpacing = 26;
    layout.headerAlignTop = YES;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.allowsMultipleSelection = YES;
    
    [self.view  addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [self.collectionView registerClass:[LabelCollectionViewCell class] forCellWithReuseIdentifier:Identifier_Cell];
    
    [self.collectionView registerClass:[HeaderLabelCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:Identifier_Header];
}

#pragma mark - Public Methods
-(void)reloadData{
    
    NSInteger bodyCount = [[self.personModel getCategorySizeType:CategorySizeType_Body] count];
    NSInteger clothesCount = [[self.personModel getCategorySizeType:CategorySizeType_Clothes] count];
    
    self.dataArray = [SpecialBodyOptionModel getSpecialBodyOptions:bodyCount andHasClothes:clothesCount isMTMData:self.personModel.mtm];
    
    [self reloadSelectedIndexPaths];
    
    [self.collectionView reloadData];
}

-(void)reloadSelectedIndexPaths{
    [self.selectedIndexPath removeAllObjects];
    
    NSArray *codeArray = [self.personModel.specialoptions componentsSeparatedByString:Separated_Str];
    
    for (int section = 0; section < [self.dataArray count]; section++) {
        
        NSArray *options = [(SpecialBodyOptionModel *)self.dataArray[section] options];
        
        for (int row = 0; row < [options count]; row++) {
            SpecialBodyOptionModel *model = options[row];
            
            NSString *codeStr = [NSString stringWithFormat:@"%ld",model.code];
            
            if ([codeArray containsObject:codeStr]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                [self.selectedIndexPath addObject:indexPath];
            }
        }
        
    }
    
    if ([self.selectedIndexPath count]) {
        [self saveSpecialOptions];
    }
}


#pragma mark - UICollectionView DataSource Methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [self.dataArray count];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    SpecialBodyOptionModel *groupModel = [self.dataArray objectAtIndex:section];
    
    return [groupModel.options count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LabelCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier_Cell forIndexPath:indexPath];

    weakObjc(self);
    cell.labelBySelectedBlock = ^(BOOL selected, UILabel *label) {
        [weakself configCellLabel:label bySelected:selected];
    };
    
    SpecialBodyOptionModel *groupModel = self.dataArray[indexPath.section];
    SpecialBodyOptionModel *itemModel = groupModel.options[indexPath.row];
    
    cell.titleLabel.text = itemModel.name;
    
    cell.style = [self.selectedIndexPath containsObject:indexPath];
    
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        HeaderLabelCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:Identifier_Header forIndexPath:indexPath];
        
        [self configCollectionHeaderViewLabel:headerView.titleLabel];
        
        SpecialBodyOptionModel *groupModel = self.dataArray[indexPath.section];
        
        headerView.titleLabel.text = groupModel.group;
        
        return headerView;
    }
    return nil;
}

#pragma mark - UICollectionView Delegate Methods
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.selectedIndexPath containsObject:indexPath]) {
        [self.selectedIndexPath removeObject:indexPath];
    }else{
        
        //删除同一个section里的元素
        for (NSIndexPath *selectedIndexPath in self.selectedIndexPath) {
            if (selectedIndexPath.section == indexPath.section) {
                [self.selectedIndexPath removeObject:selectedIndexPath];
                break;
            }
        }
        
        [self.selectedIndexPath addObject:indexPath];
        
    }
    
    [collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
    
    //保存特体数据到数据库中
    [self saveSpecialOptions];
}



#pragma mark - Private Helper Methods
-(void)configCollectionHeaderViewLabel:(UILabel *)label{
    
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = COLOR_PERSION_INFO_SELECTED;
    label.font = [UIFont systemFontOfSize:18.0];
    label.layer.cornerRadius = 4.0;
    label.layer.masksToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    
}

-(void)configCellLabel:(UILabel *)label bySelected:(BOOL)selected{
    
    label.font = [UIFont systemFontOfSize:16.0];
    label.layer.masksToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 4.0;
    label.layer.borderColor = TEXT_COLOR_NORMAL.CGColor;
    
    if (selected) {
        label.textColor = TEXT_COLOR_SELECTED;
        label.layer.borderWidth = 0;
        label.backgroundColor = TEXT_BACKGROUND_COLOR_SELECTED;
        
    }else{
        label.textColor = TEXT_COLOR_NORMAL;
        label.layer.borderWidth = 1.0;
        label.backgroundColor = [UIColor clearColor];
    }
    
}

#pragma mark - Data Operation Methods
-(void)saveSpecialOptions{
    
    NSMutableArray *optionsArray = [NSMutableArray array];
    
    for (NSIndexPath *indexPath in self.selectedIndexPath) {
        SpecialBodyOptionModel *groupModel = [self.dataArray objectAtIndex:indexPath.section];
        
        SpecialBodyOptionModel *optionModel = groupModel.options[indexPath.row];
        
        NSString *code = [NSString stringWithFormat:@"%ld",optionModel.code];
        
        [optionsArray addObject:code];
    }
    
    NSString *specialOptions = [optionsArray componentsJoinedByString:Separated_Str];
    
    if (![self.personModel.specialoptions isEqualToString:specialOptions]) {
        self.personModel.specialoptions = specialOptions;
        //[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }

    
}

@end
