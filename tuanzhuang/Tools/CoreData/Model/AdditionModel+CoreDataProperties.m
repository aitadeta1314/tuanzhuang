//
//  AdditionModel+CoreDataProperties.m
//  tuanzhuang
//
//  Created by red on 2018/3/8.
//  Copyright © 2018年 red. All rights reserved.
//
//

#import "AdditionModel+CoreDataProperties.h"

@implementation AdditionModel (CoreDataProperties)

+ (NSFetchRequest<AdditionModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"AdditionModel"];
}

@dynamic increase;
@dynamic season;
@dynamic value_clothes;
@dynamic value_pants;
@dynamic value_pleat;
@dynamic value_shoulder;
@dynamic value_skirt;
@dynamic value_sleeve;
@dynamic value_waist;
@dynamic category;

@end
