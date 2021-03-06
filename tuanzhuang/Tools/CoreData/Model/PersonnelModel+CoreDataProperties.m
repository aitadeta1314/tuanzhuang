//
//  PersonnelModel+CoreDataProperties.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/3/20.
//  Copyright © 2018年 red. All rights reserved.
//
//

#import "PersonnelModel+CoreDataProperties.h"

@implementation PersonnelModel (CoreDataProperties)

+ (NSFetchRequest<PersonnelModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"PersonnelModel"];
}

@dynamic category_config;
@dynamic companyid;
@dynamic department;
@dynamic edittime;
@dynamic firstletter;
@dynamic gender;
@dynamic height;
@dynamic history;
@dynamic ignored;
@dynamic istemp;
@dynamic lid;
@dynamic lname;
@dynamic mtm;
@dynamic name;
@dynamic personnelid;
@dynamic remark;
@dynamic sign;
@dynamic specialoptions;
@dynamic status;
@dynamic weight;
@dynamic category;
@dynamic company;
@dynamic position;

@end
