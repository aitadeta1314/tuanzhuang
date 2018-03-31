//
//  AdditionModel+CoreDataProperties.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/3/17.
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
@dynamic blcode_clothes;
@dynamic blcode_pants;
@dynamic blcode_pleat;
@dynamic blcode_shoulder;
@dynamic blcode_skirt;
@dynamic blcode_sleeve;
@dynamic blcode_waist;
@dynamic category;

@end
