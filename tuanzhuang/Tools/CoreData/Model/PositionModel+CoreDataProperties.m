//
//  PositionModel+CoreDataProperties.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/19.
//  Copyright © 2018年 red. All rights reserved.
//
//

#import "PositionModel+CoreDataProperties.h"

@implementation PositionModel (CoreDataProperties)

+ (NSFetchRequest<PositionModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"PositionModel"];
}

@dynamic blcode;
@dynamic personnelid;
@dynamic positionname;
@dynamic size_winter;
@dynamic size;
@dynamic type;
@dynamic category;
@dynamic personnel;

@end
