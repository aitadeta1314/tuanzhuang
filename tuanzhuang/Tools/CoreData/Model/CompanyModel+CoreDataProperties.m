//
//  CompanyModel+CoreDataProperties.m
//  tuanzhuang
//
//  Created by red on 2018/3/12.
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
@dynamic lock_status;
@dynamic tb_frequency;
@dynamic tb_lasttime;
@dynamic upload_frequency;
@dynamic upload_lasttime;
@dynamic rev;
@dynamic personnel;

@end
