//
//  PersonnelModel+CoreDataProperties.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/3/20.
//  Copyright © 2018年 red. All rights reserved.
//
//

#import "PersonnelModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PersonnelModel (CoreDataProperties)

+ (NSFetchRequest<PersonnelModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *category_config;
@property (nullable, nonatomic, copy) NSString *companyid;
@property (nullable, nonatomic, copy) NSString *department;
@property (nullable, nonatomic, copy) NSString *edittime;
@property (nullable, nonatomic, copy) NSString *firstletter;
@property (nonatomic) int16_t gender;
@property (nonatomic) float height;
@property (nonatomic) BOOL history;
@property (nonatomic) BOOL ignored;
@property (nonatomic) BOOL istemp;
@property (nullable, nonatomic, copy) NSString *lid;
@property (nullable, nonatomic, copy) NSString *lname;
@property (nonatomic) BOOL mtm;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *personnelid;
@property (nullable, nonatomic, retain) NSData *remark;
@property (nullable, nonatomic, retain) NSData *sign;
@property (nullable, nonatomic, copy) NSString *specialoptions;
@property (nonatomic) int16_t status;
@property (nonatomic) float weight;
@property (nullable, nonatomic, retain) NSSet<CategoryModel *> *category;
@property (nullable, nonatomic, retain) CompanyModel *company;
@property (nullable, nonatomic, retain) NSSet<PositionModel *> *position;

@end

@interface PersonnelModel (CoreDataGeneratedAccessors)

- (void)addCategoryObject:(CategoryModel *)value;
- (void)removeCategoryObject:(CategoryModel *)value;
- (void)addCategory:(NSSet<CategoryModel *> *)values;
- (void)removeCategory:(NSSet<CategoryModel *> *)values;

- (void)addPositionObject:(PositionModel *)value;
- (void)removePositionObject:(PositionModel *)value;
- (void)addPosition:(NSSet<PositionModel *> *)values;
- (void)removePosition:(NSSet<PositionModel *> *)values;

@end

NS_ASSUME_NONNULL_END
