//
//  UploadView.m
//  tuanzhuang
//
//  Created by zhuang on 2017/12/8.
//  Copyright © 2017年 red. All rights reserved.
//

#import "UploadView.h"
#import "UploadCell.h"
#import "UnfinishedViewController.h"
#import "CategoryModel+Helper.h"
#import "DownloadManager.h"

#define NIB_CELL @"UploadCell"

@interface UploadView()
@property (strong,nonatomic) UITableView* listView;
@property (nonatomic, strong) NSMutableArray * dataArray;/**<数据源*/
@end

@implementation UploadView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"数据上传";
    [self.view addSubview:self.listView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self handleDatas];
    for (int i = 0; i<self.dataArray.count; i++) {
        UploadModel * model = self.dataArray[i];
        if (model.status == UPLOADABLE) {
            model.status = UPLOADING;
            [self checkHistory:model andIndex:i];
        }
    }
    [self.listView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 懒加载
-(NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
        for (CompanyModel * companymodel in self.uploadDatasArray) {
            UploadModel * uploadModel = [[UploadModel alloc] init];
            uploadModel.companymodel = companymodel;
            uploadModel.status = UNFINISH;//默认情况下暂时先给赋值为“未完成”，后面还会进行进一步验证
            [_dataArray addObject:uploadModel];
        }
    }
    return _dataArray;
}

-(UITableView *)listView{
    if(!_listView){
        _listView = [[UITableView alloc] initWithFrame:CGRectMake(20, 0, SCREEN_W - 40,SCREEN_H - TOPNAVIGATIONBAR_H) style:UITableViewStylePlain];
        [_listView registerNib:[UINib nibWithNibName:@"UploadCell" bundle:nil] forCellReuseIdentifier:NIB_CELL];
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView.delegate = self;
        _listView.dataSource = self;
    }
    return _listView;
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UploadCell* cell = [self.listView dequeueReusableCellWithIdentifier:NIB_CELL forIndexPath:indexPath];
    [cell fillWithModel:self.dataArray[indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 115;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UploadModel * model = [self.dataArray objectAtIndex:indexPath.row];
    if (model.status != UNFINISH) {
        return;
    }
    UnfinishedViewController * unfinishedVC = VCFromBundleWithIdentifier(@"UnfinishedViewController");
    unfinishedVC.companymodel = model.companymodel;
    [self.navigationController pushViewController:unfinishedVC animated:YES];
}

#pragma mark - 数据上传
#pragma mark -- 检测后台是否存在历史数据
-(void)checkHistory:(UploadModel *)uploadmodel andIndex:(NSInteger)index
{
    //获取参数:有历史尺寸标记的数据
    NSDictionary * parametersdic = [[self parametersAndDatasByModel:uploadmodel.companymodel andType:CHECKHISTORY]  valueForKey:@"parameters"];
    NSArray * customerArray = [parametersdic valueForKey:@"customer"];
    if (customerArray.count > 0) {//本地存在“历史尺寸”标记的数据时，需先检测
        NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:parametersdic options:NSJSONWritingPrettyPrinted error:nil];
        NSString * parametersStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSDictionary * pdic = @{@"parameters":parametersStr};
        NSString * url = [NSString stringWithFormat:@"%@file/history",HTTP_HEADER];
        [NetworkOperation postWithHost:url andToken:[UserManager getToken] andType:JSONSTRING andParameters:pdic andSuccess:^(id rootobject) {
            NSArray * customers = rootobject;
            if (customers.count > 0) {//如果后台没有找到与本地相匹配的历史尺寸，则会返回相应的人员数组，本地需要根据此数组将人员的历史尺寸状态取消掉，同时将“已完成”状态改为“待量体”
                for (NSDictionary * customerdic in customers) {
                    PersonnelModel * personnelmodel = [PersonnelModel MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"name = %@ AND department = %@ AND gender = %d", [customerdic valueForKey:@"name"], [customerdic valueForKey:@"department"], [[customerdic valueForKey:@"gender"] intValue]]];
                    if (personnelmodel) {
                        personnelmodel.history = NO;
                        personnelmodel.status = 0;
                        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    }
                }
                uploadmodel.status = UNFINISH;
                [self.listView reloadData];
            } else {
                [self uploadData:uploadmodel andIndex:index];
            }
        } andFailure:^(NSError *error, NSString *errorMessage) {
            uploadmodel.status = UPLOADFAILURE;
            [self.listView reloadData];
            [self showHUDMessage:errorMessage];
        }];
    } else {//本地没有有“历史尺寸”标记的数据时，无需检测，可直接上传
        [self uploadData:uploadmodel andIndex:index];
    }
}

#pragma mark -- 上传网络请求
-(void)uploadData:(UploadModel*)uploadmodel andIndex:(NSInteger)index
{
    NSDictionary * parametersdic = [self parametersAndDatasByModel:uploadmodel.companymodel andType:UPLOADDATAS];
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:[parametersdic valueForKey:@"parameters"] options:NSJSONWritingPrettyPrinted error:nil];
    NSString * parametersStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSDictionary * pdic = @{@"parameters":parametersStr};
    [NetworkOperation networkWithHost:[NSString stringWithFormat:@"%@file",HTTP_HEADER] andToken:[UserManager getToken] andParameters:pdic andFormDatas:[parametersdic valueForKey:@"datas"] andSuccess:^(id rootobject) {
        uploadmodel.companymodel.rev = [[rootobject valueForKey:@"rev"] intValue];
        uploadmodel.companymodel.lock_status = YES;//上锁
        uploadmodel.companymodel.upload_lasttime = [NSDate date];
        uploadmodel.companymodel.upload_frequency = uploadmodel.companymodel.upload_frequency+1;
        for (PersonnelModel * personnelmodel in uploadmodel.companymodel.personnel) {//删除忽略的
            if (personnelmodel.ignored) {
                [personnelmodel MR_deleteEntity];
            }
        }

        NSArray * customers = [rootobject valueForKey:@"customers"];
        for (NSDictionary * customerdic in customers) {
            NSManagedObjectContext * pidcontext = [NSManagedObjectContext MR_context];
            PersonnelModel * personnelmodel = [PersonnelModel MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"company = %@ AND name = %@ AND department = %@ AND gender = %d",uploadmodel.companymodel, [customerdic valueForKey:@"name"], [customerdic valueForKey:@"department"], [[customerdic valueForKey:@"gender"] intValue]]];
            if (personnelmodel) {
                personnelmodel.personnelid = [customerdic valueForKey:@"businessId"];
                [pidcontext MR_saveToPersistentStoreAndWait];
            }
        }
        
        //如果上传的数据中含有“历史尺寸”标记，则后台会返回历史尺寸数据，本地将这些数据存储
        NSArray * historyCustomerArray = [rootobject valueForKey:@"info"];
        for (NSDictionary * customerDic in historyCustomerArray) {
            PersonnelModel * originalmodel = [PersonnelModel MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"company = %@ AND personnelid = %@",uploadmodel.companymodel,[customerDic valueForKey:@"businessId"]]];
            NSData * remark = originalmodel.remark;
            NSData * sign = originalmodel.sign;
            [originalmodel MR_deleteEntity];
            DownloadManager * downloadManager = [[DownloadManager alloc] init];
            PersonnelModel * historymodel = [downloadManager customerInfo:customerDic andCompany:uploadmodel.companymodel];
            historymodel.remark = remark;
            historymodel.sign = sign;
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        uploadmodel.status = UPLOADED;
        [self.listView reloadData];
    } andProgress:^(float percentage) {
        
    } andFailure:^(NSError *error, NSString *errorMessage) {//上传失败时，取消忽略状态
        uploadmodel.status = UPLOADFAILURE;
        for (PersonnelModel * model in uploadmodel.companymodel.personnel) {
            if (model.ignored) {
                model.ignored = NO;
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            }
        }
        [self.listView reloadData];
        [self showHUDMessage:errorMessage];
    }];
}

#pragma mark -- 处理网络请求参数:history为yes时，是为检测历史数据提供参数数据；为no时，是为上传提供参数数据。
-(NSDictionary *)parametersAndDatasByModel:(CompanyModel *)companymodel andType:(parameterType)type
{
    NSMutableDictionary * parametersdic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * datasdic = [[NSMutableDictionary alloc] init];
    NSMutableArray * remarks = [[NSMutableArray alloc] init];
    NSMutableArray * sighs = [[NSMutableArray alloc] init];
    [datasdic setValue:remarks forKey:@"remarks"];
    [datasdic setValue:sighs forKey:@"signs"];
    
    [parametersdic setValue:companymodel.companyid forKey:@"missionId"];
    [parametersdic setValue:[NSNumber numberWithInt:companymodel.rev] forKey:@"rev"];
    
    //人员信息数组
    NSMutableArray * customerArray = [[NSMutableArray alloc] init];
    int fileindex = 0;
    for (PersonnelModel * personnelmodel in companymodel.personnel) {
        if (personnelmodel.ignored || personnelmodel.status != 2) {
            continue;
        }
        if (type == CHECKHISTORY && !personnelmodel.history) {
            continue;
        }
        NSMutableDictionary * customerDic = [NSMutableDictionary dictionary];
        [customerDic setValue:personnelmodel.personnelid forKey:@"businessId"];
        [customerDic setValue:personnelmodel.lid forKey:@"userId"];
        [customerDic setValue:personnelmodel.lname forKey:@"userName"];
        [customerDic setValue:companymodel.companyname forKey:@"company"];
        [customerDic setValue:personnelmodel.name forKey:@"name"];
        [customerDic setValue:[NSNumber numberWithInt:personnelmodel.gender] forKey:@"gender"];
        [customerDic setValue:[NSNumber numberWithBool:personnelmodel.history] forKey:@"history"];
        [customerDic setValue:personnelmodel.category_config forKey:@"category"];
        [customerDic setValue:[NSNumber numberWithFloat:personnelmodel.height] forKey:@"height"];
        [customerDic setValue:[NSNumber numberWithFloat:personnelmodel.weight] forKey:@"weight"];
        [customerDic setValue:personnelmodel.department forKey:@"department"];
        NSNumber * source = personnelmodel.mtm ? [NSNumber numberWithInt:2] : [NSNumber numberWithInt:1];
        [customerDic setValue:source forKey:@"source"];
        if (personnelmodel.remark) {
            NSString * filename = [NSString stringWithFormat:@"remark-%d",fileindex];
            NSDictionary * remaredic = [NSDictionary dictionaryWithObjectsAndKeys:personnelmodel.remark,@"data",filename,@"filename", nil];
            [remarks addObject:remaredic];
            [customerDic setValue:filename forKey:@"remark"];
        }
        if (personnelmodel.sign) {
            NSString * filename = [NSString stringWithFormat:@"sign-%d",fileindex];
            NSDictionary * signdic = [NSDictionary dictionaryWithObjectsAndKeys:personnelmodel.sign,@"data",filename,@"filename", nil];
            [sighs addObject:signdic];
            [customerDic setValue:filename forKey:@"sign"];
        }
        fileindex ++;
        [customerDic setValue:personnelmodel.edittime forKey:@"appTime"];
        //净体数据
        NSMutableArray * bBodyParts = [[NSMutableArray alloc] init];
        for (PositionModel * positionmodel in personnelmodel.position) {
            NSMutableDictionary * bodypartdic = [[NSMutableDictionary alloc] init];
            [bodypartdic setValue:positionmodel.positionname forKey:@"name"];
            [bodypartdic setValue:positionmodel.blcode forKey:@"code"];
            [bodypartdic setValue:[NSNumber numberWithInt:positionmodel.size] forKey:@"size"];
            [bBodyParts addObject:bodypartdic];
        }
        [customerDic setValue:bBodyParts forKey:@"bBodyParts"];
        
        //特体数据
        NSMutableArray * bSpecialInfos = [[NSMutableArray alloc] init];
        for (NSString * specialcode in [personnelmodel.specialoptions componentsSeparatedByString:@","]) {
            if (specialcode.length > 0) {
                NSDictionary * specialdic = @{@"code":specialcode};
                [bSpecialInfos addObject:specialdic];
            }
        }
        [customerDic setValue:bSpecialInfos forKey:@"bSpecialInfos"];
        
        //品类数据
        NSMutableArray * bConfigurations = [[NSMutableArray alloc] init];
        for (CategoryModel * categorymodel in personnelmodel.category) {
            //夏天品类数据
            if (categorymodel.summerCount > 0) {
                NSDictionary * summerCateDic = [self categoryDict:categorymodel season:0];
                [bConfigurations addObject:summerCateDic];
            }
            //冬天品类数据
            if (categorymodel.winterCount > 0) {
                NSDictionary * winterCateDic = [self categoryDict:categorymodel season:1];
                [bConfigurations addObject:winterCateDic];
            }
        }
        [customerDic setValue:bConfigurations forKey:@"bConfigurations"];
        [customerArray addObject:customerDic];
    }
    [parametersdic setValue:customerArray forKey:@"customer"];
    return @{@"parameters":parametersdic,@"datas":datasdic};
}

//品类数据
-(NSDictionary *)categoryDict:(CategoryModel *)categorymodel season:(int)season
{
    NSMutableDictionary * cateDic = [[NSMutableDictionary alloc] init];
    int count = season == 0 ? categorymodel.summerCount : categorymodel.winterCount;
    if (count > 0) {
        //基本信息
        [cateDic setValue:categorymodel.cate forKey:@"cate"];
        [cateDic setValue:[NSNumber numberWithInt:season] forKey:@"season"];
        [cateDic setValue:[NSNumber numberWithInt:categorymodel.type] forKey:@"type"];
        [cateDic setValue:[NSNumber numberWithInt:count] forKey:@"count"];
        //部位信息
        if (categorymodel.type == 0) {
            //净体附加信息
            NSMutableArray * bBodyPartInfos = [[NSMutableArray alloc] init];
            AdditionModel * additionmodel = [categorymodel getAdditionItemBySeason:season];
            if (additionmodel.value_clothes > 0) {
                NSMutableDictionary * additionDic = [[NSMutableDictionary alloc] init];
                [additionDic setValue:[NSNumber numberWithInteger:additionmodel.increase] forKey:@"increase"];
                [additionDic setValue:@"15" forKey:@"blcode"];
                [additionDic setValue:[NSNumber numberWithInteger:additionmodel.value_clothes] forKey:@"value"];
                [bBodyPartInfos addObject:additionDic];
            }
            if (additionmodel.value_pants > 0) {
                NSMutableDictionary * additionDic = [[NSMutableDictionary alloc] init];
                [additionDic setValue:[NSNumber numberWithInteger:additionmodel.increase] forKey:@"increase"];
                [additionDic setValue:@"16" forKey:@"blcode"];
                [additionDic setValue:[NSNumber numberWithInteger:additionmodel.value_pants] forKey:@"value"];
                [bBodyPartInfos addObject:additionDic];
            }
            if (additionmodel.value_pleat > 0) {
                NSMutableDictionary * additionDic = [[NSMutableDictionary alloc] init];
                [additionDic setValue:[NSNumber numberWithInteger:additionmodel.increase] forKey:@"increase"];
                [additionDic setValue:@"zzfg_XK" forKey:@"blcode"];
                [additionDic setValue:[NSNumber numberWithInteger:additionmodel.value_pleat] forKey:@"value"];
                [bBodyPartInfos addObject:additionDic];
            }
            if (additionmodel.value_shoulder > 0) {
                NSMutableDictionary * additionDic = [[NSMutableDictionary alloc] init];
                [additionDic setValue:[NSNumber numberWithInteger:additionmodel.increase] forKey:@"increase"];
                [additionDic setValue:@"11" forKey:@"blcode"];
                [additionDic setValue:[NSNumber numberWithInteger:additionmodel.value_shoulder] forKey:@"value"];
                [bBodyPartInfos addObject:additionDic];
            }
            if (additionmodel.value_sleeve > 0) {
                NSMutableDictionary * additionDic = [[NSMutableDictionary alloc] init];
                [additionDic setValue:[NSNumber numberWithInteger:additionmodel.increase] forKey:@"increase"];
                [additionDic setValue:@"13" forKey:@"blcode"];
                [additionDic setValue:[NSNumber numberWithInteger:additionmodel.value_sleeve] forKey:@"value"];
                [bBodyPartInfos addObject:additionDic];
            }
            if (additionmodel.value_waist > 0) {
                NSMutableDictionary * additionDic = [[NSMutableDictionary alloc] init];
                [additionDic setValue:[NSNumber numberWithInteger:additionmodel.increase] forKey:@"increase"];
                [additionDic setValue:@"4" forKey:@"blcode"];
                [additionDic setValue:[NSNumber numberWithInteger:additionmodel.value_waist] forKey:@"value"];
                [bBodyPartInfos addObject:additionDic];
            }
            [cateDic setValue:bBodyPartInfos forKey:@"bBodyPartInfos"];
        } else {
            NSMutableArray * bClothesParts = [[NSMutableArray alloc] init];
            for (PositionModel * positionmodel in categorymodel.position) {
                if (positionmodel.type == 1) {
                    NSMutableDictionary * positionDic = [[NSMutableDictionary alloc] init];
                    [positionDic setValue:positionmodel.blcode forKey:@"code"];
                    [positionDic setValue:positionmodel.positionname forKey:@"name"];
                    int size = season == 0 ? positionmodel.size : positionmodel.size_winter;
                    [positionDic setValue:[NSNumber numberWithInt:size] forKey:@"size"];
                    [bClothesParts addObject:positionDic];
                }
            }
            [cateDic setValue:bClothesParts forKey:@"bClothesParts"];
        }
    }
    return cateDic;
}

#pragma mark - 数据初步处理
-(void)handleDatas
{
    for (UploadModel * uploadModel in self.dataArray) {
        if (uploadModel.status == UNFINISH) {//未完成数据时需要先判断再处理
            
            NSPredicate *finishFilter = [NSPredicate predicateWithFormat:@"status  == 2 AND company == %@",uploadModel.companymodel];//已完成数据搜索条件
            NSPredicate *ignoreFilter = [NSPredicate predicateWithFormat:@"company == %@ AND ignored == true",uploadModel.companymodel];//已忽略数据搜索条件
            NSPredicate *processingFilter = [NSPredicate predicateWithFormat:@"status  == 1 AND company == %@ AND ignored == false",uploadModel.companymodel];//进行中且未忽略的数据搜索条件
            
            NSInteger finishcount = [PersonnelModel MR_findAllWithPredicate:finishFilter].count;
            NSInteger ignorecount = [PersonnelModel MR_findAllWithPredicate:ignoreFilter].count;
            NSInteger processingcount = [PersonnelModel MR_findAllWithPredicate:processingFilter].count;
            if (finishcount == 0) {//没有已完成的数据
                if (processingcount > 0) {
                    uploadModel.status = UNFINISH;
                } else {
                    uploadModel.status = NOUPLOADDATAS;
                }
            } else if (finishcount + ignorecount == uploadModel.companymodel.personnel.count) {
                uploadModel.status = UPLOADABLE;
            } else {
                uploadModel.status = UNFINISH;
            }
        } else {
            continue;
        }
    }
}

@end
