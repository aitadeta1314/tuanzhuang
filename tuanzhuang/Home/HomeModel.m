//
//  HomeModel.m
//  tuanzhuang
//
//  Created by Fenly on 2017/12/5.
//  Copyright © 2017年 red. All rights reserved.
//

#import "HomeModel.h"

@implementation HomeModel

- (NSString *)numberOfPerson {
    return [NSString stringWithFormat:@"%ld",[PersonnelModel MR_findByAttribute:@"company" withValue:_companyModel].count];
}


- (NSString *)waitNum {
    
    if (!_waitNum) {
        
        NSPredicate *waitFilter = [NSPredicate predicateWithFormat:@"status == 0 AND company == %@",_companyModel];
        _waitNum = [NSString stringWithFormat:@"%ld",[PersonnelModel MR_findAllWithPredicate:waitFilter].count];
    }
    return _waitNum;
}

- (NSString *)beingNum {
    
    if (!_beingNum) {
        
        NSPredicate *beingFilter = [NSPredicate predicateWithFormat:@"status == 1 AND company == %@",_companyModel];
        _beingNum = [NSString stringWithFormat:@"%ld",[PersonnelModel MR_findAllWithPredicate:beingFilter].count];
    }
    return _beingNum;
}

- (NSString *)doneNum {
    
    if (!_doneNum) {
        
        NSPredicate *doneFilter = [NSPredicate predicateWithFormat:@"status  == 2 AND company == %@",_companyModel];
        _doneNum = [NSString stringWithFormat:@"%ld",[PersonnelModel MR_findAllWithPredicate:doneFilter].count];
    }
    return _doneNum;
}

@end
