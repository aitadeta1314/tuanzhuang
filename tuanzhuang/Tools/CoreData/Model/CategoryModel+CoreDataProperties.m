//
//  CategoryModel+CoreDataProperties.m
//  tuanzhuang
//

//  Copyright © 2018年 red. All rights reserved.
//
//

#import "CategoryModel+CoreDataProperties.h"

@implementation CategoryModel (CoreDataProperties)

+ (NSFetchRequest<CategoryModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CategoryModel"];
}

@dynamic cate;
@dynamic count;
@dynamic personnelid;
@dynamic type;
@dynamic addition;
@dynamic personnel;
@dynamic position;

@end
