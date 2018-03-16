//
//  NSManagedObject+Coping.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/22.
//  Copyright © 2018年 red. All rights reserved.
//

#import "NSManagedObject+Coping.h"
#import <objc/runtime.h>

@implementation NSManagedObject (Coping)

-(id)mutableCopy{
    return [[self class] copyFromObject:self];
}

-(void)copyRelationshipsFrom:(NSManagedObject *)fromObject{
    [[self class] copyRelationshipsFrom:fromObject toObject:self];
}

-(void)copyAttributesFrom:(NSManagedObject *)fromObject{
    [[self class] copyAttributesFrom:fromObject toObject:self];
}

-(void)copyRelationships:(NSString *)relationshipName From:(NSManagedObject *)fromObject{
    
    [[self class] copyRelationshipByName:relationshipName FromObject:fromObject toObject:self];
    
}

#pragma mark - Public Class Methods
+(NSManagedObject *)copyFromObject:(NSManagedObject *)object{
    NSString *entityName = [[object entity] name];
    
    NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    
    NSArray *allKeys = [[[object entity] attributesByName] allKeys];
    NSDictionary *attributes = [object dictionaryWithValuesForKeys:allKeys];
    
    [newObject setValuesForKeysWithDictionary:attributes];
    
    NSDictionary *relationships = [[object entity] relationshipsByName];
    
    for (NSString *key in [relationships allKeys]) {
        NSRelationshipDescription *desc = [relationships valueForKey:key];
        
        if (NO == desc.toMany  && YES == desc.inverseRelationship.toMany) {
            //关联的对象，是父级对象，不用复制
            continue;
        }
        
        if ([desc isToMany]) {
            NSMutableSet *subObjectSet = [NSMutableSet set];
            for (NSManagedObject *subObject in [object valueForKey:key]) {
                [subObjectSet addObject:[self copyFromObject:subObject]];
            }
            
            [newObject setValue:subObjectSet forKey:key];
            
        }else{
            NSManagedObject *subObject = [newObject valueForKey:key];
            
            if (subObject) {
                [newObject setValue:[self copyFromObject:subObject] forKey:key];
            }
        }
    }
    
    return newObject;
}

+(void)copyRelationshipsFrom:(NSManagedObject *)fromObject toObject:(NSManagedObject *)toObject;{
    
    //同类型的Model的子数据可以拷贝
    if(![[fromObject entity].name isEqualToString:[toObject entity].name]){
        return;
    }
    
    NSDictionary *relationships = [[fromObject entity] relationshipsByName];
    
    for (NSString *key in [relationships allKeys]) {
        NSRelationshipDescription *desc = [relationships valueForKey:key];
        
        if (NO == desc.isToMany && YES == desc.inverseRelationship.isToMany) {
            //父级对象
            continue;
        }
        
        if (desc.toMany) {
            NSMutableSet *newObjectSet = [NSMutableSet set];
            
            //删除粘贴目标上的关联对象
            for (NSManagedObject *subObject in [toObject valueForKey:key]) {
                [subObject MR_deleteEntity];
            }
            
            for (NSManagedObject *subObject in [fromObject valueForKey:key]) {
                
                NSManagedObject *newSubObject = [self copyFromObject:subObject];
                
                [newObjectSet addObject:newSubObject];
            }
            
            [toObject setValue:newObjectSet forKey:key];
        }else{
            
            NSManagedObject *subObject = [fromObject valueForKey:key];
            
            NSManagedObject *object_source = [toObject valueForKey:key];
            [object_source MR_deleteEntity];
            
            if (subObject) {
                [toObject setValue:subObject forKey:key];
            }
        }
    }
}

/**
 * 拷贝指定模型子关联对象
 **/
+(void)copyRelationshipByName:(NSString *)relationshipName FromObject:(NSManagedObject *)fromObject toObject:(NSManagedObject *)toObject{
    
    NSDictionary *relationshipDic = [[fromObject entity] relationshipsByName];
    
    for (NSString *key in [relationshipDic allKeys]) {
        if ([key isEqualToString:relationshipName]) {
            NSRelationshipDescription *description = [relationshipDic objectForKey:key];
            
            if (description.toMany) {
                
                NSMutableSet *set = [NSMutableSet set];
                for (NSManagedObject *subObject in [fromObject valueForKey:key]) {
                    [set addObject:[self copyFromObject:subObject]];
                }
                
                [toObject setValue:set forKey:key];
                
            }else{
                
                NSManagedObject *subObject = [fromObject valueForKey:key];
                if (subObject) {
                    [toObject setValue:subObject forKey:key];
                }
                
            }
            break;
        }
    }
}

/**
 * 拷贝模型对象的属性数据
 **/
+(void)copyAttributesFrom:(NSManagedObject *)fromObject toObject:(NSManagedObject *)toObject{
    
    NSEntityDescription *fromEntity = [fromObject entity];
    
    NSDictionary *attributes = [fromEntity attributesByName];
    
    for (NSString *key in [attributes allKeys]) {
        [toObject setValue:[fromObject valueForKey:key] forKey:key];
    }
}

@end
