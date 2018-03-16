//
//  hwlib.h
//  hwlib
//
//  Created by admin on 7/19/13.
//  Copyright (c) 2013 admin. All rights reserved.
//
//  SITE：www.dwhand.com
//  QQ:  1043107063、1119442338
//

#import <Foundation/Foundation.h>

@interface hwlib : NSObject


/****
 *	引擎初始化。
 *
 *	data : 数据库数据，当引擎是内置数据库时，这里传null，具体请参考demo代码
 *	param : 保留
 */
+(int)WWRecognitionInit:(void*)data
                       :(void*)param;


/***
 * 
 *	引擎结束，通常是app结束时调用
 */
+(int)WWRecognitionExit;



/**
 *
 *	执行识别：WWRecognizeChar
 *
 *	pbTraceIn1 	: 笔画坐标数据，数据采集请参考demo 代码。
 *	candNum		: 需要返回的结果数量，一般是10个。
 *	option 		: 识别范围
 *
 *  option 允许的数值如下：
 * 	
 *  #define WWHW_RANGE_NUMBER				0x1         // 识别范围：数字
 *  #define WWHW_RANGE_LOWER_CHAR			0x2         // 识别范围：小写字母
 *  #define WWHW_RANGE_UPPER_CHAR			0x4         // 识别范围：大写字母 
 *  #define WWHW_RANGE_ASC_SYMBOL           0x8         // 识别范围：半角标点符号 
 *  #define WWHW_RANGE_GB2312				0x8000      // 识别范围：GB2312汉字 
 *  #define WWHW_RANGE_BIG5					0x200       // 识别范围：BIG5汉字   
 *	#define WWHW_RANGE_CHN_SYMBOL		    0x800       // 识别范围：中文标点符号
 *
 *  例子：
 *			1、只识别中文 option 值为 0x8000
 *			2、只识别小写英文 option 值为 0x2
 *			3、只识别大写中文 option 值为 0x4
 *			4、只识别中文+英文大小写 option 值为 0x8000|0x4|0x2
 *	
 **/

+(NSString*)WWRecognizeChar:(const short*)pbTraceIn1
                     :(int)candNum
                     :(int)option;
                     	

@end
