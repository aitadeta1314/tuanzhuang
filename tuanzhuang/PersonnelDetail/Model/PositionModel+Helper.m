//
//  PositionModel+Helper.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/2/6.
//  Copyright © 2018年 red. All rights reserved.
//

#import "PositionModel+Helper.h"
#import "PersonnelModel+Helper.h"

@implementation PositionModel (Helper)

-(void)didChangeValueForKey:(NSString *)key{
    [super didChangeValueForKey:key];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[[self entity] name] forKey:KEY_ENTITY_USERINFO_NOTIFICATION];
    
    if (self.category && self.category.personnel) {
        
        [userInfo setObject:self.category.personnel forKey:KEY_PERSON_USERINFO_NOTIFICATION];
    }else if (self.personnel){
        
        [userInfo setObject:self.personnel forKey:KEY_PERSON_USERINFO_NOTIFICATION];
    }
    
    //发送修改通知
    [[NSNotificationCenter defaultCenter] postNotificationName:KEY_NOTIFICATION_CENTER_PERSON_SIZE_OPERATION object:nil userInfo:userInfo];
}

@end
