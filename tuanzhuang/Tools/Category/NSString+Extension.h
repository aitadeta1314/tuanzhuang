//
//  NSString+WN_StringTools.h
//  Wanna
//
//  Created by X-Liang on 16/1/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

/**
 *  验证字符格式
 */
- (BOOL)isValidByRegex:(NSString *)reg;

/**
 *  判断某个字符串是否是有效的字符创(不为空, 长度>0)
 *
 *  @return 判断结果
 */
- (BOOL)isValidString;

/**
 * 删除两边的空格和回车
 **/
- (NSString *)removeSpaceAndNewLine;

/**
 * 将传入的 Objective-C 字典转为 JSon 形式的字典
 */
+ (NSString *)dicToJsonStr:(NSDictionary *)param;

/**
 * 判断是否是iTunes URL
 */
- (BOOL)isiTunesURL;

/// 从str中分离出数字（array）
/**
 *  @"111*(()&&&2343" -> @[111, 2343];
 */
+ (NSArray *)getOnlyNum:(NSString *)str;

/**
 特定字符串（eg:@"1T,2B,2CD"）转字典(eg:@{ T:1, B:2, CD:2 })

 @param str 需要转换的字符串(字符串中含有逗号  例如：@"1T,2B,2CD")
 @return 转换得到的字典
 */
+ (NSDictionary *)stringToDic:(NSString *)str;

/// 从str中分离出数字（string）
/**
 * @"1234" → @"1234"
 * @"001234" → @"001234"
 * @"leading text get removed 001234" → @"001234"
 * @"001234 trailing text gets removed" → @"001234"
 * @"a0b0c1d2e3f4" → @"001234"
 */
+ (NSString *)extractNumberFromText:(NSString *)text;
/**
 验证字符串是否是整型

 @param number string
 @return all numbers return YES, otherwise return NO.
 */
+ (BOOL)isNumber:(NSString *)number;
/**
 验证字符串是否为浮点型(包含整型跟浮点型)

 @param number 需要验证的字符串
 @return ‘是’ return YES, '否'　return　NO.
 */
+ (BOOL)isDecimalNumber:(NSString *)number;
@end
