//
//  PositionModel+CoreDataProperties.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/19.
//  Copyright © 2018年 red. All rights reserved.
//
//

#import "PositionModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PositionModel (CoreDataProperties)

+ (NSFetchRequest<PositionModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *blcode;
@property (nullable, nonatomic, copy) NSString *personnelid;
@property (nullable, nonatomic, copy) NSString *positionname;
@property (nonatomic) int16_t size_winter;
@property (nonatomic) int16_t size;
@property (nonatomic) int16_t type;
@property (nullable, nonatomic, retain) CategoryModel *category;
@property (nullable, nonatomic, retain) PersonnelModel *personnel;

@end

NS_ASSUME_NONNULL_END
