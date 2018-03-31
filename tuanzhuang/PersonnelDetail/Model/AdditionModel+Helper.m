//
//  AdditionModel+Helper.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/23.
//  Copyright © 2018年 red. All rights reserved.
//

#import "AdditionModel+Helper.h"
#import "PersonnelModel+Helper.h"
#import "CategoryAddRangeModel.h"
#import "PositionSizeRangeModel.h"

static NSArray *_clothesLongArray;  //后衣长
static NSArray *_sleeveLongArray;   //袖长
static NSArray *_pleatOptionArray;  //皱褶
static NSArray *_shoulderArray;     //肩宽
static NSArray *_waistArray;        //腰围
static NSArray *_pantsArray;        //裤长
static NSArray *_skirtArray;        //裙长

static NSDictionary *_positionDic;  //属性对应的量体部位

static NSDictionary *_validatePositionDic;//验证量体部位

@implementation AdditionModel (Helper)

+(void)load{
    [super load];
    
    _clothesLongArray = @[Category_Code_A,Category_Code_CY,Category_Code_CD,Category_Code_W,Category_Code_C];
    
    _sleeveLongArray = @[Category_Code_CY,Category_Code_CD,Category_Code_A,Category_Code_W];
    
    _pleatOptionArray = @[Category_Code_B];
    
    _shoulderArray = @[Category_Code_A,Category_Code_CY,Category_Code_CD,Category_Code_C,Category_Code_W];
    
    _waistArray = @[Category_Code_B,Category_Code_D];
    
    _pantsArray = @[Category_Code_B];
    
    _skirtArray = @[Category_Code_D];
    
    _positionDic = @{
                     @"总肩宽":@"value_shoulder",
                     @"后衣长":@"value_clothes",
                     @"袖长":@"value_sleeve",
                     @"短袖长":@"value_sleeve",
                     @"裤腰围":@"value_waist",
                     @"裤长":@"value_pants",
                     @"裙长":@"value_skirt"
                     };
    
    _validatePositionDic = @{
                             Category_Code_CY:@[@"短袖长"],    //长袖衬衣：不同步更新“短袖长”
                             Category_Code_A:@[@"短袖长"],     //西服：不同步更新“短袖长”
                             Category_Code_W:@[@"短袖长"],     //大衣：不同步更新“短袖长”
                             Category_Code_CD:@[@"袖长"]      //短袖衬衣：不同步更新“袖长”
                             };
}

-(BOOL)hasClothesLong{
    return [_clothesLongArray containsObject:self.category.cate];
}

-(BOOL)hasSleeveLong{
    return [_sleeveLongArray containsObject:self.category.cate];
}

-(BOOL)hasPleatOption{
    return [_pleatOptionArray containsObject:self.category.cate];
}

-(BOOL)hasShoulderWidth{
    return [_shoulderArray containsObject:self.category.cate];
}

-(BOOL)hasWaist{
    return [_waistArray containsObject:self.category.cate];
}

-(BOOL)hasPantsLong{
    return [_pantsArray containsObject:self.category.cate];
}

-(BOOL)hasSkirtLong{
    return [_skirtArray containsObject:self.category.cate];
}

-(NSString *)description{
    NSMutableString *description = [NSMutableString string];
    
    if (SEASON_TYPE_SUMMER == self.season) {
        [description appendString:@"(夏) "];
    }else if (SEASON_TYPE_WINTER == self.season){
        [description appendString:@"(冬) "];
    }
    
    NSMutableArray * tempArray = [NSMutableArray array];
    if (self.increase > 0) {
        [tempArray addObject:[NSString stringWithFormat:@"加放量：%d",self.increase]];
    }
    
    if (self.hasSleeveLong && self.value_sleeve>0) {
        [tempArray addObject:[NSString stringWithFormat:@"袖长：%d",self.value_sleeve]];
    }
    
    if (self.hasClothesLong && self.value_clothes) {
        [tempArray addObject:[NSString stringWithFormat:@"后衣长：%d",self.value_clothes]];
    }
    
    if (self.hasShoulderWidth && self.value_shoulder) {
        [tempArray addObject:[NSString stringWithFormat:@"肩宽：%d",self.value_shoulder]];
    }
    
    if (self.hasWaist && self.value_waist) {
        [tempArray addObject:[NSString stringWithFormat:@"腰围：%d",self.value_waist]];
    }
    
    if(self.hasPantsLong && self.value_pants){
        [tempArray addObject:[NSString stringWithFormat:@"裤长：%d",self.value_pants]];
    }
    
    if (self.hasSkirtLong && self.value_skirt) {
        [tempArray addObject:[NSString stringWithFormat:@"裙长：%d",self.value_skirt]];
    }
    
    if (self.hasPleatOption) {
        NSString *pleateString;
        switch (self.value_pleat) {
            case CLOTHES_PLEAT_TYPE_SINGLE:
                pleateString = @"单褶";
                break;
            case CLOTHES_PLEAT_TYPE_DOUBLE:
                pleateString = @"双褶";
                break;
            default:
                pleateString = @"无褶";
                break;
        }
        [tempArray addObject:pleateString];
    }
    
    [description appendString:[tempArray componentsJoinedByString:@"/"]];
    
    return description;
}

#pragma mark - publict Methods

-(void)reset{
    
    PersonnelModel *person = self.category.personnel;
    NSString *categoryCode = self.category.cate;

    int pleat = CLOTHES_PLEAT_TYPE_NONE;    //女：默认“无褶”
    if ([categoryCode isEqualToString:Category_Code_B]) {
        if (PERSON_GENDER_MAN == person.gender) {
            pleat = CLOTHES_PLEAT_TYPE_SINGLE;  //男：默认“单褶”
        }
    }
    
    self.season = SEASON_TYPE_SUMMER;
    self.value_pleat = pleat;
    
    //重置量体部位尺寸
    if (person) {
        
        for (NSString *key in _positionDic.allKeys) {
            
            NSString *properyName = [_positionDic objectForKey:key];
            
            NSInteger size = [person getBodyPositionSizeByName:key];
            
            BOOL validate = [AdditionModel validateSyncPositioin:key inCategory:categoryCode];
            
            if (validate && size) {
                [self setValue:@(size) forKey:properyName];
            }
            
        }
    }
    
    CategoryAddRangeModel *rangeModel = [CategoryAddRangeModel rangeModelByCategory:categoryCode withPleatType:pleat];
    
    //赋值默认的加放量
    if (PERSON_GENDER_WOMEN == person.gender) {
        self.increase = rangeModel.womenValue;
    }else{
        self.increase = rangeModel.manValue;
    }
}

/**
 * 褶皱变更重置默认加放量
 */
-(void)resetIncreaseByPleatOption{
    
    PersonnelModel *person = self.category.personnel;
    NSString *categoryCode = self.category.cate;
    
    CategoryAddRangeModel *rangeModel = [CategoryAddRangeModel rangeModelByCategory:categoryCode withPleatType:self.value_pleat];
    
    //赋值默认的加放量
    if (PERSON_GENDER_WOMEN == person.gender) {
        self.increase = rangeModel.womenValue;
    }else{
        self.increase = rangeModel.manValue;
    }
    
}

/**
 * 判断是否可修改该属性
 **/
-(BOOL)shouldChangedValueBykey:(NSString *)key{
    
    BOOL changed = YES;
    
    if ([key isEqualToString:@"value_clothes"] && ![self hasClothesLong]) {
        changed = NO;
    }else if ([key isEqualToString:@"value_pants"] && ![self hasPantsLong]){
        changed = NO;
    }else if ([key isEqualToString:@"value_pleat"] && ![self hasPleatOption]){
        changed = NO;
    }else if ([key isEqualToString:@"value_shoulder"] && ![self hasShoulderWidth]){
        changed = NO;
    }else if ([key isEqualToString:@"value_skirt"] && ![self hasSkirtLong]){
        changed = NO;
    }else if ([key isEqualToString:@"value_sleeve"] && ![self hasSleeveLong]){
        changed = NO;
    }else if ([key isEqualToString:@"value_waist"] && ![self hasWaist]){
        changed = NO;
    }
    
    //男性 针对 “西裙”品类：无修改
    if (PERSON_GENDER_MAN == self.category.personnel.gender && [self.category.cate isEqualToString:Category_Code_D]) {
        changed = NO;
    }
    
    return changed;
    
}

-(void)setValue:(id)value forKey:(NSString *)key{
    
    if ([self shouldChangedValueBykey:key] && [self validatePositionSizeRangeValue:value forKey:key]) {
        
        [super setValue:value forKey:key];
        
    }
    
}

/**
 * 验证部位是否在范围内
 **/
-(BOOL)validatePositionSizeRangeValue:(id)value forKey:(NSString *)key{
    
    BOOL isPass = YES;
    
    for (NSString *positionName in _positionDic.allKeys) {
        NSString *keyName = [_positionDic objectForKey:positionName];
        NSString *categoryCode = self.category.cate;
        BOOL isMan = NO;
        BOOL isMTM = NO;
        
        if (self.category && self.category.personnel) {
            isMan = self.category.personnel.gender;
            isMTM = self.category.personnel.mtm;
        }
        
        if ([keyName isEqualToString:key] && [[self class] validateSyncPositioin:positionName inCategory:categoryCode]) {
            
            //获取指定部位的尺寸范围
            PositionSizeRangeModel *rangeModel = [PositionSizeRangeModel getBodyPositionSizeRangeByName:positionName andSex:isMan andMTM:isMTM];
            
            if (rangeModel) {
                NSInteger min = 0;
                NSInteger max = 0;
                
                [rangeModel getRangeMin:&min andRangeMax:&max byIsMan:isMan];
                
                NSInteger size = [value integerValue];
                
                if (size != 0 && (size < min || size > max)) {
                    isPass = NO;
                }
                
                break;
            }
        }
    }
    
    return isPass;
    
}

#pragma mark - Value changed Methods
-(void)didChangeValueForKey:(NSString *)key{
    
    [super didChangeValueForKey:key];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    [userInfo setObject:[[self entity] name] forKey:KEY_ENTITY_USERINFO_NOTIFICATION];
    
    if (self.category && self.category.personnel) {
        [userInfo setObject:self.category.personnel forKey:KEY_PERSON_USERINFO_NOTIFICATION];
    }
    
    //发送修改通知
    [[NSNotificationCenter defaultCenter] postNotificationName:KEY_NOTIFICATION_CENTER_PERSON_SIZE_OPERATION object:nil userInfo:userInfo];
    
}

#pragma mark - Class Methods
/**
 * 获取量体部位关联字典
 **/
+(NSDictionary *)positionAssociateDic{
    return _positionDic;
}

/**
 * 验证量体部位在指定品类下，是否可同步更新对应的属性
 **/
+(BOOL)validateSyncPositioin:(NSString *)positionName inCategory:(NSString *)categoryCode{
    
    BOOL validate = YES;
    
    if ([_validatePositionDic.allKeys containsObject:categoryCode]) {
        
        NSArray *positionNameArray = [_validatePositionDic objectForKey:categoryCode];
        
        if ([positionNameArray containsObject:positionName]) {
            //该量体部位：不能同步到加放量附加信息中
            validate = NO;
        }
        
    }
    
    return validate;
    
}

@end
