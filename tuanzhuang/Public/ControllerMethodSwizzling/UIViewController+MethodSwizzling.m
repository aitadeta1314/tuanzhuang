//
//  UIViewController+MethodSwizzling.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/22.
//  Copyright © 2018年 red. All rights reserved.
//

#import "UIViewController+MethodSwizzling.h"
#import <objc/runtime.h>

@implementation UIViewController (MethodSwizzling)

+(void)load{
    [super load];
    Method fromMethod = class_getInstanceMethod([self class],@selector(viewWillAppear:));
    Method toMethod = class_getInstanceMethod([self class],@selector(customViewWillAppear:));
    
    if (!class_addMethod([self class], @selector(viewWillAppear:), method_getImplementation(toMethod), method_getTypeEncoding(toMethod))) {
        method_exchangeImplementations(fromMethod, toMethod);
    }
}

-(void)customViewWillAppear:(BOOL)animated{
    
    //执行交换后，原始的viewWillAppear
    [self customViewWillAppear:animated];
    
    //执行自定义代码
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backItem;
}

@end
