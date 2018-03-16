//
//  SynchronizeData.m
//  tuanzhuang
//
//  Created by red on 2018/1/2.
//  Copyright © 2018年 red. All rights reserved.
//

#import "SynchronizeData.h"
#import <CommonCrypto/CommonDigest.h>

@implementation SynchronizeData

#pragma mark - 多点连接
+(void)multiCreateFile:(CompanyModel *)companymodel{
    NSURL* url = [SynchronizeData fileUrlWithCompany:companymodel];
    // 
    [UserManager setUserInfo:@"syncPlistUrl" value:[url relativePath]];
    [UserManager setUserInfo:@"companyId" value:companymodel.companyid];
    //
    //NSString * servicetype = [NSString stringWithFormat:@"RCserviceType%@%@",[UserManager getCname],companymodel.companyid];
    [UserManager setUserInfo:@"multiType" value:[SynchronizeData MD5ForUpper15Bate:@"randomType"]];
}

+(void)multiUpdateModel{
    NSLog(@"记录同步次数");
    NSString* companyId = [UserManager getUserInfo:@"companyId"];
    if(companyId==nil){
        NSLog(@"(ERROR) 同步完成保存model: 公司id不存在，更新异常！");
        return;
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveWithBlock:^(NSManagedObjectContext* localContext) {
        NSPredicate* sql = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"companyid == '%@' ",companyId]];
        CompanyModel* one = [CompanyModel MR_findFirstWithPredicate:sql inContext:localContext];
        one.tb_lasttime = [NSDate date];
        one.tb_frequency = one.tb_frequency + 1;
        NSLog(@"------%d-----",one.tb_frequency);
    } completion:^(BOOL contextDidSave, NSError* error) {
        if(!contextDidSave){
            NSLog(@"(ERROR) 同步完成保存model : 保存异常如何处理！！！");
        }
    }];
}

#pragma mark - 生成plist文件
+(NSURL *)createSyncFile:(NSMutableDictionary*)dic{
    NSString * filename = [NSString stringWithFormat:@"from%@.plist",[UserManager getName]];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docPath stringByAppendingPathComponent:filename];
    [dic writeToFile:filePath atomically:YES];
    if ([dic writeToFile:filePath atomically:YES]) {
        return [NSURL fileURLWithPath:filePath];
    } else {
        NSLog(@"******plist文件生成失败!******");
        return nil;
    }
}

+(NSURL *)fileUrlWithCompany:(CompanyModel *)companymodel
{
    //从数据库获取当前公司的所有人员数据
    NSPredicate *peopleFilter = [NSPredicate predicateWithFormat:@"status = 2 AND companyid = %@", companymodel.companyid];
    NSFetchRequest *peopleRequest = [PersonnelModel MR_requestAllWithPredicate:peopleFilter];
    [peopleRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstletter"ascending:YES]]];
    NSArray * modelArray = [PersonnelModel MR_executeFetchRequest:peopleRequest];
    NSMutableDictionary * sourceDic = [[NSMutableDictionary alloc] init];
    NSMutableArray * sourceArray = [[NSMutableArray alloc] init];
    for (PersonnelModel * pmodel in modelArray) {
        //人员基本数据
        NSDictionary * personnelDic = [[NSDictionary alloc] init];
        personnelDic = [self personnelDicByModel:pmodel];
        [sourceArray addObject:personnelDic];
    }
    [sourceDic setValue:sourceArray forKey:@"source"];
    [sourceDic setValue:[NSNumber numberWithInteger:companymodel.rev] forKey:@"rev"];
    return [SynchronizeData createSyncFile:sourceDic];
}

#pragma mark - 删除plist文件
+(void)deletFile:(NSString *)filename
{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        BOOL blDele= [fileManager removeItemAtPath:filePath error:nil];
        if (blDele) {
            NSLog(@"dele success");
        } else {
            NSLog(@"dele fail");
        }
    } else {
        NSLog(@"file not exists");
    }
}

#pragma mark - 将master分发的文件转化成model并保存
+(void)handleMasterDataWithFileUrl:(NSURL *)url
{
    NSDictionary * masterDic = [NSDictionary dictionaryWithContentsOfURL:url];
    NSArray * sourceArray = [masterDic valueForKey:@"source"];
    NSDictionary * tmpdic = [sourceArray firstObject];
    NSString * companyid = [tmpdic valueForKey:@"companyid"];
    [PersonnelModel MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"status = 2 AND companyid = %@", companyid]];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    for (NSDictionary * dic in sourceArray) {
        [self personnelModelByDic:dic];
    }
    CompanyModel * company = [CompanyModel MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"companyid = %@",companyid]];
    company.rev = [[masterDic valueForKey:@"rev"] integerValue];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

#pragma mark - 生成同步servicetype字符串
//MD5加密
+(NSString *)MD5ForUpper15Bate:(NSString *)str{
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02X", result[i]];
    }
    return [digest substringWithRange:NSMakeRange(8, 15)];
}

#pragma mark - 单纯的合并数据
+(NSDictionary *)mergeMasterDic:(NSDictionary *)masterDic andSlaveDic:(NSDictionary *)slaveDic
{
    NSMutableDictionary * mergeDic = [[NSMutableDictionary alloc] init];
    NSInteger rev = MAX([[masterDic valueForKey:@"rev"] integerValue], [[slaveDic valueForKey:@"rev"] integerValue]);
    [mergeDic setValue:[NSNumber numberWithInteger:rev] forKey:@"rev"];
    [mergeDic setValue:[[masterDic valueForKey:@"source"] arrayByAddingObjectsFromArray:[slaveDic valueForKey:@"source"]] forKey:@"source"];
    return mergeDic;
}

#pragma mark - 重新处理同步数据
+(NSDictionary *)rehandleSynchronizeDict:(NSDictionary *)dic
{
    NSMutableDictionary * synDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    NSMutableArray * sourceArray = [[NSMutableArray alloc] init];
    for (NSArray * array in [dic valueForKey:@"repeat"]) {
        [sourceArray addObjectsFromArray:array];
    }
    [sourceArray addObjectsFromArray:[dic valueForKey:@"nonrepeat"]];
    [sourceArray addObjectsFromArray:[dic valueForKey:@"original"]];
    [synDic setValuesForKeysWithDictionary:[self handleSourceArray:sourceArray]];
    return synDic;
}

#pragma mark - 合并、处理数据
+(NSDictionary *)handleMasterDic:(NSDictionary *)masterDic andSlaveDic:(NSDictionary *)slaveDic
{
    NSMutableDictionary * mergeDic = [[NSMutableDictionary alloc] init];
    NSInteger rev = MAX([[masterDic valueForKey:@"rev"] integerValue], [[slaveDic valueForKey:@"rev"] integerValue]);
    [mergeDic setValue:[NSNumber numberWithInteger:rev] forKey:@"rev"];
    [mergeDic setValuesForKeysWithDictionary:[self handleSourceArray:[NSMutableArray arrayWithArray:[[masterDic valueForKey:@"source"] arrayByAddingObjectsFromArray:[slaveDic valueForKey:@"source"]]]]];
    return mergeDic;
}

//处理新建数据：将新建数据按照重复情况进行分组
+(NSMutableDictionary *)handleSourceArray:(NSMutableArray *)sourceArray
{
    NSMutableDictionary * mergeDic = [[NSMutableDictionary alloc] init];
    NSMutableArray * repeatArray = [[NSMutableArray alloc] init];//重复的数据，是一个二维数组，每个元素都是一组重复的数据
    NSMutableArray * nonrepeatArray = [[NSMutableArray alloc] init];//不重复的数据，是一个一维数组，每个元素对应一个人员信息
    NSMutableArray * originalArray = [[NSMutableArray alloc] init];//不可编辑数据，含有“personnelid”的数据
    
    while (sourceArray.count > 0) {
        /* 每次循环都将重复的元素集中到一起，挪到最顶部
         * 然后截取顶部重复的数据，以数组的形式存入 repeatArray
         * 截取完后，将顶部重复的数据移除，准备新一轮循环
         */
        int k = 0;
        int q = k+1;
        NSMutableDictionary * dic_k = sourceArray[k];
        for (int i = q; i < sourceArray.count; i++) {
            NSMutableDictionary * dic_i = sourceArray[i];
            if ([[dic_k valueForKey:@"name"] isEqualToString:[dic_i valueForKey:@"name"]] && [[dic_k valueForKey:@"gender"] integerValue] == [[dic_i valueForKey:@"gender"] integerValue] && [[dic_k valueForKey:@"department"] isEqualToString:[dic_i valueForKey:@"department"]]) {//如果两个人员信息的 姓名、性别、部门均相等，则视为重复
                if (i > q) {
                    NSMutableDictionary * dic_q = sourceArray[q];
                    sourceArray[q] = sourceArray[i];
                    sourceArray[i] = dic_q;
                }
                q++;
            }
        }
        
        if (q-k == 1) {//没有与当前元素重复的，此元素存入不重复数组当中
            [nonrepeatArray addObject:dic_k];
        } else {
            //将本次遍历后重复的数据归为一组，并存入重复的数据数组当中，存入之前要去重（对除了姓名、性别、部门相等外，量体人、编辑时间也相等的数据进行排重）
            NSArray * subArray = [self handleSubArray:[sourceArray subarrayWithRange:NSMakeRange(k, q-k)]];
            if (subArray.count >1) {//经过进一步排重处理后，如果返回的数组多于一个元素，则将其插入到重复数组，否则插入到不重复数组
                [repeatArray addObject:subArray];
            } else {
                NSDictionary * dict = subArray[0];
                if ([[dict valueForKey:@"personnelid"] length] > 0) {
                    [originalArray addObject:dict];
                } else {
                    [nonrepeatArray addObject:dict];
                }
            }
        }
        [sourceArray removeObjectsInRange:NSMakeRange(k, q-k)];
    }
    [mergeDic setValue:repeatArray forKey:@"repeat"];
    [mergeDic setValue:nonrepeatArray forKey:@"nonrepeat"];
    [mergeDic setValue:originalArray forKey:@"original"];
    return mergeDic;
}

//分两种情况处理重复的分组
//（1）重复的分组中存在含有“personnelid”的数据，则此组数据需筛选出“edittime”最大的数据，并将其转化为“不可编辑”数据（即赋值“personnelid”）
//（2）重复的分组中不存在含有“personnelid”的数据，则此组数据需排重完全重复的数据即：姓名、性别、部门、量体师、编辑时间都相同的数据
+(NSArray *)handleSubArray:(NSArray *)subarray
{
    //判断此重复数据数组中是否存在含有“personnelid”字段的数据,若有则记录“personnelid”
    NSString * personnelid = @"";
    for (NSMutableDictionary * dic in subarray) {
        if ([[dic valueForKey:@"personnelid"] length] > 0) {
            personnelid = [dic valueForKey:@"personnelid"];
            break;
        }
    }
    
    NSMutableArray * tmparray = [NSMutableArray arrayWithArray:subarray];
    NSMutableArray * array = [[NSMutableArray alloc] init];
    if (personnelid.length > 0) {
        NSMutableDictionary * dic_0 = tmparray[0];
        for (int i = 1; i<tmparray.count; i++) {
            NSMutableDictionary * dic_i = tmparray[i];
            if ([[dic_i valueForKey:@"edittime"] compare:[dic_0 valueForKey:@"edittime"]] == NSOrderedDescending) {
                dic_0 = dic_i;
            }
        }
        [dic_0 setValue:personnelid forKey:@"personnelid"];
        [array addObject:dic_0];
    } else {
        while (tmparray.count > 0) {
            NSMutableDictionary * dic_0 = tmparray[0];
            for (int i = 1; i < tmparray.count; i++) {
                NSMutableDictionary * dic_i = tmparray[i];
                if ([[dic_i valueForKey:@"lid"] isEqualToString:[dic_0 valueForKey:@"lid"]] && [[dic_i valueForKey:@"edittime"] compare:[dic_0 valueForKey:@"edittime"]] == NSOrderedSame) {
                    [tmparray removeObjectAtIndex:i];
                    i--;
                    continue;
                }
            }
            [array addObject:dic_0];
            [tmparray removeObjectAtIndex:0];
        }
    }
    return array;
}

#pragma mark - 处理重复数组元素状态
+(NSArray *)handleRepeatArray:(NSArray *)array
{
    NSInteger k = 0;
    //判断array里 状态是“非忽略”的元素个数 是否 >=2，如果是，则所有状态是“非忽略”的元素状态改为“重复”,否则为“不重复”
    for (NSMutableDictionary * dic in array) {
        if ([[dic allKeys] containsObject:@"repeatlogo"] && [[dic valueForKey:@"repeatlogo"] integerValue] == 1) {
            continue;
        } else {
            k++;
        }
        if (k >= 2) {
            break;
        }
    }
    if (k >= 2) {
        for (NSMutableDictionary * dic in array) {
            if (!([[dic allKeys] containsObject:@"repeatlogo"] && [[dic valueForKey:@"repeatlogo"] integerValue] == 1)) {
                [dic setValue:@(2) forKey:@"repeatlogo"];
            }
        }
    } else if (k == 1) {
        for (NSMutableDictionary * dic in array) {
            if (!([[dic allKeys] containsObject:@"repeatlogo"] && [[dic valueForKey:@"repeatlogo"] integerValue] == 1)) {
                [dic setValue:@(0) forKey:@"repeatlogo"];
                break;
            }
        }
    }
    return array;
}

/**
 处理非重复数据数组

 @param array 需要处理的不重复数组
 @return 返回处理完之后的数组
 */
+(NSArray *)handleNonrepeatArray:(NSArray *)array {
    
    for (NSMutableDictionary *dic in array) {
        if (![[dic allKeys] containsObject:@"repeatlogo"]) {
            [dic setValue:@0 forKey:@"repeatlogo"];
        }
        if ([[dic allKeys] containsObject:@"repeatlogo"] && [[dic valueForKey:@"repeatlogo"] integerValue] == 2) {
            [dic setValue:@0 forKey:@"repeatlogo"];
        }
    }
    return array;
}


#pragma mark - 人员信息字典转model
+(PersonnelModel *)personnelModelByDic:(NSDictionary *)dic
{
    /* 暂时注释掉，便于测试
    NSManagedObjectContext * context = [NSManagedObjectContext MR_context];
    CompanyModel * company = [CompanyModel MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"companyid = %@", [dic valueForKey:@"companyid"]]];
    */
    
    CompanyModel * company = [CompanyModel MR_findFirst];//测试用
    
    
    PersonnelModel * personnelmodel = [PersonnelModel MR_createEntity];
    personnelmodel.company = company;
    [personnelmodel MR_importValuesForKeysWithObject:dic];
    
    
    //成衣品类
    NSArray * finishcateArray = [[dic valueForKey:@"finishcate"] valueForKey:@"cate"];
    for (NSDictionary * catedic in finishcateArray) {
        CategoryModel * catemodel = [CategoryModel MR_createEntity];
        catemodel.personnel = personnelmodel;
        [catemodel MR_importValuesForKeysWithObject:catedic];
        //成衣量体部位
        NSArray * positionArray = [catedic valueForKey:@"positions"];
        for (NSDictionary * positiondic in positionArray) {
            PositionModel * positionmodel = [PositionModel MR_createEntity];
            [positionmodel MR_importValuesForKeysWithObject:positiondic];
            positionmodel.category = catemodel;
        }
    }
    
    //净体品类
    NSArray * netcateArray = [[dic valueForKey:@"netcate"] valueForKey:@"cate"];
    for (NSDictionary * catedic in netcateArray) {
        CategoryModel * catemodel = [CategoryModel MR_createEntity];
        catemodel.personnel = personnelmodel;
        [catemodel MR_importValuesForKeysWithObject:catedic];
        //净体附加信息
        NSArray * additionArray = [catedic valueForKey:@"addition"];
        for (NSDictionary * additiondic in additionArray) {
            AdditionModel * additionmodel = [AdditionModel MR_createEntity];
            [additionmodel MR_importValuesForKeysWithObject:additiondic];
            additionmodel.category = catemodel;
        }
    }
    //净体部位
    NSArray * positionArray = [[dic valueForKey:@"netcate"] valueForKey:@"positions"];
    for (NSDictionary * positiondic in positionArray) {
        PositionModel * positionmodel = [PositionModel MR_createEntity];
        [positionmodel MR_importValuesForKeysWithObject:positiondic];
        positionmodel.personnel = personnelmodel;
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return personnelmodel;
}

#pragma mark - 人员信息model转字典
+(NSDictionary *)personnelDicByModel:(PersonnelModel *)pmodel
{
    NSMutableDictionary * personnelDic = [[NSMutableDictionary alloc] init];
    personnelDic = [self dicByModel:pmodel];
    //净体品类数据
    NSMutableDictionary * netcateDic = [[NSMutableDictionary alloc] init];
    NSMutableArray * netcateSourceArray = [[NSMutableArray alloc] init];
    for (CategoryModel * cmodel in [CategoryModel MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"type = 0 AND personnelid = %@",pmodel.personnelid]]) {
        NSMutableDictionary * cateDic = [[NSMutableDictionary alloc] init];
        cateDic = [self dicByModel:cmodel];
        NSMutableArray * additionArray = [[NSMutableArray alloc] init];
        //每个净体品类对应的附加信息
        for (AdditionModel * addmodel in [cmodel.addition allObjects]) {
            NSMutableDictionary * addDic = [[NSMutableDictionary alloc] init];
            addDic = [self dicByModel:addmodel];
            [additionArray addObject:addDic];
        }
        [cateDic setValue:additionArray forKey:@"addition"];
        [netcateSourceArray addObject:cateDic];
    }
    
    [netcateDic setValue:netcateSourceArray forKey:@"cates"];
    
    NSMutableArray * positionArray = [[NSMutableArray alloc] init];
    for (PositionModel * positionmodel in [pmodel.position allObjects]) {
        NSMutableDictionary * positionDic = [[NSMutableDictionary alloc] init];
        positionDic = [self dicByModel:positionmodel];
        [positionArray addObject:positionDic];
    }
    [netcateDic setValue:positionArray forKey:@"positions"];
    [personnelDic setValue:netcateDic forKey:@"netcate"];
    
    NSMutableDictionary * finishcateDic = [[NSMutableDictionary alloc] init];
    NSMutableArray * finishcateSourceArray = [[NSMutableArray alloc] init];
    for (CategoryModel * cmodel in [CategoryModel MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"type = 1 AND personnelid = %@",pmodel.personnelid]]) {
        NSMutableDictionary * cateDic = [[NSMutableDictionary alloc] init];
        cateDic = [self dicByModel:cmodel];
        NSMutableArray * positionArray = [[NSMutableArray alloc] init];
        for (PositionModel * positionmodel in [cmodel.position allObjects]) {
            NSMutableDictionary * positionDic = [[NSMutableDictionary alloc] init];
            positionDic = [self dicByModel:positionmodel];
            [positionArray addObject:positionDic];
        }
        [cateDic setValue:positionArray forKey:@"positions"];
        [finishcateSourceArray addObject:cateDic];
    }
    [finishcateDic setValue:finishcateSourceArray forKey:@"cates"];
    [personnelDic setValue:finishcateDic forKey:@"finishcate"];
    return personnelDic;
}

//将 coredata model 转字典
+(NSMutableDictionary *)dicByModel:(NSManagedObject *)object
{
    NSArray * allkeys = [[[object entity] attributesByName] allKeys];
//    NSMutableDictionary * dic = [[NSMutableDictionary alloc] initWithDictionary:[object dictionaryWithValuesForKeys:allkeys]];
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    for (NSString * key in allkeys) {
        [dic setValue:[object valueForKey:key] forKey:key];
    }
    return dic;
}

@end
