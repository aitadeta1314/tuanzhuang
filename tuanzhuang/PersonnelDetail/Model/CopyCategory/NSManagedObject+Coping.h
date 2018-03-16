//
//  NSManagedObject+Coping.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/22.
//  Copyright © 2018年 red. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Coping)

-(void)copyRelationshipsFrom:(NSManagedObject *)fromObject;

-(void)copyAttributesFrom:(NSManagedObject *)fromObject;

-(void)copyRelationships:(NSString *)relationshipName From:(NSManagedObject *)fromObject;


#pragma mark - Class Methods

/**
 * 拷贝整个模型对象
 */
+(NSManagedObject *)copyFromObject:(NSManagedObject *)object;

/**
 * 拷贝模型子关联对象
 **/
+(void)copyRelationshipsFrom:(NSManagedObject *)fromObject toObject:(NSManagedObject *)toObject;

/**
 * 拷贝指定模型子关联对象
 **/
+(void)copyRelationshipByName:(NSString *)relationshipName FromObject:(NSManagedObject *)fromObject toObject:(NSManagedObject *)toObject;

/**
 * 拷贝模型对象的属性数据
 **/
+(void)copyAttributesFrom:(NSManagedObject *)fromObject toObject:(NSManagedObject *)toObject;



@end
