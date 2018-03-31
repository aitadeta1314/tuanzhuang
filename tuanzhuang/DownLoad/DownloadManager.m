//
//  DownloadManager.m
//  tuanzhuang
//
//  Created by red on 2018/3/22.
//  Copyright © 2018年 red. All rights reserved.
//

#import "DownloadManager.h"
#import "GetLetter.h"
@interface DownloadManager ()
@property (nonatomic, strong) NSMutableArray * failureArray;/**<下载失败任务id数组*/
@property (nonatomic, strong) NSArray * missionArray;/**<任务数组*/
@property (nonatomic, strong) NSThread * thread;/**<异步解析数据用到的线程*/
@property (nonatomic, assign) BOOL cover;/**<是否覆盖*/
@end

@implementation DownloadManager

-(instancetype)init
{
    if (self = [super init]) {
        _failureArray = [[NSMutableArray alloc] init];
    }
    return self;
}

static failureBlock _failureblock;
-(void)handleDownloadDatas:(NSArray *)missionArray andCover:(BOOL)cover andFailureMissions:(failureBlock)failuremissions
{
    _failureblock = failuremissions;
    self.cover = cover;
    self.missionArray = missionArray;
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(analyticalData) object:@"thread"];
    [self.thread start];
    
}

#pragma mark -- 停止线程
-(void)stop
{
    [self.thread cancel];
}

#pragma mark -- 解析数据、获取图片data
-(void)analyticalData
{
    NSMutableArray * tmparray = [[NSMutableArray alloc] init];
    for (NSDictionary * missiondic in self.missionArray) {
        NSMutableDictionary * companydic = [[NSMutableDictionary alloc] init];
        [companydic setValue:[missiondic valueForKey:@"missionId"] forKey:@"missionId"];
        [companydic setValue:[missiondic valueForKey:@"missionName"] forKey:@"missionName"];
        [companydic setValue:[missiondic valueForKey:@"company"] forKey:@"company"];
        [companydic setValue:[missiondic valueForKey:@"rev"] forKey:@"rev"];
        NSMutableArray * customerArray = [[NSMutableArray alloc] init];
        [companydic setValue:customerArray forKey:@"customer"];
        for (NSDictionary * customerdic in [missiondic valueForKey:@"customer"]) {
            NSMutableDictionary * tempdic = [[NSMutableDictionary alloc] init];
            [tempdic setValue:[customerdic valueForKey:@"name"] forKey:@"name"];
            [tempdic setValue:[customerdic valueForKey:@"businessId"] forKey:@"businessId"];
            [tempdic setValue:[customerdic valueForKey:@"department"] forKey:@"department"];
            [tempdic setValue:[customerdic valueForKey:@"appTime"] forKey:@"appTime"];
            [tempdic setValue:[customerdic valueForKey:@"gender"] forKey:@"gender"];
            if ([customerdic valueForKey:@"remark"]!= [NSNull null] && [[customerdic valueForKey:@"remark"] length] > 0) {
                NSData *remarkData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[customerdic valueForKey:@"remark"]]];
                if ([remarkData isValidObject]) {
                    [tempdic setValue:remarkData forKey:@"remark"];
                } else {
                    [_failureArray addObject:[missiondic valueForKey:@"missionId"]];
                    break;
                }
            }
            if ([customerdic valueForKey:@"sign"]!= [NSNull null] && [[customerdic valueForKey:@"sign"] length] > 0) {
                NSData *signData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[customerdic valueForKey:@"sign"]]];
                if ([signData isValidObject]) {
                    [tempdic setValue:signData forKey:@"sign"];
                } else {
                    [_failureArray addObject:[missiondic valueForKey:@"missionId"]];
                    break;
                }
            }
            if ([customerdic valueForKey:@"height"] != [NSNull null]) {
                [tempdic setValue:[customerdic valueForKey:@"height"] forKey:@"height"];
            }
            if ([customerdic valueForKey:@"weight"] != [NSNull null]) {
                [tempdic setValue:[customerdic valueForKey:@"weight"] forKey:@"weight"];
            }
            [tempdic setValue:[customerdic valueForKey:@"source"] forKey:@"source"];
            [tempdic setValue:[customerdic valueForKey:@"category"] forKey:@"category"];
            [tempdic setValue:[customerdic valueForKey:@"userId"] forKey:@"userId"];
            [tempdic setValue:[customerdic valueForKey:@"userName"] forKey:@"userName"];
            [tempdic setValue:[customerdic valueForKey:@"status"] forKey:@"status"];
            [tempdic setValue:[customerdic valueForKey:@"bSpecialInfos"] forKey:@"bSpecialInfos"];
            [tempdic setValue:[customerdic valueForKey:@"bBodyParts"] forKey:@"bBodyParts"];
            [tempdic setValue:[customerdic valueForKey:@"bConfigurations"] forKey:@"bConfigurations"];
            [customerArray addObject:tempdic];
        }
        if ([NSThread currentThread].isCancelled) {
            [NSThread exit];
            return;
        }
        [tmparray addObject:companydic];
    }
    self.missionArray = tmparray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self storageData];
    });
}

#pragma mark -- -- 存储数据
-(void)storageData
{
    /*
    NSMutableArray * originalArr = [[NSMutableArray alloc] init];
     */
    for (NSDictionary * missiondic in self.missionArray) {
        NSString * missionidStr = [missiondic valueForKey:@"missionId"];
        if ([self.failureArray containsObject:missionidStr]) {//失败的任务（图片没有加载成功）不存储
            break;
        }
        
        if (self.cover) {
            CompanyModel * originalCompany = [CompanyModel MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"companyid = %@", missionidStr]];
            [originalCompany MR_deleteEntity];
        }
        
        /*
        //先暂存原有数据，以便于下载成功以后进行删除
        CompanyModel * originalCompany = [CompanyModel MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"companyid = %@", missionidStr]];
        if (originalCompany) {
            [originalArr addObject:originalCompany];
        }
         */
        
        CompanyModel * company = [CompanyModel MR_createEntity];
        company.companyid = [missiondic valueForKey:@"missionId"];
        company.missionname = [missiondic valueForKey:@"missionName"];
        company.companyname = [missiondic valueForKey:@"company"];
        company.addtime = [NSDate date];
        company.lock_status = false;
        company.rev = [[missiondic valueForKey:@"rev"] intValue];
        for (NSDictionary * customerdic in [missiondic valueForKey:@"customer"]) {
            [self customerInfo:customerdic andCompany:company];
        }
    }
    
    /*
    //如果下载成功，删除原有数据
    for (CompanyModel * companymodel in originalArr) {
        [companymodel MR_deleteEntity];
    }
     */
    if (_failureblock) {
        _failureblock(_failureArray);
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

#pragma mark -- -- 解析、存储“人员”数据
-(PersonnelModel *)customerInfo:(NSDictionary *)customerdic andCompany:(CompanyModel *)company
{
    PersonnelModel *personnel = [PersonnelModel MR_createEntity];
    if ([[customerdic valueForKey:@"status"] intValue] > 1) {
        [personnel MR_deleteEntity];
        return nil;
    }
    personnel.status = [[customerdic valueForKey:@"status"] intValue]*2;
    personnel.company = company;
    personnel.companyid = company.companyid;
    personnel.name = [customerdic valueForKey:@"name"];
    personnel.personnelid = [customerdic valueForKey:@"businessId"];
    personnel.firstletter = [GetLetter firstLetterOfString:personnel.name];
    personnel.department = [customerdic valueForKey:@"department"];
    personnel.edittime = [customerdic valueForKey:@"appTime"];
    personnel.gender = [[customerdic valueForKey:@"gender"] intValue];
    // 备注图片
    if ([customerdic valueForKey:@"remark"] != [NSNull null] && [[customerdic valueForKey:@"remark"] isKindOfClass:[NSData class]]) {
        personnel.remark = [customerdic valueForKey:@"remark"];
    }
    // 签名图片
    if ([customerdic valueForKey:@"sign"] != [NSNull null] && [[customerdic valueForKey:@"sign"] isKindOfClass:[NSData class]]) {
        personnel.remark = [customerdic valueForKey:@"sign"];
    }
    
    if ([customerdic valueForKey:@"height"] != [NSNull null]) {
        personnel.height = [[customerdic valueForKey:@"height"] floatValue];
    }
    if ([customerdic valueForKey:@"weight"] != [NSNull null]) {
        personnel.weight = [[customerdic valueForKey:@"weight"] floatValue];
    }
    personnel.mtm = [[customerdic valueForKey:@"source"] intValue] == 2;
    if ([customerdic valueForKey:@"category"] != [NSNull null]) {
        personnel.category_config = [customerdic valueForKey:@"category"];
    }
    if ([customerdic valueForKey:@"userId"] != [NSNull null]) {
        personnel.lid = [customerdic valueForKey:@"userId"];
    }
    if ([customerdic valueForKey:@"userName"] != [NSNull null]) {
        personnel.lname = [customerdic valueForKey:@"userName"];
    }
    personnel.specialoptions = [self specialoptions:[customerdic valueForKey:@"bSpecialInfos"]];
    [self bodyParts:[customerdic valueForKey:@"bBodyParts"] ofPersonnel:personnel];
    [self configurations:[customerdic valueForKey:@"bConfigurations"] ofPersonnel:personnel];
    return personnel;
}

#pragma mark -- -- 解析、存储 “品类” 数据
-(void)configurations:(NSArray *)configurations ofPersonnel:(PersonnelModel *)personnelmodel
{
    //第一步：现将所品类归类,存入 categorysDic 字典
    NSMutableDictionary * categorysDic = [[NSMutableDictionary alloc] init];
    for (NSDictionary * cateDic in configurations) {
        NSString * categoryname = [cateDic valueForKey:@"cate"];
        if ([[categorysDic allKeys] containsObject:categoryname]) {
            NSMutableDictionary * subDic = [categorysDic valueForKey:categoryname];
            if ([[cateDic valueForKey:@"season"] intValue] == 0) {
                [subDic setValue:cateDic forKey:@"summer"];
            } else {
                [subDic setValue:cateDic forKey:@"winter"];
            }
        } else {
            NSMutableDictionary * subDic = [[NSMutableDictionary alloc] init];
            if ([[cateDic valueForKey:@"season"] intValue] == 0) {
                [subDic setValue:cateDic forKey:@"summer"];
            } else {
                [subDic setValue:cateDic forKey:@"winter"];
            }
            [categorysDic setValue:subDic forKey:categoryname];
        }
    }
    //第二步:生成categorymodel
    for (NSString * key in [categorysDic allKeys]) {
        CategoryModel * categorymodel = [CategoryModel MR_createEntity];
        categorymodel.cate = key;
        categorymodel.personnelid = personnelmodel.personnelid;
        categorymodel.personnel = personnelmodel;
        NSDictionary * subDic = [categorysDic valueForKey:key];
        NSArray * summerArray;
        NSArray * winterArray;
        if ([subDic valueForKey:@"summer"]) {
            NSDictionary * sumdic = [subDic valueForKey:@"summer"];
            categorymodel.count += [[sumdic valueForKey:@"count"] intValue];
            categorymodel.summerCount = [[sumdic valueForKey:@"count"] intValue];
            categorymodel.type = [[sumdic valueForKey:@"type"] intValue];
            summerArray = categorymodel.type == 0 ? [sumdic valueForKey:@"bBodyPartInfos"] : [sumdic valueForKey:@"bClothesParts"];
        }
        if ([subDic valueForKey:@"winter"]) {
            NSDictionary * winterdic = [subDic valueForKey:@"winter"];
            categorymodel.count += [[winterdic valueForKey:@"count"] intValue];
            categorymodel.winterCount = [[winterdic valueForKey:@"count"] intValue];
            categorymodel.type = [[winterdic valueForKey:@"type"] intValue];
            winterArray = categorymodel.type == 0 ? [winterdic valueForKey:@"bBodyPartInfos"] : [winterdic valueForKey:@"bClothesParts"];
        }
        if (categorymodel.type == 1) {
            [self clotheSummerParts:summerArray andWinter:winterArray ofCategory:categorymodel];
        } else {
            [self bodySummerParts:summerArray andWinter:winterArray ofCategory:categorymodel];
        }
    }
}
#pragma mark -- -- 解析、存储 “成衣部位” 数据
-(void)clotheSummerParts:(NSArray *)summerparts andWinter:(NSArray *)winterparts ofCategory:(CategoryModel *)categorymodel
{
    if (summerparts && winterparts) {
        for (NSDictionary * summerpartdic in summerparts) {
            PositionModel * positionmodel = [PositionModel MR_createEntity];
            positionmodel.blcode = [summerpartdic valueForKey:@"code"];
            positionmodel.positionname = [summerpartdic valueForKey:@"name"];
            positionmodel.size = [[summerpartdic valueForKey:@"size"] intValue];
            for (NSDictionary * winterpartdic in winterparts) {
                if ([[winterparts valueForKey:@"code"] isEqualToString:positionmodel.blcode]) {
                    positionmodel.size_winter = [[winterpartdic valueForKey:@"size"] intValue];
                    break;
                }
            }
            positionmodel.category = categorymodel;
            positionmodel.type = 1;
        }
    } else {
        int season = 0;
        NSArray * parts = summerparts;
        if (winterparts) {
            season = 1;
            parts = winterparts;
        }
        for (NSDictionary * partdic in parts) {
            PositionModel * positionmodel = [PositionModel MR_createEntity];
            positionmodel.blcode = [partdic valueForKey:@"code"];
            positionmodel.positionname = [partdic valueForKey:@"name"];
            if (season == 0) {
                positionmodel.size = [[partdic valueForKey:@"size"] intValue];
            } else {
                positionmodel.size_winter = [[partdic valueForKey:@"size"] intValue];
            }
            positionmodel.category = categorymodel;
            positionmodel.type = 1;
        }
        
    }
}

#pragma mark -- -- 解析、存储 “净体附加部位” 数据
-(void)bodySummerParts:(NSArray *)summerparts andWinter:(NSArray *)winterparts ofCategory:(CategoryModel *)categorymodel
{
    for (int i = 0; i<categorymodel.summerCount; i++) {
        AdditionModel * additionmodel = [AdditionModel MR_createEntity];
        additionmodel.category = categorymodel;
        additionmodel.season = 0;
        for (NSDictionary * summerdic in summerparts) {
            if ([summerdic valueForKey:@"increase"]) {
                additionmodel.increase = [[summerdic valueForKey:@"increase"] intValue];
            }
            if ([[summerdic valueForKey:@"blcode"] isEqualToString:@"15"]) {
                additionmodel.value_clothes = [[summerdic valueForKey:@"value"] intValue];
                additionmodel.blcode_clothes = [summerdic valueForKey:@"blcode"];
            }
            if ([[summerdic valueForKey:@"blcode"] isEqualToString:@"16"]) {
                additionmodel.value_pants = [[summerdic valueForKey:@"value"] intValue];
                additionmodel.blcode_pants = [summerdic valueForKey:@"blcode"];
            }
            if ([[summerdic valueForKey:@"blcode"] isEqualToString:@"zzfg_XK"]) {
                additionmodel.value_pleat = [[summerdic valueForKey:@"value"] intValue];
                additionmodel.blcode_pleat = [summerdic valueForKey:@"blcode"];
            }
            if ([[summerdic valueForKey:@"blcode"] isEqualToString:@"11"]) {
                additionmodel.value_shoulder = [[summerdic valueForKey:@"value"] intValue];
                additionmodel.blcode_shoulder = [summerdic valueForKey:@"blcode"];
            }
            if ([[summerdic valueForKey:@"blcode"] isEqualToString:@"13"]) {
                additionmodel.value_sleeve = [[summerdic valueForKey:@"value"] intValue];
                additionmodel.blcode_sleeve = [summerdic valueForKey:@"blcode"];
            }
            if ([[summerdic valueForKey:@"blcode"] isEqualToString:@"4"]) {
                additionmodel.value_waist = [[summerdic valueForKey:@"value"] intValue];
                additionmodel.blcode_waist = [summerdic valueForKey:@"blcode"];
            }
        }
    }
    for (int j = 0; j<categorymodel.winterCount; j++) {
        AdditionModel * additionmodel = [AdditionModel MR_createEntity];
        additionmodel.category = categorymodel;
        additionmodel.season = 1;
        for (NSDictionary * winterdic  in winterparts) {
            if ([winterdic valueForKey:@"increase"]) {
                additionmodel.increase = [[winterdic valueForKey:@"increase"] intValue];
            }
            if ([[winterdic valueForKey:@"blcode"] isEqualToString:@"15"]) {
                additionmodel.value_clothes = [[winterdic valueForKey:@"value"] intValue];
                additionmodel.blcode_clothes = [winterdic valueForKey:@"blcode"];
            }
            if ([[winterdic valueForKey:@"blcode"] isEqualToString:@"16"]) {
                additionmodel.value_pants = [[winterdic valueForKey:@"value"] intValue];
                additionmodel.blcode_pants = [winterdic valueForKey:@"blcode"];
            }
            if ([[winterdic valueForKey:@"blcode"] isEqualToString:@"zzfg_XK"]) {
                additionmodel.value_pleat = [[winterdic valueForKey:@"value"] intValue];
                additionmodel.blcode_pleat = [winterdic valueForKey:@"blcode"];
            }
            if ([[winterdic valueForKey:@"blcode"] isEqualToString:@"11"]) {
                additionmodel.value_shoulder = [[winterdic valueForKey:@"value"] intValue];
                additionmodel.blcode_shoulder = [winterdic valueForKey:@"blcode"];
            }
            if ([[winterdic valueForKey:@"blcode"] isEqualToString:@"13"]) {
                additionmodel.value_sleeve = [[winterdic valueForKey:@"value"] intValue];
                additionmodel.blcode_sleeve = [winterdic valueForKey:@"blcode"];
            }
            if ([[winterdic valueForKey:@"blcode"] isEqualToString:@"4"]) {
                additionmodel.value_waist = [[winterdic valueForKey:@"value"] intValue];
                additionmodel.blcode_waist = [winterdic valueForKey:@"blcode"];
            }
        }
    }
    
}
#pragma mark -- -- 解析、存储 “净体部位” 数据
-(void)bodyParts:(NSArray *)bodyparts ofPersonnel:(PersonnelModel *)personnelmodel
{
    for (NSDictionary * bodypartdic in bodyparts) {
        PositionModel * positionmodel = [PositionModel MR_createEntity];
        positionmodel.blcode = [bodypartdic valueForKey:@"code"];
        positionmodel.personnelid = [bodypartdic valueForKey:@"businessId"];
        positionmodel.positionname = [bodypartdic valueForKey:@"name"];
        positionmodel.size = [[bodypartdic valueForKey:@"size"] intValue];
        positionmodel.type = 0;
        positionmodel.personnel = personnelmodel;
    }
}
#pragma mark -- -- 解析、存储 “特体信息” 数据
-(NSString *)specialoptions:(NSArray *)specialinfos
{
    NSString * specialoptions = @"";
    for (NSDictionary * specialDic in specialinfos) {
        specialoptions = [NSString stringWithFormat:@"%@,%@",[specialDic valueForKey:@"code"],specialoptions];
    }
    if (specialoptions.length > 1) {
        specialoptions = [specialoptions substringWithRange:NSMakeRange(0, specialoptions.length-2)];
    }
    return specialoptions;
}

@end
