//
//  GetLetter.m
//  tuanzhuang
//
//  Created by red on 2017/12/4.
//  Copyright © 2017年 red. All rights reserved.
//

#import "GetLetter.h"

@implementation GetLetter
+(NSString *)firstLetterOfString:(NSString *)str
{
    if ([str length]) {
        
        NSMutableString *ms = [[NSMutableString alloc] initWithString:str];
        CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO);
        CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO);
        
        NSArray *pyArray = [ms componentsSeparatedByString:@" "];
        if(pyArray && pyArray.count > 0){
            if ([[pyArray firstObject] length] > 0) {
                return [[[pyArray firstObject] substringToIndex:1] uppercaseString];
            }
        }
        ms = nil;
    }
    return @"#";
}
@end
