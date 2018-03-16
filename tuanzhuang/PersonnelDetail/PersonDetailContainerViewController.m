//
//  PersonDetailContainerViewController.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/20.
//  Copyright © 2017年 red. All rights reserved.
//

#import "PersonDetailContainerViewController.h"
#import "PersonMsgSlideMenuView.h"
#import "CategorySlideMenuView.h"
#import "OtherSliderMenuView.h"
#import "ConfigSlideMenuView.h"
#import "BodySizeContainerViewController.h"
#import "ClothesSizeViewController.h"
#import "SpecialBodyViewController.h"
#import "PersonSignedViewController.h"
#import "RemarksViewController.h"
#import "consultViewController.h"

#import "NSManagedObject+Coping.h"

#import "PPNumberButton.h"

typedef NS_ENUM(NSUInteger, Person_Page_Type) {
    Person_Page_Type_Body,                  //净体量体页面
    Person_Page_Type_Clothes,               //成衣量体页面
    Person_Page_Type_Special_Body,          //特体页面
};

#define COLOR_BACKGROUND_CONTENT [UIColor colorWithRed:0.937 green:0.953 blue:0.961 alpha:1.00]

static const NSInteger zPostion_TabBar = 100;
static const NSInteger zPosition_Slide_Menu = 200;

static const CGFloat Padding_Left_Side = 70.0f;
static const CGFloat Height_Tabbar = 60.0f;
static const CGFloat Padding_Tabbar = 7.0;

#define SIDE_MENU_SIZE          CGSizeMake(870, 156)
#define Width_Tabbar            (CGRectGetWidth(self.view.bounds) - Padding_Left_Side)
#define Width_Tabbar_Progress   Width_Tabbar/3.0

@interface PersonDetailContainerViewController (){
    BOOL _createPerson;
    NSTimer *_timer;
}

@property(nonatomic,strong) PersonMsgSlideMenuView      *personMsgMenuView;
@property(nonatomic,strong) CategorySlideMenuView       *categoryMenuView;
@property(nonatomic,strong) OtherSliderMenuView         *otherMenuView;
@property(nonatomic,strong) ConfigSlideMenuView         *configSlideMenuView;

@property(nonatomic,strong) NSArray                     *pageControllers;

@property(nonatomic,strong) NSMutableArray *pageTypeArray;

@property(nonatomic,strong) UILabel                     *titleLabel;

@property(nonatomic,strong) PersonnelModel              *personModelBackup;     //用户数据备份

@end

@implementation PersonDetailContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addBackButton];
    
    self.title = @"量体页面";
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.masksToBounds = YES;
    
    self.delegate = self;
    self.dataSource = self;
    
    //配置标题
    [self setupTitleLabel];
    self.titleLabel.text = [self.personModel getCategoryConfigDescription_BySizeType];
    
    //配置“完成”按钮
    [self setupNavigationBarComplete];
    
    //配置新用户
    [self setupNewPersonModel];
    
    //初始化公司品类配置数据
    [self setupCompanyCategoryConfigure];
    
    [self setupTabbarAppearance];
    
    [self setupTabPageControllers];

    [self layoutLeftBorderLine];

    self.view.backgroundColor = COLOR_BACKGROUND_CONTENT;
    
    //数据初始化结束后，初始菜单视图
    [self layoutMenuViews];
    
    //显示锁定历史尺寸
    [self setupDisplayLockForHistorySize];
    
    //添加修改通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(personSizeEditNotification:) name:KEY_NOTIFICATION_CENTER_PERSON_SIZE_OPERATION object:nil];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGRect pagerFrame = self.pagerController.view.frame;
    
    self.pagerController.view.frame = CGRectMake(Padding_Left_Side, CGRectGetMinY(pagerFrame), pagerFrame.size.width-Padding_Left_Side, pagerFrame.size.height);
    
    CGRect tabFrame = self.tabBar.frame;
    
    self.tabBar.frame = CGRectMake(Padding_Left_Side, CGRectGetMinY(tabFrame), tabFrame.size.width - Padding_Left_Side, tabFrame.size.height);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.otherMenuView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (self.personModelBackup) {
        [self.personModelBackup MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Custom Layout Subviews
-(void)layoutMenuViews{
    
    self.personMsgMenuView = [[PersonMsgSlideMenuView alloc] init];
    self.categoryMenuView = [[CategorySlideMenuView alloc] init];
    self.configSlideMenuView = [[ConfigSlideMenuView alloc] init];
    
    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([OtherSliderMenuView class]) owner:self options:nil];
    self.otherMenuView = nibArray[0];
    
    if (self.personModel.personnelid.isValidString) {
        self.personMsgMenuView.isNew = NO;
    }else{
        self.personMsgMenuView.isNew = YES;
    }
    
    weakObjc(self);
    
    self.personMsgMenuView.sexChanged = ^{
        //改变性别，重新加载所有的数据
        [weakself reloadTabPageSubControllersData];
    };
    
    self.categoryMenuView.countChangedBlock = ^(NSString *cateCode, NSInteger count, UILabel *cateLabel) {
        [weakself.configSlideMenuView openSlideMenu];
        [weakself.configSlideMenuView reloadData];
        [weakself.personModel setPersonSatus_Progressing];
    };
    
    self.configSlideMenuView.changedBlock = ^(NSArray *bodyCategoryArray, NSArray *clothesCategoryArray) {
        [weakself CategorySizeTypeChanged:bodyCategoryArray andClothesCategorys:clothesCategoryArray];
    };
    
    self.otherMenuView.tapBlock = ^(SLIDER_BUTTON_ITEM_TYPE type) {
        [weakself otherSlideMenuButtonTapAction:type];
    };
    
    NSString *personName = self.personModel.name;
    
    [self configSliderMenu:self.personMsgMenuView andTitle:personName andIndex:0];
    [self configSliderMenu:self.categoryMenuView andTitle:@"品类配置" andIndex:1];
    [self configSliderMenu:self.configSlideMenuView andTitle:@"量体配置" andIndex:2];
    [self configSliderMenu:self.otherMenuView andTitle:@"辅助功能" andIndex:3];
    
    self.personMsgMenuView.hideAllSlideMenuBlock = ^{
        [weakself.personMsgMenuView closeSlideMenu];
        [weakself.categoryMenuView closeSlideMenu];
        [weakself.otherMenuView closeSlideMenu];
        [weakself.configSlideMenuView closeSlideMenu];
    };
}

-(void)reloadMenuViewData{
    [self.personMsgMenuView reloadData];
    [self.categoryMenuView reloadData];
    [self.configSlideMenuView reloadData];
    [self.otherMenuView reloadData];
}

/**
 * 重新加载TabPage里的子Controller数据
 */
-(void)reloadTabPageSubControllersData{
    
    BodySizeContainerViewController *controller = self.pageControllers[Person_Page_Type_Body];
    [controller reloadData];
    
    ClothesSizeViewController *clothesSizeController = self.pageControllers[Person_Page_Type_Clothes];
    [clothesSizeController reloadData];
    
    SpecialBodyViewController *specialBodyController = self.pageControllers[Person_Page_Type_Special_Body];
    [specialBodyController reloadData];
    
}

#pragma mark - Setup Methods

/**
 * 顶部标签的样式配置
 **/
-(void)setupTabbarAppearance{
    
    self.tabBar.layout.barStyle = TYPagerBarStyleCoverView;
    self.tabBar.layer.zPosition = zPostion_TabBar;      //显示在上层，不被page层遮挡
    
    self.tabBarHeight = Height_Tabbar;
    
    self.tabBar.backgroundView = [self getCustomTabbarBackgroundView];
    
    //set tabBar progress View
    self.tabBar.progressView.backgroundColor = COLOR_PERSION_INFO_SELECTED;
    self.tabBar.layout.progressRadius = 5.0;
    self.tabBar.layout.progressHorEdging = 0.0;
    self.tabBar.layout.progressVerEdging = -10.0;
    
    //set tabBar Font
    self.tabBar.layout.normalTextFont = [UIFont systemFontOfSize:20.0];
    self.tabBar.layout.selectedTextFont = [UIFont systemFontOfSize:22.0];
    self.tabBar.layout.normalTextColor = [UIColor blackColor];
    self.tabBar.layout.selectedTextColor = [UIColor whiteColor];
    
    //set tabBar Collection View
    self.tabBar.collectionView.scrollEnabled = NO;
    self.tabBar.collectionView.layer.masksToBounds = NO;
    self.tabBar.layout.progressWidth = Width_Tabbar_Progress;
    
    self.tabBar.layout.cellWidth = Width_Tabbar/1.0 - Padding_Tabbar;
}

/**
 * 存储初始化后的PageController
 */
-(void)setupTabPageControllers{
    
    weakObjc(self);
    
    BodySizeContainerViewController *bodyController = [[BodySizeContainerViewController alloc] init];
    
    
    bodyController.unLockBlock = ^{
        [weakself confirmDialog:@"取消使用历史尺寸？" content:nil result:^(NSInteger i, id obj) {
            if (i) {
                [weakself triggerLockEditSize:NO];
            }
        }];
    };
    
    bodyController.personModel = self.personModel;
    
    ClothesSizeViewController *clothesController = [[ClothesSizeViewController alloc] init];
    clothesController.personModel = self.personModel;
    
    clothesController.unLockBlock = ^{
        [weakself confirmDialog:@"取消使用历史尺寸？" content:nil result:^(NSInteger i, id obj) {
            if (i) {
                [weakself triggerLockEditSize:NO];
            }
        }];
        
    };
    
    SpecialBodyViewController *specialController = [[SpecialBodyViewController alloc] init];
    specialController.personModel = self.personModel;
    
    self.pageControllers = @[bodyController,clothesController,specialController];
}

/**
 * 配置新用户
 **/
-(void)setupNewPersonModel{
    
#warning 等待确认量体师信息获取后，赋值量体师数据
    
    if (!self.personModel) {
        self.personModel = [PersonnelModel MR_createEntity];
        self.personModel.company = self.companyModel;
        self.personModel.companyid = self.companyModel.companyid;
        self.personModel.edittime = [NSDate date];
        self.personModel.name = @"";
        self.personModel.lname = @"量体师名称";
        self.personModel.lid = @"";
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        _createPerson = YES;
    }
    
}

/**
 * 配置导航条“完成”按钮
 **/
-(void)setupNavigationBarComplete{
    
    UIBarButtonItem *completeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(completeBarButtonAction:)];
    
    self.navigationItem.rightBarButtonItem = completeButtonItem;
}

-(void)setupTitleLabel{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 500, 44)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:20.0];
    
    self.navigationItem.titleView = self.titleLabel;
}


#pragma mark - TYPagerController DataSource
-(NSInteger)numberOfControllersInTabPagerController{
    return [self.pageTypeArray count];
}

-(UIViewController *)tabPagerController:(TYTabPagerController *)tabPagerController controllerForIndex:(NSInteger)index prefetching:(BOOL)prefetching{
    
    Person_Page_Type type = [self.pageTypeArray[index] intValue];
    
    UIViewController *controller = self.pageControllers[type];
    
    return controller;
}

-(NSString *)tabPagerController:(TYTabPagerController *)tabPagerController titleForIndex:(NSInteger)index{
    
    Person_Page_Type type = [self.pageTypeArray[index] intValue];
    
    return [self getPageTitleByType:type];
}

#pragma mark - UIBarButton Item Action
-(void)backButtonPressed{
    
    if (_createPerson) {
        [self backAlertForNewPerson];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/**
 * 完成操作
 ***/
-(void)completeBarButtonAction:(id)sender{
    
    BOOL isPass = YES;
    
    NSError *error;
    [self.personModel validatePerson:&error];
    
    if (!error) {
        [self.personModel validateRepeatPerson:&error];
    }
    
    if (error) {
        [self showHUDMessage:[error.userInfo objectForKey:ERROR_DESCRIPTION_KEY] andDelay:1.5];
        isPass = NO;
    }else if(!self.personModel.history){
        [self.personModel validateBodySizeData:&error];
        
        if (error) {
            [self showHUDMessage:[error.userInfo objectForKey:ERROR_DESCRIPTION_KEY] andDelay:2.0];
            isPass = NO;
        }else{
            [self.personModel validateClothesSizeData:&error];
            
            if (error) {
                [self showHUDMessage:[error.userInfo objectForKey:ERROR_DESCRIPTION_KEY] andDelay:1.5];
                isPass = NO;
            }
        }
    }
    
    
    
    
    
    if (isPass) {
        self.personModel.status = PERSON_STATUS_COMPLETED;
        
        //是否需要标注短袖长
        [self.personModel setHasShortSleeveFlag];
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        [self loadSuccessWith:@"已完成量体"];
    }
    
}

/**
 * 备注图片中，添加“标注短袖长”功能
 **/

#pragma mark - Slider Block Methods

/**
 * 品类的测量方式变更
 **/
-(void)CategorySizeTypeChanged:(NSArray *)bodyCategorys andClothesCategorys:(NSArray *)clothesCategorys{
    [self reloadTabPageByBodyCategorys:bodyCategorys clothesCategorys:clothesCategorys];
    
    [self reloadTabPageSubControllersData];
    
    self.titleLabel.text = [self.personModel getCategoryConfigDescription_BySizeType];
}


-(void)otherSlideMenuButtonTapAction:(SLIDER_BUTTON_ITEM_TYPE)type{
    
    switch (type) {
        case SLIDER_BUTTON_ITEM_TYPE_COPY:{
            [self showLoading];
            self.otherMenuView.showCancelButton = NO;
            [CommonData shareCommonData].personModelForCoping = self.personModel;
            [self showHUDMessage:@"复制成功"];
            break;
        }
        case SLIDER_BUTTON_ITEM_TYPE_PASTER:{
            [self showLoading];
            
            //备份量体人量体数据
            if (!self.personModelBackup) {
                self.personModelBackup = [PersonnelModel MR_createEntity];
            }
            [self.personModelBackup copyAttributesFrom:self.personModel];
            [self.personModelBackup copyPersonSizeDataFrom:self.personModel];
            
            //粘贴量体数据
            [self.personModel copyPersonSizeDataFrom:[CommonData shareCommonData].personModelForCoping];
            
            [CommonData shareCommonData].personModelForCoping = nil;
            
            self.otherMenuView.showCancelButton = YES;
            [self reloadMenuViewData];
            [self showHUDMessage:@"粘贴成功"];
            break;
        }
        case SLIDER_BUTTON_ITEM_TYPE_CANCEL_PASTER:{
            [self showLoading];
            self.otherMenuView.showCancelButton = NO;
            if (self.personModelBackup) {
                [self.personModel copyPersonSizeDataFrom:self.personModelBackup];
            }
            
            [self reloadMenuViewData];
            
            [self showHUDMessage:@"撤销完成"];
            
            break;
        }
        case SLIDER_BUTTON_ITEM_TYPE_COPY_OTHER:{
            [self pasteFromChoosedPerson];
            break;
        }
        case SLIDER_BUTTON_ITEM_TYPE_HISTORY:{
            weakObjc(self);
            if (!self.personModel.history) {
                [self confirmDialog:@"确定使用历史尺寸?" content:nil result:^(NSInteger i, id obj) {
                    if (i) {
                        [weakself triggerLockEditSize:YES];
                    }
                }];
            }
            break;
        }
        case SLIDER_BUTTON_ITEM_TYPE_REMARK:{
            RemarksViewController *remarkController = VCFromBundleWithIdentifier(@"RemarksViewController");
            remarkController.personnelmodel = self.personModel;
            [self.navigationController pushViewController:remarkController animated:YES];
            break;
        }
        case SLIDER_BUTTON_ITEM_TYPE_SIGNED:{
            PersonSignedViewController *signedController = [[PersonSignedViewController alloc] init];
            signedController.personModel = self.personModel;
            signedController.companyModel = self.companyModel;
            [self.navigationController pushViewController:signedController animated:YES];
            break;
        }
            
        default:
            break;
    }
    
    [self.otherMenuView reloadData];
}

#pragma mark - Private Helper Methods

-(UIView *)getCustomTabbarBackgroundView{
    UIView *backgroundView = [[UIView alloc] init];
    
    backgroundView.backgroundColor = COLOR_BACKGROUND_CONTENT;
    
    UIView *lineView = [[UIView alloc] init];
    
    lineView.backgroundColor = COLOR_TABLE_CELL_BORDER;
    
    [backgroundView addSubview:lineView];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.offset(0);
        make.height.mas_equalTo(0.5);
    }];
    lineView.layer.shadowRadius = 1;
    lineView.layer.shadowOpacity = 0.2;
    lineView.layer.shadowColor = [UIColor grayColor].CGColor;
    lineView.layer.shadowOffset = CGSizeMake(0, 0.5);
    
    
    UIView *leftLineView = [[UIView alloc] init];
    leftLineView.backgroundColor = COLOR_TABLE_CELL_BORDER;
    
    [backgroundView addSubview:leftLineView];
    
    [leftLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.bottom.offset(0);
        make.width.mas_equalTo(1.0);
    }];

    return backgroundView;
}

-(void)layoutLeftBorderLine{
    UIView *borderLine = [[UIView alloc] init];
    borderLine.backgroundColor = COLOR_TABLE_CELL_BORDER;
    
    [self.view addSubview:borderLine];
    
    [borderLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(Padding_Left_Side);
        make.top.and.bottom.offset(0);
        make.width.mas_equalTo(1.0);
    }];
}

/**
 * 显示或隐藏锁定尺寸
 **/
-(void)setupDisplayLockForHistorySize{
    
    if (self.personModel.history) {
        [self triggerLockEditSize:YES];
    }else{
        [self triggerLockEditSize:NO];
    }
    
}

-(void)configSliderMenu:(CustomSlideMenuView *)sliderMenu andTitle:(NSString *)title andIndex:(NSInteger)index{
    
    sliderMenu.menuTitle = title;
    sliderMenu.layer.zPosition = zPosition_Slide_Menu;
    
    CGFloat padding = 10.0f;
    
    CGFloat paddingTop = TOPNAVIGATIONBAR_H + padding;
    
    CGFloat height = SIDE_MENU_SIZE.height;
    
    paddingTop += (padding+height)*index;
    
    [sliderMenu locationMenuAtPositionY:paddingTop andSize:SIDE_MENU_SIZE inView:self.view];
    
    sliderMenu.personModel = self.personModel;
    sliderMenu.companyModel = self.companyModel;
    
    [sliderMenu reloadData];
}

-(NSString *)getPageTitleByType:(Person_Page_Type)type{

    NSString *title = @"";

    switch (type) {
        case Person_Page_Type_Body:
            title = @"净体信息";
            break;
        case  Person_Page_Type_Clothes:
            title = @"成衣信息";
            break;
        case Person_Page_Type_Special_Body:
            title = @"特体信息";
            break;

        default:
            break;
    }
    
    return title;
}


/**
 * 重新加载TabPageController
 **/
-(void)reloadTabPageByBodyCategorys:(NSArray *)bodyCategorys clothesCategorys:(NSArray *)clothesCategorys{
    
    BOOL changed = NO;
    
    BOOL _hasBody = [bodyCategorys count];
    BOOL _hasClothes = [clothesCategorys count];
    
    NSMutableArray *tempArray = [NSMutableArray array];
    if (_hasBody) {
        [tempArray addObject:@(Person_Page_Type_Body)];
    }
    
    if (_hasClothes) {
        [tempArray addObject:@(Person_Page_Type_Clothes)];
    }
    
    [tempArray addObject:@(Person_Page_Type_Special_Body)];
    
    if ([tempArray count] != [self.pageTypeArray count]) {
        changed = YES;
    }else{
        for (NSNumber *type in tempArray) {
            BOOL isExist = [self.pageTypeArray containsObject:type];
            if (!isExist) {
                changed = YES;
                break;
            }
        }
    }
    
    self.pageTypeArray = tempArray;
    
    if (changed) {
        CGFloat pageCount = [self.pageTypeArray count];
        self.tabBar.layout.cellWidth = Width_Tabbar/pageCount - Padding_Tabbar;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
    }
}

/**
 * 配置公司全局设置的品类数量
 ***/
-(void)setupCompanyCategoryConfigure{
    BOOL allowConfig = [self allowCompanyCategoryConfig];
    
    if (allowConfig) {
        
        if (self.companyModel.configuration.isValidString) {
            
            NSMutableDictionary *countDic = [NSMutableDictionary dictionary];
            NSDictionary *categoryConfigDic = [PersonnelModel convertDicByCategoryConfigStr:self.companyModel.configuration];
            
            for (NSString *categoryCode in categoryConfigDic.allKeys) {
                
                NSInteger count = [[categoryConfigDic objectForKey:categoryCode] integerValue];
                
                if ([categoryCode isEqualToString:Category_Code_T]) {
                    
                    NSInteger count_A = [[countDic objectForKey:Category_Code_A] integerValue];
                    NSInteger count_B = [[countDic objectForKey:Category_Code_B] integerValue];
                    
                    [countDic setObject:@(count_A + count) forKey:Category_Code_A];
                    [countDic setObject:@(count_B + count) forKey:Category_Code_B];
                }else{
                    NSInteger count_Category = [[countDic objectForKey:categoryCode] integerValue];
                    
                    [countDic setObject:@(count + count_Category) forKey:categoryCode];
                }
            }
            
            //删除之前的品类
            for (CategoryModel *category in self.personModel.category) {
                [category MR_deleteEntity];
            }
            
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            
            //复制默认的品类配置
            self.personModel.category_config = self.companyModel.configuration;
            
            for (NSString *categoryCode in countDic.allKeys) {
                NSInteger count = [[countDic objectForKey:categoryCode] integerValue];
                [self.personModel setCategoryCount:count byCategoryCode:categoryCode];
            }
        }

    }

}

/**
 * 是否允许使用全局类别配置
 **/
-(BOOL)allowCompanyCategoryConfig{
    BOOL flag = YES;
    
    if ([self.personModel.position count] > 0) {
        flag = NO;
    }else{
        for (CategoryModel *category in self.personModel.category) {
            if ([category.position count] > 0) {
                flag = NO;
                break;
            }
        }
    }
    
    return flag;
}

-(void)backAlertForNewPerson{
    
    weakObjc(self);
    
    [self confirmDialog:@"是否保留创建的新人员" content:@"" confirmTitle:@"保存" cancelTitle:@"取消" result:^(BOOL confirm) {
        
        if (confirm) {
            //保存新创建的人员数据
            NSError *error;
            [weakself.personModel validatePerson:&error];
            
            if (!error) {
                [weakself.personModel validateRepeatPerson:&error];
            }
            
            if (error) {
                [weakself showHUDMessage:[error.userInfo objectForKey:ERROR_DESCRIPTION_KEY] andDelay:1.5];
                [weakself.personMsgMenuView openSlideMenu];
            }else{
                [weakself.navigationController popViewControllerAnimated:YES];
            }
        }else{
            //删除新创建的人员
            [weakself.navigationController popViewControllerAnimated:YES];
            
            [weakself.personModel MR_deleteEntity];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
        
    }];
}


#pragma mark - Other Button Action

/**
 * 粘贴选择的用户的数据
 **/
-(void)pasteFromChoosedPerson{
    
    consultViewController *choosePersonController = [MAIN_STORYBOARD instantiateViewControllerWithIdentifier:NSStringFromClass([consultViewController class])];
    choosePersonController.companymodel = self.companyModel;
    
    weakObjc(self);
    choosePersonController.copyPersonBlock = ^(PersonnelModel *personModel) {
        [weakself.personModel copyPersonSizeDataFrom:personModel];
        [weakself showHUDMessage:@"粘贴成功"];
        
        [[CommonData shareCommonData] addPersonToCopiedOther:weakself.personModel];
        
         [weakself reloadMenuViewData];
    };
    
    [self.navigationController pushViewController:choosePersonController animated:YES];
    
}


/**
 * 是否锁定尺寸修改【历史尺寸】
 */
-(void)triggerLockEditSize:(BOOL)lock{
    
    self.personModel.history = lock;
    
    if (!lock) {
        //不使用【历史尺寸】时，修改状态
        self.personModel.status = PERSON_STATUS_PROGRESSING;
    }
    
    for (UIViewController *controller in self.pageControllers) {
        if ([controller isKindOfClass:[BodySizeContainerViewController class]]) {
            [(BodySizeContainerViewController *)controller setShowLockView:lock];
        }
        
        if ([controller isKindOfClass:[ClothesSizeViewController class]]) {
            [(ClothesSizeViewController *)controller setShowLockView:lock];
        }
    }
    
    [self.otherMenuView reloadData];
    
}

#pragma mark - 量体修改操作通知处理
-(void)personSizeEditNotification:(NSNotification *)notification{
    
    PersonnelModel *personModel = [notification.userInfo objectForKey:KEY_PERSON_USERINFO_NOTIFICATION];
    NSString *entityName  = [notification.userInfo objectForKey:KEY_ENTITY_USERINFO_NOTIFICATION];
    
    if (personModel == self.personModel) {
        
        if ([entityName isEqualToString:[AdditionModel MR_entityName]]) {
            [personModel setEditTimeIsNow];
        }else{
            [personModel setEditTimeIsNow];
            [personModel setPersonSatus_Progressing];
        }
        
    }
    
    if (self.otherMenuView.showCancelButton && personModel == self.personModel) {
        self.otherMenuView.showCancelButton = NO;
        [self.otherMenuView reloadData];

        if (self.personModelBackup) {
            [self.personModelBackup MR_deleteEntity];
        }
    }
}


@end
