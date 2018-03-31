//
//  PersonnelModel+Helper.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/16.
//  Copyright © 2018年 red. All rights reserved.
//

#import "PersonnelModel+Helper.h"
#import "CategoryAddRangeModel.h"
#import "NSManagedObject+Coping.h"
#import "PositionSizeRangeModel.h"
#import "CategoryModel+Helper.h"
#import "processingTime.h"

NSString * const ERROR_DESCRIPTION_KEY      = @"description";
NSString * const ERROR_POSITION_BLCODE_KEY  = @"position_blcode";
NSString * const ERROR_POSITION_NAME_KEY    = @"position_name";
NSString * const ERROR_CATEGORY_NAME_KEY    = @"category_name";
NSString * const ERROR_CATEGORY_CODE_KEY    = @"category_code";

NSString * const KEY_PERSON_USERINFO_NOTIFICATION   = @"key_person_userinfo";

NSString * const KEY_ENTITY_USERINFO_NOTIFICATION = @"key_entity_userinfo";

@implementation PersonnelModel (Helper)

/**
 * 存在短袖长
 **/
-(BOOL)hasShortSleeveSize{
    
    BOOL isExist = NO;
    
    NSString *positionName = @"短袖长";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"positionname CONTAINS[cd] %@",positionName];
    
    NSSet *positions = [self.position filteredSetUsingPredicate:predicate];
    
    if ([positions count] > 0) {
        isExist = YES;
    }else{
        
        NSArray *categorys = [self getCategoryArrayByCode:Category_Code_CD];
        
        for (CategoryModel *categoryModel in categorys) {
            
            NSSet *positions = [categoryModel.position filteredSetUsingPredicate:predicate];
            
            if ([positions count] > 0 && categoryModel.count > 0) {
                isExist = YES;
                break;
            }
            
        }
        
    }
    
    return isExist;
}

/**
 * 设置包含短袖长标志
 */
-(void)setHasShortSleeveFlag{
    
    UIColor *textColor = [UIColor clearColor];
    
    BOOL shouldEdit = NO;
    
    if ([self hasShortSleeveSize]) {
        //创建标记图片
        textColor = [UIColor blackColor];
        shouldEdit = YES;
    }else if (self.remark){
        //清除已有的图片的标记
        textColor = [UIColor whiteColor]; //抹掉标注文字
        shouldEdit = YES;
    }
    
    if (shouldEdit) {
        UIImage *remarkImage;
        CGSize size = [UIScreen mainScreen].bounds.size;
        CGFloat scale = [UIScreen mainScreen].scale;
        if (self.remark) {
            remarkImage = [UIImage imageWithData:self.remark];
        }
        
        UIGraphicsBeginImageContextWithOptions(size, NO, scale);
        
        [remarkImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        
        NSDictionary *attrDic = @{NSFontAttributeName:[UIFont systemFontOfSize:28],NSForegroundColorAttributeName:textColor};
        NSAttributedString *flagAttrStr = [[NSAttributedString alloc] initWithString:@"标注短袖长" attributes:attrDic];
        
        [flagAttrStr drawAtPoint:CGPointZero];
        
        remarkImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        self.remark = UIImagePNGRepresentation(remarkImage);
    }
}


/**
 * 设置量体中状态
 **/
-(void)setPersonSatus_Progressing{
    
    if (self.status != PERSON_STATUS_COMPLETED) {
        self.status = PERSON_STATUS_PROGRESSING;
    }
    
}

/*
 * 从“已完成”状态恢复到“进行中”状态
 **/
-(void)resumePersonSatus_Progressing{
    
    if (self.status == PERSON_STATUS_COMPLETED) {
        self.status = PERSON_STATUS_PROGRESSING;
    }
    
}

/**
 * 设置修改时间为当前时间
 */
-(void)setEditTimeIsNow{
    NSDate *date = [NSDate date];

    self.edittime = [processingTime dateStringWithDate:date andFormatString:@"yyyy-MM-dd HH:mm:ss"];
}


/**
 * 拷贝其他用户的量体与品类数据
 **/
-(void)copyPersonSizeDataFrom:(PersonnelModel *)otherPerson{
    
    if (otherPerson && self != otherPerson) {
        [self copyRelationshipsFrom:otherPerson];
        self.company = otherPerson.company;
        self.specialoptions = otherPerson.specialoptions;
        self.category_config = otherPerson.category_config;
        self.mtm = otherPerson.mtm;
        
        //根据性别，对数据进行修改
        if (self.gender != otherPerson.gender) {
            [self referenceAssociateDataBySexChanged];
        }
    }
}

/**
 * 检测是否为重复用户数据
 ***/
-(BOOL)validateRepeatPerson:(NSError **)error{
    
    //如果是临时数据，不用进行重复数据检测
    if (self.istemp) {
        return YES;
    }
    
    BOOL pass = YES;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",self.name];
    
    NSMutableArray *personArray = [NSMutableArray arrayWithArray:[[self.company.personnel filteredSetUsingPredicate:predicate] sortedArrayUsingDescriptors:@[]]];

    //删除自身
    [personArray removeObject:self];
    
    //判断是否重复
    for (PersonnelModel *otherPerson in personArray) {
        
        //直接跳过临时数据
        if (otherPerson.istemp) {
            continue;
        }
        
        if (self.gender == otherPerson.gender &&
            [self.department isEqualToString:otherPerson.department] &&
            self.mtm == otherPerson.mtm) {
            //存在重复数据：姓名、性别、MTM、部门一致
            pass = NO;
            
            NSString *descriptioin = @"对不起，不能创建重复的量体人员";
            *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:0 userInfo:@{ERROR_DESCRIPTION_KEY:descriptioin}];
            
            break;
        }
        
    }
    
    return pass;
}

/**
 * 验证基本的数据
 */
-(BOOL)validatePerson:(NSError **)error{
    
    BOOL pass = YES;
    
    NSString *descriptioin;
    
    if (!self.name.isValidString) {
        pass = NO;
        descriptioin = @"请输入姓名";
    }else if (!self.department.isValidString){
        pass = NO;
        descriptioin = @"请输入部门";
    }else if (0 == self.height || 0 == self.weight){
        pass = NO;
        descriptioin = @"请输入身高和体重";
    }
    
    if (descriptioin.isValidString) {
        *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:0 userInfo:@{ERROR_DESCRIPTION_KEY:descriptioin}];
    }
    
    return pass;
    
}

/**
 * 验证量体人员是否进行品类的配置
 **/
-(BOOL)validatePersonCategoryConfig:(NSError **)error{
    
    BOOL pass = NO;
    
    NSDictionary *categoryDic = [PersonnelModel convertDicByCategoryConfigStr:self.category_config];
    
    for (NSString *key in categoryDic.allKeys) {
        NSInteger count = [[categoryDic objectForKey:key] integerValue];
        
        if (count > 0) {
            pass = YES;
            break;
        }
    }
    
    if (!pass) {
        *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:0 userInfo:@{ERROR_DESCRIPTION_KEY:@"请进行品类配置"}];
    }
    
    return pass;
}

-(BOOL)validateBodySizeData:(NSError *__autoreleasing *)error{
    
    BOOL isPass = YES;
    
    NSArray *bodyPositionArray = [PositionSizeRangeModel getBodyPositionSizeRangeArrayBySex:self.gender andMTM:self.mtm];
    
    NSArray *bodyCategorys = [self getCategorySizeType:CategorySizeType_Body];
    
    if (PERSON_GENDER_MAN == self.gender) {
        //忽略西裙的验证
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:bodyCategorys];
        
        for (CategoryModel *item in tempArray) {
            if ([item.cate isEqualToString:Category_Code_D]) {
                [tempArray removeObject:item];
                break;
            }
        }
        
        bodyCategorys = tempArray;
    }
    
    
    for (PositionSizeRangeModel *rangeModel in bodyPositionArray) {
        //验证必填部位尺寸不为空
        isPass = [self validateBodySizeData_Required:rangeModel forCategorys:bodyCategorys error:error];
        
        if (isPass) {
            //验证部位尺寸是否在规定范围内
            isPass = [self validateBodySizeData_Range:rangeModel error:error];
        }
        
        if (!isPass) {
            break;
        }
    }
    
    return isPass;
}

/**
 * 验证净体的部位尺寸的必填
 **/
-(BOOL)validateBodySizeData_Required:(PositionSizeRangeModel *)rangeModel forCategorys:(NSArray *)categorys error:(NSError **)error{
    
    BOOL isPass = YES;
    
    BOOL isRequired = [rangeModel isRequiredForBodySizeCategorys:categorys];
    
    NSString *positionName = rangeModel.position;
    NSString *blcode = rangeModel.blcode;
    
    if (PERSON_GENDER_WOMEN == self.gender) {
        blcode = rangeModel.wblcode;
    }
    
    if (isRequired) {
        NSInteger size = [self getBodyPositionSizeByCode:blcode];
        
        if (0 == size) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{ERROR_DESCRIPTION_KEY:[NSString stringWithFormat:@"请在净体中输入\"%@\"的尺寸",positionName],ERROR_POSITION_BLCODE_KEY:blcode,ERROR_POSITION_NAME_KEY:positionName}];
            
            isPass = NO;
        }
    }
    
    return isPass;
}

/**
 * 验证净体尺寸是否在范围内
 **/
-(BOOL)validateBodySizeData_Range:(PositionSizeRangeModel *)rangeModel error:(NSError **)error{
    
    BOOL isPass = YES;
    
    NSString *positionName = rangeModel.position;
    NSString *blcode = rangeModel.blcode;
    NSInteger max = 0;
    NSInteger min = 0;
    
    //获取尺寸范围
    [rangeModel getRangeMin:&min andRangeMax:&max byIsMan:self.gender];
    
    if (PERSON_GENDER_WOMEN == self.gender) {
        blcode = rangeModel.wblcode;
    }
    
    NSInteger size = [self getBodyPositionSizeByCode:blcode];
    
    if (size > 0 && (size < min || size > max)) {
        
        *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{ERROR_DESCRIPTION_KEY:[NSString stringWithFormat:@"净体中\"%@\"的尺寸不在范围内",positionName],ERROR_POSITION_BLCODE_KEY:blcode,ERROR_POSITION_NAME_KEY:positionName}];
        
        isPass = NO;
    }
    
    return isPass;
}


-(BOOL)validateClothesSizeData:(NSError *__autoreleasing *)error{
    
    BOOL isPass = YES;
    
    NSArray *categoryArray = [self getCategorySizeType:CategorySizeType_Clothes];
    
    for (CategoryModel *categoryItem in categoryArray) {
        
        if (PERSON_GENDER_MAN == self.gender && [categoryItem.cate isEqualToString:Category_Code_D]) {
            //男性忽略“西裙”的验证
            continue;
        }
        
        NSArray *rangeModelArray = [PositionSizeRangeModel getClothesPositionSizeRangeArray:categoryItem.cate bySex:self.gender andMTM:self.mtm];

        for (PositionSizeRangeModel *rangeModel in rangeModelArray) {
            
            //必填尺寸验证
            isPass = [self validateClothesSizeData_Required:rangeModel forCategory:categoryItem error:error];
            
            if (isPass) {
                //尺寸范围验证
                isPass = [self validateClothesSizeData_Range:rangeModel forCategory:categoryItem error:error];
            }
            
            if (!isPass) {
                break;
            }
        }
        
        if (!isPass) {
            break;
        }
    }
    
    return isPass;
}

/**
 * 成衣的部位尺寸针对某个品类的必填验证
 **/
-(BOOL)validateClothesSizeData_Required:(PositionSizeRangeModel *)rangeModel forCategory:(CategoryModel *)category error:(NSError **)error{
    
    BOOL isPass = YES;
    
    NSString *categoryName = category.name;
    NSString *positionName = rangeModel.position;
    NSString *blcode = rangeModel.blcode;
    
    if (PERSON_GENDER_WOMEN == self.gender) {
        blcode = rangeModel.wblcode;
    }
    
    if ([rangeModel.required isEqualToString:category.cate]) {
        //必填尺寸
        PositionModel *position = [self getPositionByCode:blcode atCategory:category];
        
        if (!position) {
            isPass = NO;
        }else if (category.summerCount > 0 && 0 == position.size){
            isPass = NO;
        }else if (category.winterCount > 0 && 0 == position.size_winter){
            isPass = NO;
        }
    
        if (!isPass) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{
                                                                                   ERROR_DESCRIPTION_KEY:[NSString stringWithFormat:@"请在成衣中输入\"%@-%@\"的尺寸",categoryName,positionName]
                                                                                   }];
        }
    }
    
    
    return isPass;
}

/**
 * 验证成衣的部位尺寸范围
 **/
-(BOOL)validateClothesSizeData_Range:(PositionSizeRangeModel *)rangeModel forCategory:(CategoryModel *)category error:(NSError **)error{
    
    BOOL isPass = YES;
    
    NSString *categoryName = category.name;
    NSString *positionName = rangeModel.position;
    
    NSString *blcode = rangeModel.blcode;
    NSInteger max = 0;
    NSInteger min = 0;
    
    //获取范围
    [rangeModel getRangeMin:&min andRangeMax:&max byIsMan:self.gender];
    
    if (PERSON_GENDER_WOMEN == self.gender) {
        blcode = rangeModel.wblcode;
    }
    
    PositionModel *position = [self getPositionByCode:blcode atCategory:category];
    
    if (position) {
        
        if (category.summerCount > 0 && position.size > 0 && (position.size < min || position.size > max)) {
            //判断夏季尺寸范围
            isPass = NO;
        }
        
        if (category.winterCount > 0 && position.size_winter > 0 && (position.size_winter < min || position.size_winter > max)) {
            //判断冬季尺寸范围
            isPass = NO;
        }
        
        if (!isPass) {
            //尺寸不在范围内
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{
                                                                                   ERROR_DESCRIPTION_KEY:[NSString stringWithFormat:@"成衣中\"%@-%@\"的尺寸不在范围内",categoryName,positionName]
                                                                                   }];
        }
    }
    
    return isPass;
}


#pragma mark - Body Position Size
/**
 * 根据部位名称，获取部位的净体量体尺寸
 **/
-(NSInteger)getBodyPositionSizeByName:(NSString *)positionName{
    
    NSInteger size = 0;
    
    for (PositionModel *itemModel in self.position) {
        
        if ([itemModel.positionname isEqualToString:positionName]) {
            size = itemModel.size;
            break;
        }
        
    }
    
    return size;
}

-(NSInteger)getBodyPositionSizeByCode:(NSString *)blcode{
    
    NSInteger size = 0;
    
    for (PositionModel *itemModel in self.position) {
        
        if ([itemModel.blcode isEqualToString:blcode]) {
            size = itemModel.size;
            break;
        }
        
    }
    
    return size;
    
}

/**
 * 根据部位的编码，获取成衣的品类测量尺寸
 **/
-(PositionModel *)getPositionByCode:(NSString *)blcode atCategory:(CategoryModel *)category{
    
    PositionModel *position;
    
    for (PositionModel *item in category.position) {
        if ([item.blcode isEqualToString:blcode]) {
            position = item;
            break;
        }
    }
    
    return position;
}

#pragma mark - Value Changed Methods
-(void)didChangeValueForKey:(NSString *)key{
    [super didChangeValueForKey:key];
    
    if (![key isEqualToString:@"edittime"]  && ![key isEqualToString:@"status"] && ![key isEqualToString:@"lid"] && ![key isEqualToString:@"lname"]) {
        
        NSDictionary *userInfo = @{KEY_PERSON_USERINFO_NOTIFICATION : self,
                                   KEY_ENTITY_USERINFO_NOTIFICATION : [[self entity] name]
                                   };
        
        //发送修改信息通知
        [[NSNotificationCenter defaultCenter] postNotificationName:KEY_NOTIFICATION_CENTER_PERSON_SIZE_OPERATION object:nil userInfo:userInfo];
    }
}

@end
