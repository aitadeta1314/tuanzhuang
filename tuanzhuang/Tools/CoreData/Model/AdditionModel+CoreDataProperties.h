//
//  AdditionModel+CoreDataProperties.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/3/17.
//  Copyright © 2018年 red. All rights reserved.
//
//

#import "AdditionModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AdditionModel (CoreDataProperties)

+ (NSFetchRequest<AdditionModel *> *)fetchRequest;

@property (nonatomic) int16_t increase;
@property (nonatomic) int16_t season;
@property (nonatomic) int16_t value_clothes;
@property (nonatomic) int16_t value_pants;
@property (nonatomic) int16_t value_pleat;
@property (nonatomic) int16_t value_shoulder;
@property (nonatomic) int16_t value_skirt;
@property (nonatomic) int16_t value_sleeve;
@property (nonatomic) int16_t value_waist;
@property (nullable, nonatomic, copy) NSString *blcode_clothes;
@property (nullable, nonatomic, copy) NSString *blcode_pants;
@property (nullable, nonatomic, copy) NSString *blcode_pleat;
@property (nullable, nonatomic, copy) NSString *blcode_shoulder;
@property (nullable, nonatomic, copy) NSString *blcode_skirt;
@property (nullable, nonatomic, copy) NSString *blcode_sleeve;
@property (nullable, nonatomic, copy) NSString *blcode_waist;
@property (nullable, nonatomic, retain) CategoryModel *category;

@end

NS_ASSUME_NONNULL_END
