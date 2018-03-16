//
//  hwlib.h
//  hwlib
//
//  Created by admin on 7/19/13.
//  Copyright (c) 2013 admin. All rights reserved.
//
//  SITE��www.dwhand.com
//  QQ:  1043107063��1119442338
//

#import <Foundation/Foundation.h>

@interface hwlib : NSObject


/****
 *	�����ʼ����
 *
 *	data : ���ݿ����ݣ����������������ݿ�ʱ�����ﴫnull��������ο�demo����
 *	param : ����
 */
+(int)WWRecognitionInit:(void*)data
                       :(void*)param;


/***
 * 
 *	���������ͨ����app����ʱ����
 */
+(int)WWRecognitionExit;



/**
 *
 *	ִ��ʶ��WWRecognizeChar
 *
 *	pbTraceIn1 	: �ʻ��������ݣ����ݲɼ���ο�demo ���롣
 *	candNum		: ��Ҫ���صĽ��������һ����10����
 *	option 		: ʶ��Χ
 *
 *  option �������ֵ���£�
 * 	
 *  #define WWHW_RANGE_NUMBER				0x1         // ʶ��Χ������
 *  #define WWHW_RANGE_LOWER_CHAR			0x2         // ʶ��Χ��Сд��ĸ
 *  #define WWHW_RANGE_UPPER_CHAR			0x4         // ʶ��Χ����д��ĸ 
 *  #define WWHW_RANGE_ASC_SYMBOL           0x8         // ʶ��Χ����Ǳ����� 
 *  #define WWHW_RANGE_GB2312				0x8000      // ʶ��Χ��GB2312���� 
 *  #define WWHW_RANGE_BIG5					0x200       // ʶ��Χ��BIG5����   
 *	#define WWHW_RANGE_CHN_SYMBOL		    0x800       // ʶ��Χ�����ı�����
 *
 *  ���ӣ�
 *			1��ֻʶ������ option ֵΪ 0x8000
 *			2��ֻʶ��СдӢ�� option ֵΪ 0x2
 *			3��ֻʶ���д���� option ֵΪ 0x4
 *			4��ֻʶ������+Ӣ�Ĵ�Сд option ֵΪ 0x8000|0x4|0x2
 *	
 **/

+(NSString*)WWRecognizeChar:(const short*)pbTraceIn1
                     :(int)candNum
                     :(int)option;
                     	

@end
