//
//  SignLayoutManager.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/27.
//  Copyright © 2018年 red. All rights reserved.
//

#import "SignLayoutManager.h"

@implementation SignLayoutManager

-(void)underlineGlyphRange:(NSRange)glyphRange underlineType:(NSUnderlineStyle)underlineVal lineFragmentRect:(CGRect)lineRect lineFragmentGlyphRange:(NSRange)lineGlyphRange containerOrigin:(CGPoint)containerOrigin{
    
    [super underlineGlyphRange:glyphRange underlineType:underlineVal lineFragmentRect:lineRect lineFragmentGlyphRange:lineGlyphRange containerOrigin:CGPointMake(0, 14)];

}

@end
