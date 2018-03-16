//
//  CategoryModel+CoreDataProperties.h
//  tuanzhuang
//
//  Copyright © 2018年 red. All rights reserved.
//
//

#import "CategoryModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CategoryModel (CoreDataProperties)

+ (NSFetchRequest<CategoryModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *cate;
@property (nonatomic) int16_t count;
@property (nullable, nonatomic, copy) NSString *personnelid;
@property (nonatomic) int16_t type;
@property (nullable, nonatomic, retain) NSSet<AdditionModel *> *addition;
@property (nullable, nonatomic, retain) PersonnelModel *personnel;
@property (nullable, nonatomic, retain) NSSet<PositionModel *> *position;

@end

@interface CategoryModel (CoreDataGeneratedAccessors)

- (void)addAdditionObject:(AdditionModel *)value;
- (void)removeAdditionObject:(AdditionModel *)value;
- (void)addAddition:(NSSet<AdditionModel *> *)values;
- (void)removeAddition:(NSSet<AdditionModel *> *)values;

- (void)addPositionObject:(PositionModel *)value;
- (void)removePositionObject:(PositionModel *)value;
- (void)addPosition:(NSSet<PositionModel *> *)values;
- (void)removePosition:(NSSet<PositionModel *> *)values;

@end

NS_ASSUME_NONNULL_END
