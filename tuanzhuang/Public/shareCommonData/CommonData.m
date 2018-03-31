//
//  CommonData.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/22.
//  Copyright © 2018年 red. All rights reserved.
//

#import "CommonData.h"

static NSString * const KEY_COPY_OTHER_PERSON = @"key_copy_other_person";
static NSString * const KEY_COPY_LIST_PERSON  = @"key_copy_list_person";
static NSString * const KEY_HISTORY_LIST_PERSON = @"key_history_list_person";

@implementation CommonData

+(instancetype)shareCommonData{
    
    static CommonData *commonData;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!commonData) {
            commonData = [[CommonData alloc] init];
        }
    });
    
    return commonData;
}

#pragma mark - 拷贝他人列表操作
-(void)addPersonToCopiedOther:(PersonnelModel *)person{
    
    NSString *companyID = person.company.companyid;
    NSString *path = [person.objectID.URIRepresentation path];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:KEY_COPY_OTHER_PERSON]];
    
    NSMutableArray *dataArray = [NSMutableArray arrayWithArray:[dataDic objectForKey:companyID]];
    
    if (![dataArray containsObject:path]) {
        [dataArray addObject:path];
    }
    
    [dataDic setObject:dataArray forKey:companyID];
    
    [userDefaults setObject:dataDic forKey:KEY_COPY_OTHER_PERSON];
}

-(BOOL)copiedOtherContainPerson:(PersonnelModel *)person{
    
    BOOL exist = NO;
    
    NSString *companyID = person.company.companyid;
    NSString *path = [person.objectID.URIRepresentation path];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *dataDic = [NSDictionary dictionaryWithDictionary:[userDefaults objectForKey:KEY_COPY_OTHER_PERSON]];
    
    NSArray *dataArray = [NSArray arrayWithArray:[dataDic objectForKey:companyID]];
    
    if ([dataArray containsObject:path]) {
        exist = YES;
    }
    
    return exist;
}

-(void)removeCopiedOtherByCompanyId:(NSString *)companyId{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:KEY_COPY_OTHER_PERSON]];
    
    [dataDic removeObjectForKey:companyId];
    
    [userDefaults setObject:dataDic forKey:KEY_COPY_OTHER_PERSON];
}


/**
 * 清除公司公共数据
 **/
-(void)clearDataByCompanyId:(NSString *)companyId{
    
    [self removeCopiedOtherByCompanyId:companyId];
    
}

/**
 * 清除指定公司无用的缓存数据
 **/
-(void)clearTempPersonDataByCompany:(CompanyModel *)company{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyid == %@ && (name == NULL || name == '')",company.companyid];
    
    NSSet *personSet = [company.personnel filteredSetUsingPredicate:predicate];
    
    for (PersonnelModel *personModel in personSet) {
        [personModel MR_deleteEntity];
    }
    
}


@end
