//
//  NSString+WN_StringTools.m
//  Wanna
//
//  Created by X-Liang on 16/1/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (BOOL)isValidByRegex:(NSString *)reg{
    NSRange range = [self rangeOfString:reg options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        return YES;
    }else {
        return NO;
    }
}

- (BOOL)isValidString {
    return ([self isValidObject] && self.length > 0);
}

/**
 * 删除两边的空格和回车
 **/
- (NSString *)removeSpaceAndNewLine{
    
    NSString *temp = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *text = [temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return text;
}


+ (NSString *)dicToJsonStr:(NSDictionary *)param {
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

- (BOOL)isMatch:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    if (error) {
        return NO;
    }
    NSTextCheckingResult *res = [regex firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    return res != nil;
}

- (BOOL)isiTunesURL {
    return [self isMatch:@"\\/\\/itunes\\.apple\\.com\\/"];
}
+ (NSArray *)getOnlyNum:(NSString *)str {
    
    NSString *onlyNumStr = [str stringByReplacingOccurrencesOfString:@"[^0-9,]"
                                                          withString:@""
                                                             options:NSRegularExpressionSearch
                                                               range:NSMakeRange(0, [str length])];
    NSArray *numArr = [onlyNumStr componentsSeparatedByString:@""];
    return numArr;
}

+ (NSDictionary *)stringToDic:(NSString *)str {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:@{@"T":@"0",@"A":@"0",@"B":@"0",@"C":@"0",@"CY":@"0",@"CD":@"0",@"D":@"0",@"E":@"0"}];
    if ([str isValidString]) {
        
        NSArray *arr = [str componentsSeparatedByString:@","];
//        NSLog(@"arr:%@",arr);
        [arr enumerateObjectsUsingBlock:^(NSString *tempStr, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSArray *numberStr = [tempStr componentsSeparatedByString:@"-"];
            NSString *number = numberStr.firstObject;
            NSString *typeStr = numberStr.lastObject;
            
            [dic setValue:number forKey:typeStr];
        }];
//        NSLog(@"dic:%@",dic);
    }
    
    return dic;
}

+ (NSString *)extractNumberFromText:(NSString *)text
{
    NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [[text componentsSeparatedByCharactersInSet:nonDigitCharacterSet] componentsJoinedByString:@""];
}

+ (BOOL)isNumber:(NSString *)number {
    
    NSScanner* scan = [NSScanner scannerWithString:number];
    
    int val;
    
    return[scan scanInt:&val] && [scan isAtEnd];
}

+ (BOOL)isDecimalNumber:(NSString *)number {
    
    
    NSScanner* scan = [NSScanner scannerWithString:number];
        
    float val;
    
    return[scan scanFloat:&val] && [scan isAtEnd];
}
@end
