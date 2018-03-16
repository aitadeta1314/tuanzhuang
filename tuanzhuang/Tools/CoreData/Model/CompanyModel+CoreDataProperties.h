//
//  CompanyModel+CoreDataProperties.h
//  tuanzhuang
//
//  Created by red on 2018/3/12.
//  Copyright © 2018年 red. All rights reserved.
//
//

#import "CompanyModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CompanyModel (CoreDataProperties)

+ (NSFetchRequest<CompanyModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *addtime;
@property (nullable, nonatomic, copy) NSString *companyid;
@property (nullable, nonatomic, copy) NSString *companyname;
@property (nullable, nonatomic, copy) NSString *configuration;
@property (nonatomic) BOOL lock_status;
@property (nonatomic) int16_t tb_frequency;
@property (nullable, nonatomic, copy) NSDate *tb_lasttime;
@property (nonatomic) int16_t upload_frequency;
@property (nullable, nonatomic, copy) NSDate *upload_lasttime;
@property (nonatomic) int16_t rev;
@property (nullable, nonatomic, retain) NSSet<PersonnelModel *> *personnel;

@end

@interface CompanyModel (CoreDataGeneratedAccessors)

- (void)addPersonnelObject:(PersonnelModel *)value;
- (void)removePersonnelObject:(PersonnelModel *)value;
- (void)addPersonnel:(NSSet<PersonnelModel *> *)values;
- (void)removePersonnel:(NSSet<PersonnelModel *> *)values;

@end

NS_ASSUME_NONNULL_END
