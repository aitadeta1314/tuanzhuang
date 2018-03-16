//
//  ReceiveDataViewController.m
//  tuanzhuang
//
//  Created by Fenly on 2017/12/19.
//  Copyright © 2017年 red. All rights reserved.
//

#import "ReceiveDataViewController.h"
#import "ReceivePersonCell.h"
#import "ReceiveInfoModel.h"
#import "ReceiveMultipeerView.h"
#import "SyncMultipeerView.h"
#import "PersonDetailContainerViewController.h"

#define RECEIVECELLIdentify @"receiveCellIdentify"
@interface ReceiveDataViewController ()<UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate>

/**
 *  tableView
 */
@property (nonatomic, strong) UITableView *mainTableView;
/**
 *  可编辑tableview
 */
@property (nonatomic, strong) UITableView *canEditView;
/**
 *  底部数据同步按钮
 */
@property (nonatomic, strong) UIButton *syncBottomBtn;
/**
 *  数据数组
 */
@property (nonatomic, copy) NSMutableArray *mainDataArr;
/**
 *  复制的最原始数据数组
 */
@property (nonatomic, copy) NSMutableArray *fuzhiDataArr;

/**
 保存所有数据字典
 */
@property (nonatomic, strong) NSMutableDictionary *allDataDic;
/**
 保存跳转进入量体页面的personalModel
 */
@property (nonatomic, strong) PersonnelModel *personelModel;
/**
 保存点击的NSIndexPath
 */
@property (nonatomic, strong) NSIndexPath *indexPath;
@end

@implementation ReceiveDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.multipeer resetReceiveStatus];
    [self rightButtonPress];
    [self addBackButton];
    [self addRightButtonWithImage:@"list_pickuo_icon"];
    [self layoutMainTableView];

    
    [self defineMergeBlock];
    
    [self receiveNotification];
    
}

// 添加观察者
- (void)receiveNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncButtonChange) name:@"syncButtonChange" object:nil];
}

- (void)syncButtonChange {
    if ([self judgeRepeatData]) {
        // 有重复的数据
        self.syncBottomBtn.backgroundColor = RGBColor(191, 191, 191);
        UIImageView *imageView = (UIImageView *)[self.syncBottomBtn viewWithTag:8888];
        imageView.image = [UIImage imageNamed:@"syncDataSendImg"];
        self.syncBottomBtn.enabled = NO;
    } else {
        // 没有重复的数据
        self.syncBottomBtn.backgroundColor = skyColor;
        UIImageView *imageView = (UIImageView *)[self.syncBottomBtn viewWithTag:8888];
        imageView.image = [UIImage imageNamed:@"master_synchronize"];
        self.syncBottomBtn.enabled = YES;
    }
}

/**
 判断是否含有重复的数据

 @return YES表示有重复数据，NO表示没有重复的数据
 */
- (BOOL)judgeRepeatData {
    // 判断是否有重复的数据
    for (int i = 0; i < self.fuzhiDataArr.count; i ++) {
        NSInteger tempNum = 0;  // 记录某个分区有几个重复数据
        NSArray *refArray = self.fuzhiDataArr[i];
        NSArray *usArray = self.mainDataArr[i];
        ReceiveInfoModel *referToModel = refArray[0];
        if (referToModel.dataEditStatus == DATA_EDIT_YES && referToModel.dataRepeatLogo == DATA_REPEAT_LOGO_repeat) {
            // 只考虑可编辑&&重复的数据，对可编辑数据进行判断是否有重复数据
            for (ReceiveInfoModel *model in usArray) {
                if (model.dataRepeatLogo == DATA_REPEAT_LOGO_repeat) {
                    tempNum ++;
                }
            }
        }
        
        if (tempNum > 1) {
            return YES;
        }
    }
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 修改可编辑数据返回之后需要对数据进行重新处理，防止不同数据在同一分区等情况。
    if ([self.allDataDic isValidDic]) {
        
        NSDictionary *changeDic = [SynchronizeData personnelDicByModel:self.personelModel];
        ReceiveInfoModel *model = self.mainDataArr[self.indexPath.section][self.indexPath.row];
        [model.data removeAllObjects];
        [model.data setValuesForKeysWithDictionary:changeDic];
        
        model.name = [model.data valueForKey:@"name"];
        if (((NSNumber *)[model.data valueForKey:@"gender"]).intValue == 1) {
            model.gender = @"男";
        }
        else {model.gender = @"女";}
        model.department = [model.data valueForKey:@"department"];
        model.jobnumber = [model.data valueForKey:@"jobnumber"];
        
        [self.personelModel MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[SynchronizeData rehandleSynchronizeDict:self.allDataDic]];
        
        [self dataSourceHandleWithDic:dic];
    }
}

/**
 分发block
 */
- (void)defineMergeBlock {
    
    weakObjc(self);
    self.multipeer.onMerge = ^(NSMutableDictionary *dic){
        /* dic
         @{
             @"rev":long,
             @"source": @{
                 @"nonrepeat":@[],
                 @"original" :@[],
                 @"repeat"   :@[]
             }
         
         }
         */
        [weakself dataSourceHandleWithDic:dic];
    };
}

#pragma mark - 处理接收的数据
/**
 数据源处理

 @param dic 未处理的总数据字典
 */
- (void)dataSourceHandleWithDic:(NSMutableDictionary *)dic {
    // 保存所有数据字典
    self.allDataDic = dic;
    // dic回调数据是全部的数据
    [self.mainDataArr removeAllObjects];
    [self.fuzhiDataArr removeAllObjects];
    NSLog(@"--处理传递过来的数据--%@",dic);
    
    NSArray *originalArr = [dic valueForKey:@"original"]; // 不能处理的原始下载数据
    NSArray *repeatArr = [dic valueForKey:@"repeat"]; // 重复数据数组（格式：元素是数组）
    NSArray *nonrepeatArr = [dic valueForKey:@"nonrepeat"];// 没有重复的数据（格式：元素是每个人员具体量体信息【字典】）
    // 1.处理可编辑的数据数组
    // 1.1处理有重复的
    if (repeatArr.isValidArray) {
        [repeatArr enumerateObjectsUsingBlock:^(NSArray *subArr, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *tempSubArr = [SynchronizeData handleRepeatArray:subArr];
            [self precessingDataToModelWithArray:tempSubArr isCanEdit:YES repeat:YES];
            
        }];
    }
    // 1.2处理没有重复的
    if (nonrepeatArr.isValidArray) {
        NSArray *tempNonrepeatArr = [SynchronizeData handleNonrepeatArray:nonrepeatArr];
        [self precessingDataToModelWithArray:tempNonrepeatArr isCanEdit:YES repeat:NO];
    }
    
    // 2.处理不可编辑的数据
    if (originalArr.isValidArray) {
        [self precessingDataToModelWithArray:originalArr isCanEdit:NO repeat:NO];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.mainTableView reloadData];
    });
    
    [self registerAndSendNoti];
}

/**
 处理接收的数据

 @param array 数组
 @param edit 是否是可编辑数据
 @param repeat 是否是重复数据分区
 */
- (void)precessingDataToModelWithArray:(NSArray *)array isCanEdit:(BOOL)edit repeat:(BOOL)repeat{
    NSMutableArray *tempArr = [NSMutableArray array];
    NSMutableArray *tempReferArr = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(NSMutableDictionary *personDic, NSUInteger idx, BOOL * _Nonnull stop) {
        ReceiveInfoModel *model = [[ReceiveInfoModel alloc] init];
        model.name = [personDic valueForKey:@"name"];
        if (((NSNumber *)[personDic valueForKey:@"gender"]).intValue == 1) {
            model.gender = @"男";
        }
        else {model.gender = @"女";}
        model.department = [personDic valueForKey:@"department"];
        model.jobnumber = [personDic valueForKey:@"lname"];
        NSInteger status = ((NSNumber *)[personDic valueForKey:@"status"]).integerValue;
        switch (status) {
            case 0:
                // 待量体
                model.dataStatus = DATAIN_STATUS_WAIT;
                break;
            case 1:
                // 进行中
                model.dataStatus = DATAIN_STATUS_DOING;
                break;
            case 2:
                // 已完成
                model.dataStatus = DATAIN_STATUS_DONE;
                break;
            default:
                break;
        }
        if (edit) {
            // 可编辑数据
            NSInteger repeatLogo = ((NSNumber *)[personDic valueForKey:@"repeatlogo"]).integerValue;
            switch (repeatLogo) {
                case 0:
                    model.dataRepeatLogo = DATA_REPEAT_LOGO_no;
                    break;
                case 1:
                    model.dataRepeatLogo = DATA_REPEAT_LOGO_ignore;
                    break;
                case 2:
                    model.dataRepeatLogo = DATA_REPEAT_LOGO_repeat;
                    break;
                default:
                    break;
            }
        }
        else {
            // 不可编辑数据
            model.dataEditStatus = DATA_EDIT_NO;
        }
        model.data = personDic;
        [tempArr addObject:model];
        ReceiveInfoModel *fuzhiModel = [model mutableCopy];
//        NSLog(@"--model.data:%p",model.data);
//
////        fuzhiModel.data = [model.data mutableCopy];
//        NSLog(@"--fuzhiModel.data:%p",fuzhiModel.data);
        if (repeat && edit) {
            fuzhiModel.dataRepeatLogo = DATA_REPEAT_LOGO_repeat;
        }
        [tempReferArr addObject:fuzhiModel];
    }];
    [self.mainDataArr addObject:tempArr];
    [self.fuzhiDataArr addObject:tempReferArr];
    
}
#pragma mark -

-(void)dealloc{
    self.multipeer.onMerge = nil;
}

- (void)layoutMainTableView {
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.syncBottomBtn];
    
}

//- (void)addDataArray {
//
//    // 不可编辑数据只设置dataEditStatus = DATA_EDIT_NO  [此状态默认是可编辑的]
//    ReceiveInfoModel *model = [[ReceiveInfoModel alloc] init];
//    model.name = @"阿尔法";
//    model.gender = @"男";
//    model.department = @"后勤部";
//    model.dataStatus = DATAIN_STATUS_DONE;
//    model.jobnumber = @"12345";
//    model.dataEditStatus = DATA_EDIT_NO;
//
//    // 数据可编辑需设置dataRepeatLogo 重复的数据设置DATA_REPEAT_LOGO_repeat 不重复数据设置DATA_REPEAT_LOGO_noDATA_REPEAT_LOGO_no
//    ReceiveInfoModel *model1 = [[ReceiveInfoModel alloc] init];
//    model1.name = @"阿尔法2";
//    model1.gender = @"男";
//    model1.department = @"后勤部";
//    model1.dataStatus = DATAIN_STATUS_DONE;
//    model1.jobnumber = @"12345";
//    model1.dataRepeatLogo = DATA_REPEAT_LOGO_repeat;
//    model1.dataEditStatus = DATA_EDIT_YES;
//
//    ReceiveInfoModel *model2 = [[ReceiveInfoModel alloc] init];
//    model2.name = @"阿尔法2";
//    model2.gender = @"男";
//    model2.department = @"后勤部";
//    model2.dataStatus = DATAIN_STATUS_DONE;
//    model2.jobnumber = @"12345";
//    model2.dataRepeatLogo = DATA_REPEAT_LOGO_repeat;
//
//    ReceiveInfoModel *model3 = [[ReceiveInfoModel alloc] init];
//    model3.name = @"阿尔法2";
//    model3.gender = @"男";
//    model3.department = @"后勤部";
//    model3.dataStatus = DATAIN_STATUS_DONE;
//    model3.jobnumber = @"12345";
//    model3.dataRepeatLogo = DATA_REPEAT_LOGO_repeat;
//
//    ReceiveInfoModel *model4 = [[ReceiveInfoModel alloc] init];
//    model4.name = @"阿尔法2";
//    model4.gender = @"男";
//    model4.department = @"后勤部";
//    model4.dataStatus = DATAIN_STATUS_DONE;
//    model4.jobnumber = @"12345";
//    model4.dataRepeatLogo = DATA_REPEAT_LOGO_repeat;
//
//    ReceiveInfoModel *model5 = [[ReceiveInfoModel alloc] init];
//    model5.name = @"阿尔法2";
//    model5.gender = @"男";
//    model5.department = @"后勤部";
//    model5.dataStatus = DATAIN_STATUS_DONE;
//    model5.jobnumber = @"12345";
//    model5.dataRepeatLogo = DATA_REPEAT_LOGO_no;
//
//
//    ReceiveInfoModel *model6 = [[ReceiveInfoModel alloc] init];
//    model6.name = @"阿尔法2";
//    model6.gender = @"男";
//    model6.department = @"后勤部";
//    model6.dataStatus = DATAIN_STATUS_DONE;
//    model6.jobnumber = @"12345";
//    model6.dataRepeatLogo = DATA_REPEAT_LOGO_no;
//
//    ReceiveInfoModel *model7 = [[ReceiveInfoModel alloc] init];
//    model7.name = @"阿尔法2";
//    model7.gender = @"男";
//    model7.department = @"后勤部";
//    model7.dataStatus = DATAIN_STATUS_DONE;
//    model7.jobnumber = @"12345";
//    model7.dataRepeatLogo = DATA_REPEAT_LOGO_no;
//
//    ReceiveInfoModel *model8 = [[ReceiveInfoModel alloc] init];
//    model8.name = @"阿尔法2";
//    model8.gender = @"男";
//    model8.department = @"后勤部";
//    model8.dataStatus = DATAIN_STATUS_DONE;
//    model8.jobnumber = @"12345";
//    model8.dataRepeatLogo = DATA_REPEAT_LOGO_no;
//
//    self.mainDataArr = [NSMutableArray arrayWithArray:@[@[model1,model2,model3,model4],@[model5,model6,model7, model8],@[model,model,model,model]]];
//
//    self.fuzhiDataArr = [NSMutableArray arrayWithArray:@[@[[model1 mutableCopy],[model2 mutableCopy],[model3 mutableCopy],[model4 mutableCopy]],@[[model5 mutableCopy],[model6 mutableCopy],[model7 mutableCopy], [model7 mutableCopy]],@[model,model,model,model]]];
//
//
//}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 25;
    
    // NSLog(@"%f,%f",scrollView.contentOffset.x,scrollView.contentOffset.y);
    if(scrollView == self.mainTableView){
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>= 0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
    
}

-(void)backButtonPressed{
    
    [self confirmDialog:@"提示" content:@"确认取消编辑？" result:^(NSInteger i, id obj) {
        if(i){
            [_multipeer setIsMaster:NO];
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
    }];
}

- (void)rightButtonPress {
    ReceiveMultipeerView* vc = [[ReceiveMultipeerView alloc] initView];
    [self presentViewController:vc animated:YES completion:^{}];
}

#pragma mark - 数据分发 同步进程
- (void)syncDataProcess {
    NSLog(@"数据分发按钮点击");
    // 验证
    // 判断是否有重复的数据
//    for (int i = 0; i < self.fuzhiDataArr.count; i ++) {
//        NSInteger tempNum = 0;  // 记录某个分区有几个重复数据
//        NSArray *refArray = self.fuzhiDataArr[i];
//        NSArray *usArray = self.mainDataArr[i];
//        ReceiveInfoModel *referToModel = refArray[0];
//        if (referToModel.dataEditStatus == DATA_EDIT_YES && referToModel.dataRepeatLogo == DATA_REPEAT_LOGO_repeat) {
//            // 只考虑可编辑&&重复的数据，对可编辑数据进行判断是否有重复数据
//            for (ReceiveInfoModel *model in usArray) {
//                if (model.dataRepeatLogo == DATA_REPEAT_LOGO_repeat) {
//                    tempNum ++;
//                }
//            }
//        }
//
//        if (tempNum > 1) {
//            // 如果重复数据大于1，需要处理重复数据
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"请先处理重复的数据" preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//            }];
//            [alert addAction:action];
//            [self presentViewController:alert animated:YES completion:nil];
//            return;
//        }
//    }
    NSMutableDictionary *dataDic = [self validationDataMethod];
    // 分发
    [self.multipeer distributeData:dataDic];
    SyncMultipeerView* vc = [[SyncMultipeerView alloc] initView];
    [self presentViewController:vc animated:YES completion:^{}];
}

- (NSMutableDictionary *)validationDataMethod {
    
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    
    NSMutableArray *newArr = [NSMutableArray array];
    NSMutableArray *originalArr = [NSMutableArray array];
    
    for (int i = 0; i < self.fuzhiDataArr.count; i ++) {
        NSArray *referArray = self.fuzhiDataArr[i];
        NSArray *useArray = self.mainDataArr[i];
        ReceiveInfoModel *referToModel = referArray[0];
        if (referToModel.dataEditStatus == DATA_EDIT_NO) {
            // 不可编辑的数据（原始数据）
            for (ReceiveInfoModel *model in useArray) {
                [originalArr addObject:model.data];
            }
        } else{
            // 可编辑数据（新建数据）
            if (referToModel.dataRepeatLogo == DATA_REPEAT_LOGO_repeat) {
                // 这个分区是重复数据分区
                for (ReceiveInfoModel *model in useArray) {
                    if (model.dataRepeatLogo == DATA_REPEAT_LOGO_no) {
                        [newArr addObject:model.data];
                    }
                }
            } else {
                // 这个分区是没有重复的数据分区
                for (ReceiveInfoModel *model in useArray) {
                    if (model.dataRepeatLogo == DATA_REPEAT_LOGO_no) {
                        [newArr addObject:model.data];
                    }
                }
            }
        }
    }
    NSMutableArray *allDataArr = [NSMutableArray array];
    [allDataArr addObjectsFromArray:newArr];
    [allDataArr addObjectsFromArray:originalArr];
    [dataDic setValue:[self.allDataDic valueForKey:@"rev"] forKey:@"rev"];
    [dataDic setValue:allDataArr forKey:@"source"];
    return dataDic;
    /*
     dataDic 字典格式
     @{
         @"rev": @"",
         @"source": @[
            model.data,
            model.data,
            ...
         ]
     }
     */
}


-(NSArray *)testData{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"];
    NSData *imageData = [NSData dataWithContentsOfFile: imagePath];
    NSMutableArray * dataArray = [[NSMutableArray alloc] init];
    for (int i=0; i<50; i++) {
        NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat:@"姓名%d",i],@"name",
                              [NSString stringWithFormat:@"部门%d",i],@"department",
                              [NSString stringWithFormat:@"公司%d",i],@"company",
                              i%2==0?@"男":@"女",@"gender",
                              imageData,@"image",nil];
        [dataArray addObject:dic];
    }
    return dataArray;
}


#pragma mark - 懒加载
- (NSMutableDictionary *)allDataDic {
    if (!_allDataDic) {
        _allDataDic = [[NSMutableDictionary alloc] init];
    }
    return _allDataDic;
}
-(Multipeer *)multipeer{
    if(!_multipeer){
        _multipeer = [[Multipeer alloc] init];
    }
    return _multipeer;
}

- (UIButton *)syncBottomBtn {
    if (!_syncBottomBtn) {
        _syncBottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _syncBottomBtn.frame = CGRectMake(0, SCREEN_H-64-64, SCREEN_W, 64);
        if (_syncBottomBtn.enabled) {
            // 有交互
            _syncBottomBtn.backgroundColor = skyColor;
        }
        else {
            _syncBottomBtn.backgroundColor = systemGrayColor;
        }
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_W/2-100, 12, 40, 40)];
        imgView.tag = 8888;
        [_syncBottomBtn addSubview:imgView];
        imgView.image = [UIImage imageNamed:@"master_synchronize"];

        UILabel *dataSyncLb = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imgView.frame)+10, 17, 150, 30)];
        dataSyncLb.text = @"数据分发";
        dataSyncLb.textColor = [UIColor whiteColor];
        dataSyncLb.font = [UIFont boldSystemFontOfSize:25];
        [_syncBottomBtn addSubview:dataSyncLb];
        
        [_syncBottomBtn addTarget:self action:@selector(syncDataProcess) forControlEvents:UIControlEventTouchUpInside];
    }
    return _syncBottomBtn;
}

- (NSMutableArray *)mainDataArr {
    if (!_mainDataArr) {
        _mainDataArr = [[NSMutableArray alloc] init];
    }
    return _mainDataArr;
}

- (NSMutableArray *)fuzhiDataArr {
    if (!_fuzhiDataArr) {
        _fuzhiDataArr = [[NSMutableArray alloc] init];
    }
    return _fuzhiDataArr;
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H-64-64) style:UITableViewStylePlain];
        _mainTableView.backgroundColor = [UIColor whiteColor];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerNib:[UINib nibWithNibName:@"ReceivePersonCell" bundle:nil] forCellReuseIdentifier:RECEIVECELLIdentify];
    }
    return _mainTableView;
}


#pragma mark - UITableViewDelegate / datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.mainDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ReceivePersonCell *cell = [tableView dequeueReusableCellWithIdentifier:RECEIVECELLIdentify forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.mainDataArr[indexPath.section][indexPath.row];
    cell.delegate = self;
    if (cell.model.dataEditStatus != DATA_EDIT_NO) {
        // 可编辑的cell 含有恢复忽略
        weakObjc(self);
        if (cell.model.dataRepeatLogo == DATA_REPEAT_LOGO_ignore) {
            cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"恢 复" icon:nil backgroundColor:skyColor padding:40 callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
                NSInteger index = indexPath.row;
                NSInteger section = indexPath.section;
                NSArray *array = weakself.mainDataArr[section];
                NSArray *referToArray = weakself.fuzhiDataArr[section];
                ReceiveInfoModel *referToModel = referToArray[0];
                if (referToModel.dataRepeatLogo == DATA_REPEAT_LOGO_repeat) {
                    // 这个分区是重复数据分区
                    __block NSInteger tempNum = 0; // 记录在重复数据分区有几个DATA_REPEAT_LOGO_ignore值
                    [array enumerateObjectsUsingBlock:^(ReceiveInfoModel *model, NSUInteger index, BOOL * _Nonnull stop) {
                        if (model.dataRepeatLogo == DATA_REPEAT_LOGO_no) {
                            // 如果有最后一个 停止遍历跳出循环
                            model.dataRepeatLogo = DATA_REPEAT_LOGO_repeat;
                            [model.data setValue:@2 forKey:@"repeatlogo"];
                            // *stop = YES;
                        }
                        if (model.dataRepeatLogo == DATA_REPEAT_LOGO_ignore) {
                            tempNum ++;
                        }
                    }];
                    
                    ReceiveInfoModel *model = array[index];
                    if (tempNum == array.count) {
                        // 如果全部忽略，则恢复的这个显示DATA_REPEAT_LOGO_no
                        model.dataRepeatLogo = DATA_REPEAT_LOGO_no;
                        [model.data setValue:@0 forKey:@"repeatlogo"];
                    } else {
                        
                        model.dataRepeatLogo = DATA_REPEAT_LOGO_repeat;
                        [model.data setValue:@2 forKey:@"repeatlogo"];
                    }
                    
                }
                else {
                    // 这个分区不是重复数据分区 DATA_REPEAT_LOGO_no
                    
                    ReceiveInfoModel *model = array[index];
                    model.dataRepeatLogo = DATA_REPEAT_LOGO_no;
                    [model.data setValue:@0 forKey:@"repeatlogo"];
                }
                
                
                [weakself.mainTableView reloadData];
                
                [self registerAndSendNoti];
                return YES;
            }]];
            
        }
        else {
            cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"忽 略" icon:nil backgroundColor:[UIColor redColor] padding:40 callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
                
                NSInteger index = indexPath.row;
                NSArray *array = weakself.mainDataArr[indexPath.section];
                ReceiveInfoModel *model = array[index];
                model.dataRepeatLogo = DATA_REPEAT_LOGO_ignore;
                [model.data setValue:@1 forKey:@"repeatlogo"];
                
                __block NSInteger tempNum = 0;  // 记录有几个重复数据（不包括忽略的）
                [array enumerateObjectsUsingBlock:^(ReceiveInfoModel *model, NSUInteger index, BOOL * _Nonnull stop) {
                    if (model.dataRepeatLogo == DATA_REPEAT_LOGO_repeat) {
                        tempNum ++;
                    }
                    if (tempNum > 2) { // 不需要遍历其他的
                        *stop = YES;
                    }
                }];
                if (tempNum < 2) {
                    // 只有一个重复的数据 ==  没有重复的数据
                    [array enumerateObjectsUsingBlock:^(ReceiveInfoModel *model, NSUInteger index, BOOL * _Nonnull stop) {
                        if (model.dataRepeatLogo != DATA_REPEAT_LOGO_ignore) {
                            model.dataRepeatLogo = DATA_REPEAT_LOGO_no;
                            [model.data setValue:@0 forKey:@"repeatlogo"];
                            *stop = YES;
                        }
                    }];
                }
                
                [weakself.mainTableView reloadData];
                
                [self registerAndSendNoti];
                
                return YES;
            }]];
        }
    }
    
    return cell;
    
}

//- (void)swipeCell:(ReceivePersonCell *)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.mainDataArr[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.mainDataArr.count == 1) {
        // 只有一种情况：包含有不可编辑数据和可编辑数据
        ReceiveInfoModel *model = self.mainDataArr[0][0];
        if (model.dataEditStatus == DATA_EDIT_NO) {
            
            return [self creatHeaderViewWithIndex:!0];
        }
        else {
            return [self creatHeaderViewWithIndex:0];
        }
    }
    else if (self.mainDataArr.count > 1) {
        
        if (section == 0) {
            
            return [self creatHeaderViewWithIndex:0];
            
        } else if (section == self.mainDataArr.count - 1) {
            ReceiveInfoModel *model = self.mainDataArr[section][0];
            if (model.dataEditStatus == DATA_EDIT_NO) {
                return [self creatHeaderViewWithIndex:!0];
            } else {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, 20)];
                view.backgroundColor = RGBColorAlpha(228, 228, 228, 1);
                return view;
            }
            
        }
        else {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, 20)];
            imageView.image = [UIImage imageNamed:@"syncDataHeader"];
            return imageView;
        }
    }
    else {
        return nil;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ReceiveInfoModel *model = self.mainDataArr[indexPath.section][indexPath.row];
    if (model.dataEditStatus == DATA_EDIT_YES) {
        // 能编辑  忽略的不能点击进入详情
        if (model.dataRepeatLogo != DATA_REPEAT_LOGO_ignore) {
            // 忽略的不能点击
            self.indexPath = indexPath;
            PersonnelModel *personModel = [SynchronizeData personnelModelByDic:model.data];
            PersonDetailContainerViewController *personDetailVC = [[PersonDetailContainerViewController alloc] init];
            self.personelModel = personModel;
            personDetailVC.personModel = self.personelModel;
            personDetailVC.companyModel = self.personelModel.company;
            [self.navigationController pushViewController:personDetailVC animated:YES];
        }
        
    }
}

- (UIView *)creatHeaderViewWithIndex:(NSInteger)index {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, 20)];
    view.backgroundColor = systemGrayColor;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 20)];
    [view addSubview:label];
    if (index == 0) {
        label.text = @"可编辑数据";
    }
    else {
        
        label.text = @"不可编辑数据";
    }
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor blackColor];
    
    return view;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (self.mainDataArr.count == 1) {
        // 只有一种情况：包含有不可编辑数据和可编辑数据
        return 20.f;
    }
    else if (self.mainDataArr.count > 1) {
        
        if (section == 0) {
            
            return 20.f;
        } else if (section == self.mainDataArr.count-1) {
            ReceiveInfoModel *model = self.mainDataArr[section][0];
            if (model.dataEditStatus == DATA_EDIT_NO) {
                return 20.f;
            } else {
                return 14.f;
            }
        }
        else {
            return 14.f;
        }
    }
    else {
        return 0.f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

//#pragma mark - 左滑忽略、恢复  已在 MGSwipeTableCellDelegate 代理中实现
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    ReceivePersonCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    if (cell.model.dataEditStatus == DATA_EDIT_NO) {
//        return NO;
//    }
//    else {
//        return YES;
//    }
//
//}

//- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//    weakObjc(self);
//    ReceivePersonCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    if (cell.model.dataRepeatLogo == DATA_REPEAT_LOGO_ignore) {
//        /// 已经被忽略的cell 需要显示恢复
//        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"恢 复" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//            NSInteger index = indexPath.row;
//            NSInteger section = indexPath.section;
//            NSArray *array = weakself.mainDataArr[section];
//            NSArray *referToArray = weakself.fuzhiDataArr[section];
//            ReceiveInfoModel *referToModel = referToArray[0];
//            if (referToModel.dataRepeatLogo == DATA_REPEAT_LOGO_repeat) {
//                // 这个分区是重复数据分区
//                __block NSInteger tempNum = 0; // 记录在重复数据分区有几个DATA_REPEAT_LOGO_ignore值
//                [array enumerateObjectsUsingBlock:^(ReceiveInfoModel *model, NSUInteger index, BOOL * _Nonnull stop) {
//                    if (model.dataRepeatLogo == DATA_REPEAT_LOGO_no) {
//                        // 如果有最后一个 停止遍历跳出循环
//                        model.dataRepeatLogo = DATA_REPEAT_LOGO_repeat;
//                        [model.data setValue:@2 forKey:@"repeatlogo"];
//                        // *stop = YES;
//                    }
//                    if (model.dataRepeatLogo == DATA_REPEAT_LOGO_ignore) {
//                        tempNum ++;
//                    }
//                }];
//
//                ReceiveInfoModel *model = array[index];
//                if (tempNum == array.count) {
//                    // 如果全部忽略，则恢复的这个显示DATA_REPEAT_LOGO_no
//                    model.dataRepeatLogo = DATA_REPEAT_LOGO_no;
//                    [model.data setValue:@0 forKey:@"repeatlogo"];
//                } else {
//
//                    model.dataRepeatLogo = DATA_REPEAT_LOGO_repeat;
//                    [model.data setValue:@2 forKey:@"repeatlogo"];
//                }
//
//            }
//            else {
//                // 这个分区不是重复数据分区 DATA_REPEAT_LOGO_no
//
//                ReceiveInfoModel *model = array[index];
//                model.dataRepeatLogo = DATA_REPEAT_LOGO_no;
//                [model.data setValue:@0 forKey:@"repeatlogo"];
//            }
//
//
//            [weakself.mainTableView reloadData];
//
//            [self registerAndSendNoti];
//        }];
//        action.backgroundColor = skyColor;
//        return @[action];
//    }
//    else {
//        /// 没有忽略的cell 需要显示忽略
//        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"忽 略" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//
//            NSInteger index = indexPath.row;
//            NSArray *array = weakself.mainDataArr[indexPath.section];
//            ReceiveInfoModel *model = array[index];
//            model.dataRepeatLogo = DATA_REPEAT_LOGO_ignore;
//            [model.data setValue:@1 forKey:@"repeatlogo"];
//
//            __block NSInteger tempNum = 0;  // 记录有几个重复数据（不包括忽略的）
//            [array enumerateObjectsUsingBlock:^(ReceiveInfoModel *model, NSUInteger index, BOOL * _Nonnull stop) {
//                if (model.dataRepeatLogo == DATA_REPEAT_LOGO_repeat) {
//                    tempNum ++;
//                }
//                if (tempNum > 2) { // 不需要遍历其他的
//                    *stop = YES;
//                }
//            }];
//            if (tempNum < 2) {
//                // 只有一个重复的数据 ==  没有重复的数据
//                [array enumerateObjectsUsingBlock:^(ReceiveInfoModel *model, NSUInteger index, BOOL * _Nonnull stop) {
//                    if (model.dataRepeatLogo != DATA_REPEAT_LOGO_ignore) {
//                        model.dataRepeatLogo = DATA_REPEAT_LOGO_no;
//                        [model.data setValue:@0 forKey:@"repeatlogo"];
//                        *stop = YES;
//                    }
//                }];
//            }
//
//            [weakself.mainTableView reloadData];
//
//            [self registerAndSendNoti];
//
//        }];
//        return @[action];
//    }
//
//}

/**
 注册并发送通知
 监听数据是否重复用来改变按钮状态
 */
- (void)registerAndSendNoti {
    NSNotification *noti = [NSNotification notificationWithName:@"syncButtonChange" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:noti];
}

#pragma mark - MGSwipeTableCellDelegate
- (BOOL)swipeTableCell:(ReceivePersonCell *)cell canSwipe:(MGSwipeDirection)direction fromPoint:(CGPoint)point {
    
    if (cell.model.dataEditStatus == DATA_EDIT_NO) {
        return NO;
    }
    else {
        return YES;
    }
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
