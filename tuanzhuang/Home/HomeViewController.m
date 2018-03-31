//
//  HomeViewController.m
//  tuanzhuang
//
//  Created by red on 2017/11/29.
//  Copyright © 2017年 red. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "DownloadListViewController.h"
#import "CompanyEmptyCell.h"
#import "CompanyCollectionViewCell.h"
#import "ConfigurationViewController.h"
#import "MultipeerView.h"
#import "PersonnelListViewController.h"
#import "SearchTableViewCell.h"
#import "UploadView.h"
#import "AboutViewController.h"
#import "SettingViewController.h"
#import "NetStatus.h"
#import "DownloadManager.h"
#import "RecycledViewController.h"

#define CompanyCellIdentify  @"companycollectioncellIdentify"
#define CompanyEmptyIdentify @"companyEmptyIdentify"
#define SearchCellIdentify   @"searchcellIdentify"
#define bottomViewHeight         60  // 底部view高度
#define bottomViewButtonInterval 100 // 批量操作按钮间隔

@interface HomeViewController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, ZZNumberFieldDelegate>

/**
 *  顶部搜索view
 */
@property (nonatomic, strong) UIView *topView;
@property (strong, nonatomic) ZZNumberField *searchTextfield;
@property (nonatomic, strong) UIButton *cancleBtn;
@property (strong, nonatomic) UIView *maskLayerView;//搜索时出现的遮罩层
@property (strong, nonatomic) UITableView *tableView; // 搜索之后显示
@property (strong, nonatomic) UILabel *unSearchLb;
@property (nonatomic, strong) UIView *bottomView;   // 长按显示的底部view
@property (nonatomic, strong) UIButton *deletesBtn; // 批量删除按钮
@property (nonatomic, strong) UIButton *uploadsBtn; // 批量上传按钮
@property (nonatomic, strong) UIButton *configuresBtn; // 批量配置按钮
@property (nonatomic, strong) UIView *inputAccessView;
/**
 *  搜索数据源数组
 */
@property (nonatomic, strong) NSMutableArray *searchDataArr;
/**
 下载单个管理
 */
@property (nonatomic, strong) DownloadManager *downloadManager;
/**
 悬浮按钮
 */
@property (nonatomic, strong) UIButton * recycledIV;
@property (nonatomic, strong) UILabel * recycledNumberLabel;/**<显示回收站内任务数量Label*/

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    [self addRightButtonWithView];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self layoutTopAndBottomView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self addArray];
    [self reloadRecycleNumber];
    [self checkVersion];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self whiteAreaClickMethod];
}

/**
 右侧系统设置按钮
 */
- (void)addRightButtonWithView {
    UIButton *bgView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 88, 26)];
    bgView.layer.borderColor = [UIColor whiteColor].CGColor;
    bgView.layer.borderWidth = 1.0;
    bgView.layer.cornerRadius = 5;
    bgView.layer.masksToBounds = YES;
    [bgView addTarget:self action:@selector(configAboutSystem) forControlEvents:UIControlEventTouchUpInside];

    UILabel *nameLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 0.66*CGRectGetWidth(bgView.frame), CGRectGetHeight(bgView.frame))];
    [bgView addSubview:nameLb];
    nameLb.text = [UserManager getShowname];
    nameLb.textAlignment = NSTextAlignmentCenter;
    nameLb.font = [UIFont systemFontOfSize:16];
    nameLb.textColor = [UIColor whiteColor];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nameLb.frame), 0, 1, 34)];
    line.backgroundColor = [UIColor whiteColor];
    [bgView addSubview:line];

    UIImageView *confiImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bgView.frame)-25, 7, 20, 20)];
    [bgView addSubview:confiImg];

    confiImg.image = [UIImage imageNamed:@"home_config"];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:bgView];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -20;
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, rightItem, nil];
}

- (void)configAboutSystem {
    SettingViewController *vc = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addArray {
    [self.dataSource removeAllObjects];
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"del == NO"];
    NSFetchRequest * request = [CompanyModel MR_requestAllWithPredicate:filter];
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"addtime" ascending:NO];
    [request setSortDescriptors:@[sort]];
    NSArray * companyarray = [CompanyModel MR_executeFetchRequest:request];
    
    if (companyarray.count == 0) {
        return;
    }
    
    for ( int i = 0; i<companyarray.count; i++) {
        HomeModel *model = [[HomeModel alloc] init];
        model.companyModel = companyarray[i];
        model.isSelected = NO;
        model.hiddenShade = YES;
        [self.dataSource addObject:model];
    }
    [_collectionView reloadData];
    
}

/**
 布局搜索textView
 */
- (void)layoutTopAndBottomView {
    [self.view addSubview:self.topView];
    [self.topView addSubview:self.searchTextfield];
    [self.topView addSubview:self.cancleBtn];
    [self layoutCollectionView];
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.uploadsBtn];
    [self.bottomView addSubview:self.deletesBtn];
    [self.bottomView addSubview:self.configuresBtn];
    [self.view addSubview:self.recycledIV];
    [self.view bringSubviewToFront:self.recycledIV];
    [self.view addSubview:self.recycledNumberLabel];
    [self.view bringSubviewToFront:self.recycledNumberLabel];
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
    [_collectionView registerNib:[UINib nibWithNibName:@"CompanyEmptyCell" bundle:nil] forCellWithReuseIdentifier:CompanyEmptyIdentify];
    [_collectionView registerNib:[UINib nibWithNibName:@"CompanyCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:CompanyCellIdentify];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    
    
    // 添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToCollectionView:)];
    [self.collectionView addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnCollectionView:)];
    [self.collectionView addGestureRecognizer:tap];
}

#pragma mark - 检查APP版本
-(void)checkVersion
{
    [NetworkOperation checkversionWithAppid:@"" andResult:^(BOOL update) {
        if (update) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"版本更新" message:@"发现新版本，是否升级？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@""]];
            }];
            [alertVC addAction:yesAction];
            [alertVC addAction:noAction];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
    }];
}

#pragma mark - 长按手势
- (void)longPressToCollectionView: (UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint pointTouch = [gestureRecognizer locationInView:self.collectionView];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
//        NSLog(@"长按开始");
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:pointTouch];
        if (indexPath) {
            NSLog(@"indexPath:%@",indexPath);
            if (indexPath.row == 0) {
                // 长按了第一个创建新文档
                NSLog(@"长按了第一个创建新文档");
            }
            else {
                // 长按了公司文档
                NSLog(@"长按了公司文档");
                // 更新数据源
                HomeModel *model = self.dataSource[indexPath.row-1];
                model.isSelected = YES;
                
                for (int i = 0; i < self.dataSource.count; i ++) {
                    HomeModel *model = self.dataSource[i];
                    if (model.companyModel.lock_status) {
                        // 此文件夹锁住了 不做任何处理
                        
                    }
                    else {
                        
                        model.hiddenShade = NO;
                    }
                }
                
                [self.collectionView reloadData];
                
                // 弹出bottomView
                [UIView animateWithDuration:0.5 animations:^{
                    self.bottomView.frame = CGRectMake(0, CGRectGetMaxY(self.collectionView.frame)-bottomViewHeight, SCREEN_W, bottomViewHeight);
                } completion:^(BOOL finished) {
                    
                }];
                
            }
        }
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"长按改变");
        
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"长按结束");
        
    }
    
}

#pragma mark - 点击手势
- (void)tapOnCollectionView:(UITapGestureRecognizer *)gesture {
    
    CGPoint point = [gesture locationInView:self.collectionView];
    NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:point];  
    if (!indexPath) {
        [self whiteAreaClickMethod];
    }
    else {
        if (indexPath.row == 0) {
            // 点击创建新文档
            DownloadListViewController *downloadVC = VCFromBundleWithIdentifier(@"DownloadListViewController");
            [self.navigationController pushViewController:downloadVC animated:YES];
        }
        else {
            // 点击具体的公司cell
            HomeModel *model = self.dataSource[indexPath.row - 1];
            NSInteger waitNum = [model.waitNum integerValue];
            NSInteger totalNum = [model.numberOfPerson integerValue];
            if (waitNum == totalNum && model.companyModel.configuration == nil) {
                /// 待量体等于量体总人数（新下载 全部数据是待量体的）,并且配置字段是空 代表没有配置过
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"该公司尚未进行品类配置，请优先配置品类" preferredStyle:UIAlertControllerStyleAlert];
                weakObjc(self);
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    // 表示不进行配置直接进入人员列表页
                    [weakself intoPersonListPageWithModel:model];
                    
                }];
                UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    // 表示直接弹出配置弹框
                    [weakself configurePinleiWithModel:model];
                }];
                [alert addAction:cancel];
                [alert addAction:confirm];
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                // 不是最新下载的
                [self intoPersonListPageWithModel:model];
            }
        }
    }
}

// 点击回收站手势
- (void)goRecycled:(UIButton *)sender {
    RecycledViewController *recycledVC = [[RecycledViewController alloc] init];
    [self.navigationController pushViewController:recycledVC animated:YES];
}

/**
 进入人员列表页

 @param model cell的homeModel
 */
- (void)intoPersonListPageWithModel:(HomeModel *)model {
    PersonnelListViewController * personnelListVC = VCFromBundleWithIdentifier(@"PersonnelListViewController");
    personnelListVC.title = [NSString stringWithFormat:@"%@",model.companyModel.missionname];
    personnelListVC.companymodel = model.companyModel;
    [self.navigationController pushViewController:personnelListVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - <UICollectionViewDelegate,UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        
        CompanyEmptyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CompanyEmptyIdentify forIndexPath:indexPath];
        
        return cell;
    }
    else {
        CompanyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CompanyCellIdentify forIndexPath:indexPath];
        cell.homeModel = self.dataSource[indexPath.row-1];
        
        /// 配置
        weakObjc(cell);
        weakObjc(self);
        cell.configurationBlock = ^{
            
            HomeModel *model = weakself.dataSource[indexPath.row - 1];
            NSInteger waitNum = [model.waitNum integerValue];
            NSInteger totalNum = [model.numberOfPerson integerValue];
            if (waitNum != totalNum) {
                // 不全为待量体的状态
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"仅可对待量体人员进行品类配置，是否继续进行？" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    // 弹出配置弹框
                    [weakself configurePinleiWithModel:model];
                }];
                [alert addAction:cancel];
                [alert addAction:confirm];
                [weakself presentViewController:alert animated:NO completion:nil];
            } else {
                // 全为待量体状态  没有提示  直接进入配置页
                [self configurePinleiWithModel:model];
                
            }
        };
        // 同步
        cell.syncMethodBlock = ^{
            [SynchronizeData multiCreateFile:weakcell.homeModel.companyModel];
            
            MultipeerView *vc = [[MultipeerView alloc] initView];
            [weakself presentViewController:vc animated:NO completion:nil];
        };
        // 删除（数据源）刷新页面
        cell.deleteBlock = ^{
            
            [weakself cellOpeationMonitorNetWith:@"删除" indexPath:indexPath];
            
        };
        // cell 上传
        cell.uploadMethodBlock = ^{
            
            [weakself cellOpeationMonitorNetWith:@"上传" indexPath:indexPath];
        };
        // cell遮罩层点击
        cell.tapOnShadeViewBlock = ^{
            HomeModel *model = self.dataSource[indexPath.row-1];
            if (model.companyModel.lock_status) {
                // 锁住了   处理锁的逻辑
                [weakself cellOpeationMonitorNetWith:@"解锁" indexPath:indexPath];
            }
            else {
                // 没有锁住，则就是点击是否选择此项
                model.isSelected = !model.isSelected;
            }
            
            [weakself.collectionView reloadData];
        };
        
        return cell;
    }
}

/**
 弹出配置页面

 @param model cell的homeModel
 */
- (void)configurePinleiWithModel:(HomeModel *)model {
    ConfigurationViewController *vc = [[ConfigurationViewController alloc] initWithItemArray:[NSString stringToDic:model.companyModel.configuration] topText:model.companyModel.companyname];
    vc.saveSelectBlock = ^(NSString *str) {
        // 更新数据库
        CompanyModel *company = [CompanyModel MR_findFirstByAttribute:@"companyid" withValue:model.companyModel.companyid];
        company.configuration = str;
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    };
    [self presentViewController:vc animated:NO completion:nil];
}

/**
 cell 操作（删除、同步、上传 etc.）

 @param str @"删除"、@"同步"、@"上传"
 @param indexPath NSIndexPath
 */
- (void)cellOpeationMonitorNetWith:(NSString *)str indexPath:(NSIndexPath *)indexPath {
    weakObjc(self);
    HomeModel *model = self.dataSource[indexPath.row - 1];
    if ([[NetStatus internetStatus] isEqualToString:@"NONetwork"]) {
        [self showHUDMessage:@"请检查您的网络" andDelay:1.5];
    } else {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"确定要%@吗？", str] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if ([str isEqualToString:@"解锁"]) {
                NSString *businessid = model.companyModel.companyid;
                NSString *urlStr = [NSString stringWithFormat:@"%@file/rev/%@", HTTP_HEADER, businessid];
                [weakself showLoadingWith:@"版本检测中"];
                [NetworkOperation getUnlockWithUrl:urlStr token:[UserManager getToken] success:^(id object) {
                    [weakself hideLoading];
                    if (model.companyModel.rev != [(NSString *)object intValue]) {
                        // 下载数据
                        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:@"数据版本过低，是否重新下载？" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            
                        }];
                        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            
                            NSString *companyid = model.companyModel.companyid;
                            NSString *urlStr = [NSString stringWithFormat:@"%@file/data/%@",HTTP_HEADER,companyid];
                            [weakself showLoadingWith:@"数据加载中"];
                            [NetworkOperation getWithUrl:urlStr
                                                andToken:[UserManager getToken] andSuccess:^(NSArray *downloadArr) {
                                                    
                                                    self.downloadManager = [[DownloadManager alloc] init];
                                                    [self.downloadManager handleDownloadDatas:downloadArr  andCover:YES andFailureMissions:^(NSArray *failureArray) {
                                                        
                                                        [weakself hideLoading];
                                                        if (failureArray.count == 0) {
                                                            // 没有失败的companyid  意味着下载成功
                                                            [weakself addArray];
                                                            [weakself.collectionView reloadData];
                                                            [weakself showHUDMessage:@"下载成功"];
                                                        } else {
                                                            [weakself showHUDMessage:@"下载失败"];
                                                        }
                                                    }];
                                                }
                                              andFailure:^(NSError *error, NSString *errorMessage) {
                                                  [weakself showHUDMessage:@"下载失败"];
                                                  [weakself hideLoading];
                                              }];
                        }];
                        [alertVC addAction:cancel];
                        [alertVC addAction:confirm];
                        [weakself presentViewController:alertVC animated:YES completion:nil];
                        
                    } else {
                        // 直接解锁
                        model.companyModel.lock_status = NO;
                        
                        [weakself.collectionView reloadData];
                    }
                } failure:^(NSError *error) {
                    [weakself hideLoading];
                    [weakself showHUDMessage:@"网络异常"];
                }];
            } else if ([str isEqualToString:@"删除"]) {
                [weakself.dataSource removeObjectAtIndex:indexPath.row-1];
                CompanyModel *company = model.companyModel;
                //删除该公司的公共数据
                [[CommonData shareCommonData] clearDataByCompanyId:company.companyid];
                company.del = YES;
                company.delTime = [NSDate date];
                [weakself reloadRecycleNumber];
                // 删除之后需要在默认上下文中保存一下，否则再次启动会发现并没有删除->_->
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                
                [weakself.collectionView reloadData];
            } else if ([str isEqualToString:@"上传"]) {
                UploadView* vc = [[UploadView alloc] init];
                vc.uploadDatasArray = [NSArray arrayWithObject:model.companyModel];
                [weakself.navigationController pushViewController:vc animated:YES];
            }
            
        }];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:cancle];
        [alert addAction:confirm];
        
        [weakself presentViewController:alert animated:YES completion:nil];
    }
}
    

- (void)whiteAreaClickMethod {
    for (int i = 0; i < self.dataSource.count; i ++) {
        HomeModel *model = self.dataSource[i];
        model.isSelected = NO;
        model.hiddenShade = YES;
    }
    [self.collectionView reloadData];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomView.frame = CGRectMake(0, CGRectGetMaxY(self.collectionView.frame), SCREEN_W, bottomViewHeight);
    } completion:nil];
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        return YES;
    }
    else {
        HomeModel *model = self.dataSource[indexPath.row-1];
        if (!model.hiddenShade) {
            return NO;
        }
        return YES;
    }
}

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row == 0) {
//        // 点击创建新文档
//        DownloadListViewController *downloadVC = VCFromBundleWithIdentifier(@"DownloadListViewController");
//        [self.navigationController pushViewController:downloadVC animated:YES];
//    }
//    else {
//        // 点击具体的公司cell
//        PersonnelListViewController * personnelListVC = VCFromBundleWithIdentifier(@"PersonnelListViewController");
//        HomeModel *model = self.dataSource[indexPath.row-1];
//        personnelListVC.title = [NSString stringWithFormat:@"%@",model.companyName];
//        [self.navigationController pushViewController:personnelListVC animated:YES];
//    }
//}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(0.272*SCREEN_W, 0.272*SCREEN_W);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.046*SCREEN_W;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.046*SCREEN_W, 0.046*SCREEN_W, 0.046*SCREEN_W, 0.046*SCREEN_W);
}

#pragma mark - uitabledatasource / delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchCellIdentify];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell cellWithData:self.searchDataArr[indexPath.row] searchKeyWords:self.searchTextfield.text];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PersonnelListViewController * personnelListVC = VCFromBundleWithIdentifier(@"PersonnelListViewController");
    HomeModel *model = self.searchDataArr[indexPath.row];
    personnelListVC.title = [NSString stringWithFormat:@"%@",model.companyModel.missionname];
    personnelListVC.companymodel = model.companyModel;
    [self.navigationController pushViewController:personnelListVC animated:YES];
}

#pragma mark - textfielddelegate
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//
//    [UIView animateWithDuration:0.5 animations:^{
//        self.padView.frame = CGRectMake(0, SCREEN_H - 64-0.5*SCREEN_H, SCREEN_W, 0.5*SCREEN_H);
//    } completion:^(BOOL finished) {
//        self.padView.userInteractionEnabled = YES;
//    }];
//    return NO;
//}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self operationCancelBtnWhenSearch:YES];
}

#pragma mark - ZZNumberFieldDelegate
- (void)didSearchClicked {
    NSLog(@"点击了搜索按钮");
    
    self.searchDataArr = nil;
    [self.maskLayerView addSubview:self.tableView];
    
    for (NSInteger i = 0; i < self.dataSource.count; i ++) {
        HomeModel *model = self.dataSource[i];
        if ([model.companyModel.missionname containsString:self.searchTextfield.text]) {
            [self.searchDataArr addObject:model];
        }
    }
    [_searchTextfield resignFirstResponder];
    if (self.searchDataArr.count == 0) {
        // 搜索结果为空
        [self.tableView removeFromSuperview];
        
        [self.maskLayerView addSubview:self.unSearchLb];
        [self.unSearchLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.maskLayerView);
            make.top.mas_equalTo(30);
        }];

    } else {
        [self.tableView reloadData];
    }
}

#pragma mark - 取消按钮点击
- (void)cancleSearchAction {
    [self.unSearchLb removeFromSuperview];
    [self.tableView removeFromSuperview];
    [self operationCancelBtnWhenSearch:NO];
    self.searchTextfield.text = @"";
    [self.searchTextfield resignFirstResponder];
    
}

//搜索时处理“取消”按钮
-(void)operationCancelBtnWhenSearch:(BOOL)operation
{
    if (operation) {
        //显示“取消”按钮
        [UIView animateWithDuration:0.2 animations:^{
            _searchTextfield.frame = CGRectMake(_searchTextfield.frame.origin.x, _searchTextfield.frame.origin.y, SCREEN_W-2*SEARCH_X-80-5, _searchTextfield.frame.size.height);
            self.maskLayerView.frame = CGRectMake(0, TOPVIEW_H, SCREEN_W, SCREEN_H);
        } completion:^(BOOL finished) {
            _cancleBtn.hidden = NO;
        }];
    } else {
        //隐藏“取消”按钮
        _cancleBtn.hidden = YES;
        [UIView animateWithDuration:0.2 animations:^{
            _searchTextfield.frame = CGRectMake(_searchTextfield.frame.origin.x, _searchTextfield.frame.origin.y, _searchTextfield.frame.size.width+80+5, _searchTextfield.frame.size.height);
            self.maskLayerView.frame = CGRectMake(0, SCREEN_H, SCREEN_W, SCREEN_H);
        } completion:^(BOOL finished) {
            self.searchDataArr = nil;
            
        }];
    }
}

#pragma mark - 批量按钮点击

/**
 批量上传
 */
- (void)uploadsBtnClick {
    
    [self batchUploadOrDeleteJudgeWithString:@"上传"];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:@"确定要上传吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    weakObjc(self);
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSMutableArray *uploadArr = [NSMutableArray array];
        for (HomeModel *model in self.dataSource) {
            if (model.isSelected) {
                [uploadArr addObject:model.companyModel];
            }
        }
        [weakself whiteAreaClickMethod];
        
        UploadView *uploadVC = [[UploadView alloc] init];
        uploadVC.uploadDatasArray = uploadArr;
        [weakself.navigationController pushViewController:uploadVC animated:YES];
        
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:confirmAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

/**
 批量删除
 */
- (void)deletesBtnClick {
    
    [self batchUploadOrDeleteJudgeWithString:@"删除"];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:@"确定要删除吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    weakObjc(self);
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 保存选中的删除对象
        NSMutableArray *saveElementArr = [NSMutableArray array];
        for (int i = 0; i < weakself.dataSource.count; i ++) {
            HomeModel *model = weakself.dataSource[i];
            if (model.isSelected) {
                [saveElementArr addObject:weakself.dataSource[i]];
            }
        }
        
        [weakself.dataSource removeObjectsInArray:saveElementArr];
        
        // 数据库删除
        [saveElementArr enumerateObjectsUsingBlock:^(HomeModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            CompanyModel *company = model.companyModel;
            
            //删除该公司的存储公共数据
            [[CommonData shareCommonData] clearDataByCompanyId:company.companyid];
            company.del = YES;
            company.delTime = [NSDate date];
            [weakself reloadRecycleNumber];
        }];
        // 删除之后需要在默认上下文中保存一下，否则再次启动会发现并没有删除->_->
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        [weakself whiteAreaClickMethod];
        
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:confirmAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

/**
 批量上传、删除、配置操作之前判断

 @param text 上传或者删除
 */
- (void)batchUploadOrDeleteJudgeWithString:(NSString *)text {
    NSInteger tempNum = 0;
    for (int i = 0; i < self.dataSource.count; i ++) {
        HomeModel *model = self.dataSource[i];
        if (model.isSelected) {
            tempNum ++;
        }
    }
    
    if (tempNum == 0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"请选择要%@的文件", text] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:confirm];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
}

/**
 批量配置
 */
- (void)configuresBtnClick {
    [self batchUploadOrDeleteJudgeWithString:@"配置"];
    weakObjc(self);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"仅可对待量体人员进行品类配置，是否继续进行？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 弹出配置弹框
        ConfigurationViewController *vc = [[ConfigurationViewController alloc] initWithItemArray:[NSString stringToDic:@""] topText:@""];
        vc.saveSelectBlock = ^(NSString *str) {
            // 更新数据库
            [weakself.dataSource enumerateObjectsUsingBlock:^(HomeModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
                if (model.isSelected) {
                    
                    CompanyModel *company = [CompanyModel MR_findFirstByAttribute:@"companyid" withValue:model.companyModel.companyid];
                    company.configuration = str;
                }
            }];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            [weakself whiteAreaClickMethod];
        };
        [self presentViewController:vc animated:NO completion:nil];
    }];
    [alert addAction:cancel];
    [alert addAction:confirm];
    [self presentViewController:alert animated:NO completion:nil];
}

#pragma mark - 私有方法
#pragma mark -- 获取回收站内任务数量
-(NSInteger)numberOfMissionsInRecycle
{
    NSInteger number = [CompanyModel MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"del == YES"]];
    return number;
}

-(void)reloadRecycleNumber
{
    NSInteger number = [self numberOfMissionsInRecycle];
    if (number == 0) {
        self.recycledNumberLabel.hidden = YES;
    } else {
        self.recycledNumberLabel.text = [NSString stringWithFormat:@"%ld",[self numberOfMissionsInRecycle]];
        self.recycledNumberLabel.hidden = NO;
    }
}
#pragma mark - 懒加载
- (UIButton *)recycledIV {
    if (!_recycledIV) {
        _recycledIV = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_W-100, SCREEN_H - 149, 69, 62)];
        [_recycledIV setBackgroundImage:[UIImage imageNamed:@"recyclebin_icon"] forState:UIControlStateNormal];
        [_recycledIV addTarget:self action:@selector(goRecycled:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recycledIV;
}

-(UILabel *)recycledNumberLabel
{
    if (!_recycledNumberLabel) {
        CGFloat size = 20.0;
        _recycledNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.recycledIV.frame.origin.x+self.recycledIV.frame.size.width-size-3, self.recycledIV.frame.origin.y+2, size, size)];
        _recycledNumberLabel.textAlignment = NSTextAlignmentCenter;
        _recycledNumberLabel.layer.masksToBounds = YES;
        _recycledNumberLabel.layer.cornerRadius = size/2.0;
        _recycledNumberLabel.backgroundColor = [UIColor redColor];
        _recycledNumberLabel.textColor = [UIColor whiteColor];
        _recycledNumberLabel.font = [UIFont systemFontOfSize:11];
    }
    return _recycledNumberLabel;
}

- (UIView *)inputAccessView {
    if (!_inputAccessView) {
        _inputAccessView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, 50)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, SCREEN_W, 40)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"自定义inputView";
        [_inputAccessView addSubview:label];

    }
    return _inputAccessView;
}

- (UIButton *)uploadsBtn {
    if (!_uploadsBtn) {
        CGFloat w = 0.76*CGRectGetHeight(self.bottomView.frame);
        CGFloat h = w;
        CGFloat x = SCREEN_W/2 + w/2 + bottomViewButtonInterval;
        CGFloat y = (CGRectGetHeight(self.bottomView.frame) - w)/2;
        _uploadsBtn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
        [_uploadsBtn setBackgroundImage:[UIImage imageNamed:@"upload_a"] forState:UIControlStateNormal];
        [_uploadsBtn addTarget:self action:@selector(uploadsBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _uploadsBtn;
}

- (UIButton *)deletesBtn {
    if (!_deletesBtn) {
        CGFloat w = CGRectGetWidth(self.uploadsBtn.frame);
        CGFloat h = w;
        CGFloat x = SCREEN_W/2-w/2;
        CGFloat y = CGRectGetMinY(self.uploadsBtn.frame);
        _deletesBtn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
        [_deletesBtn setBackgroundImage:[UIImage imageNamed:@"delete_a"] forState:UIControlStateNormal];
        [_deletesBtn addTarget:self action:@selector(deletesBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deletesBtn;
}

- (UIButton *)configuresBtn {
    if (!_configuresBtn) {
        CGFloat w = CGRectGetWidth(self.uploadsBtn.frame);
        CGFloat h = w;
        CGFloat x = SCREEN_W/2 - w/2 - bottomViewButtonInterval - w;
        CGFloat y = CGRectGetMinY(self.uploadsBtn.frame);
        _configuresBtn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
        [_configuresBtn setBackgroundImage:[UIImage imageNamed:@"set_a"] forState:UIControlStateNormal];
        [_configuresBtn addTarget:self action:@selector(configuresBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _configuresBtn;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.collectionView.frame), SCREEN_W, bottomViewHeight)];
        _bottomView.backgroundColor = systemGrayColor;
    }
    return _bottomView;
}

- (UIView *)maskLayerView {
    
    if (!_maskLayerView) {
        _maskLayerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_H, SCREEN_W, SCREEN_H)];
//        _maskLayerView.backgroundColor = RGBColorAlpha(0, 0, 0, 0.3);
        _maskLayerView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_maskLayerView];
    }
    return _maskLayerView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.maskLayerView.frame), CGRectGetHeight(self.maskLayerView.frame))];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 88;
        [_tableView registerNib:[UINib nibWithNibName:@"SearchTableViewCell" bundle:nil] forCellReuseIdentifier:SearchCellIdentify];
    }
    return _tableView;
}

- (UILabel *)unSearchLb {
    if (!_unSearchLb) {
        _unSearchLb = [[UILabel alloc] init];
        _unSearchLb.text = @"未搜到相关公司";
        _unSearchLb.font = [UIFont systemFontOfSize:16];
        _unSearchLb.textAlignment = NSTextAlignmentCenter;
        _unSearchLb.textColor = systemGrayColor;
    }
    return _unSearchLb;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, TOPVIEW_H)];
        _topView.backgroundColor = RGBColor(204, 204, 204);
    }
    return _topView;
}

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

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (NSMutableArray *)searchDataArr {
    if (!_searchDataArr) {
        _searchDataArr = [NSMutableArray array];
    }
    return _searchDataArr;
}

@end
