//
//  SizeConst.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/28.
//  Copyright © 2017年 red. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

#ifndef SizeConst_h
#define SizeConst_h

static NSString * const Category_Code_T = @"T";     //套装(西服、西裤)
static NSString * const Category_Code_A = @"A";     //西服上衣
static NSString * const Category_Code_B = @"B";     //西裤
static NSString * const Category_Code_C = @"C";     //马甲
static NSString * const Category_Code_CY = @"CY";   //长袖衬衫
static NSString * const Category_Code_CD = @"CD";   //短袖衬衫
static NSString * const Category_Code_D = @"D";     //西裙
static NSString * const Category_Code_W = @"E";     //大衣

static NSString * const Category_Code_Array_Str = @"T,A,B,C,CY,CD,D,E";

typedef enum : NSInteger {
    SEASON_TYPE_NONE = -1,
    SEASON_TYPE_SUMMER = 0,
    SEASON_TYPE_WINTER = 1
} SEASON_TYPE;

typedef enum : NSInteger {
    CLOTHES_PLEAT_TYPE_NONE = 0,            //无皱褶
    CLOTHES_PLEAT_TYPE_SINGLE = 1,          //单皱褶
    CLOTHES_PLEAT_TYPE_DOUBLE = 2          //双皱褶
} CLOTHES_PLEAT_TYPE;

typedef enum : NSInteger {
    PERSON_STATUS_WAITING = 0,                  //等待量体
    PERSON_STATUS_PROGRESSING = 1,              //量体中
    PERSON_STATUS_COMPLETED = 2,                //已完成量体
} PERSON_STATUS;

typedef enum : NSUInteger {
    PERSON_GENDER_WOMEN = 0,        //女
    PERSON_GENDER_MAN,              //男
} PERSON_GENDER;



#define BASIC_DATA_PLIST_FILE_PATH  [[NSBundle mainBundle] pathForResource:@"GarmentMessage" ofType:@"plist"]

#endif /* SizeConst_h */
