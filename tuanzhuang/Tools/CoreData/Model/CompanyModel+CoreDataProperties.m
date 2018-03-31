//
//  CompanyModel+CoreDataProperties.m
//  tuanzhuang
//
//  Created by Fenly on 2018/3/27.
//  Copyright © 2018年 red. All rights reserved.
//
//

#import "CompanyModel+CoreDataProperties.h"

@implementation CompanyModel (CoreDataProperties)

+ (NSFetchRequest<CompanyModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CompanyModel"];
}

@dynamic addtime;
@dynamic companyid;
@dynamic companyname;
@dynamic configuration;
@dynamic del;
@dynamic lock_status;
@dynamic missionname;
@dynamic rev;
@dynamic tb_frequency;
@dynamic tb_lasttime;
@dynamic upload_frequency;
@dynamic upload_lasttime;
@dynamic delTime;
@dynamic personnel;

@end
