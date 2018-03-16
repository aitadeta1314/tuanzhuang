//
//  BodySizeViewController.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/26.
//  Copyright © 2017年 red. All rights reserved.
//

#import "BodySizeViewController.h"
#import "SizeTableViewCell.h"
#import "PositionSizeRangeModel.h"
#import "PersonnelModel+Helper.h"

static NSString * const gender_Key_Observer = @"gender";

@interface BodySizeViewController ()<UITableViewDataSource,UITableViewDelegate>

//净体输入表
@property(nonatomic,strong) UITableView *bodySizeTableView;

@property(nonatomic,strong) NSArray *dataSource;

@property(nonatomic,assign) int gender;

@end

@implementation BodySizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = [PositionSizeRangeModel getBodyPositionSizeRangeArrayBySex:self.personModel.gender];
    
    [self setupBodySizeTableView];
}

-(void)setupBodySizeTableView{
    self.bodySizeTableView = [[UITableView alloc] init];
    self.bodySizeTableView.dataSource = self;
    self.bodySizeTableView.delegate = self;
    
    self.bodySizeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:self.bodySizeTableView];
    
    [self.bodySizeTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.bodySizeTableView registerClass:[SizeTableViewCell class] forCellReuseIdentifier:NSStringFromClass([SizeTableViewCell class])];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods
-(void)reloadData{
    self.dataSource = [PositionSizeRangeModel getBodyPositionSizeRangeArrayBySex:self.personModel.gender];
    
    [self.bodySizeTableView reloadData];
}

#pragma mark - TableView DataSource Delegate Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataSource count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SizeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SizeTableViewCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    PositionSizeRangeModel *positionModel = [self.dataSource objectAtIndex:indexPath.row];
    
    NSInteger maxRange = 0;
    NSInteger minRange = 0;
    if (self.personModel.gender == 0) {
        //女
        minRange = positionModel.womanMin;
        maxRange = positionModel.womanMax;
    }else{
        //男
        minRange = positionModel.manMin;
        maxRange = positionModel.manMax;
    }
    
    cell.status = BodySizeCellStatus_Normal;
    
    BOOL isrequired = [positionModel isRequiredForBodySizeCategorys:[self.personModel getCategorySizeType:CategorySizeType_Body]];
    
    NSInteger size = [self getPositionSizeAtIndexPath:indexPath];
    
    [cell setBodySizeTitle:positionModel.position andSizeValue:size andMinSize:minRange andMaxSize:maxRange isRequired:isrequired];
    
    weakObjc(self);
    cell.sizeChangedBlock = ^(NSInteger size) {
        [weakself setPositionSize:size atIndexPath:indexPath];
    };
    
    return cell;
}


#pragma mark - TableView Delegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 66.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SizeTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [cell.sizeTextField becomeFirstResponder];
    
}

#pragma mark - Private Helper Methods

-(NSInteger)getPositionSizeAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger size = 0;
    
    PositionModel *positionModel = [self getPositionModelAtIndexPath:indexPath];
    
    if (positionModel) {
        size = positionModel.size;
    }
    
    return size;
}

-(void)setPositionSize:(NSInteger)size atIndexPath:(NSIndexPath *)indexPath{

    
    PositionModel *positionModel = [self getPositionModelAtIndexPath:indexPath];
    
    PositionSizeRangeModel *rangeModel = self.dataSource[indexPath.row];
    
    NSString *positionName = rangeModel.position;
    
    if (size > 0) {
        if (!positionModel) {
            NSString *blcode = [self getBLCodeAtIndexPath:indexPath];
            
            positionModel = [PositionModel MR_createEntity];
            positionModel.blcode = blcode;
            positionModel.positionname = positionName;
            positionModel.type = CategorySizeType_Body;
            positionModel.personnel = self.personModel;
            positionModel.personnelid = self.personModel.personnelid;
        }
        positionModel.size = size;
    }else if (positionModel){
        [positionModel MR_deleteEntity];
    }
    
    //更新加放量需要同步的部位尺寸
    weakObjc(self);
    [self.personModel referenceAdditionByPositionName:positionName andSize:size complete:^(BOOL changed) {
        
        if (changed && weakself.reloadAddtionalData) {
            weakself.reloadAddtionalData();
        }
    }];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
}

-(PositionModel *)getPositionModelAtIndexPath:(NSIndexPath *)indexPath{
    
    PositionModel *positionModel;
    
    NSString *blcode = [self getBLCodeAtIndexPath:indexPath];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"blcode = %@",blcode];
    
    NSArray *positions = [[self.personModel.position filteredSetUsingPredicate:predicate] sortedArrayUsingDescriptors:@[]];
    
    if ([positions count]>0) {
        positionModel = positions[0];
    }
    return positionModel;
}

-(NSString *)getBLCodeAtIndexPath:(NSIndexPath *)indexPath{
    PositionSizeRangeModel *position_rangeModel = [self.dataSource objectAtIndex:indexPath.row];
    
    NSString *blcode = position_rangeModel.blcode;
    
    if (0 == self.personModel.gender) {
        //women
        blcode = position_rangeModel.wblcode;
    }
    
    return blcode;
}

@end
