//
//  DeviderLineDecorationView.m
//  customCollectionLayout
//
//  Created by zhang gaotang on 2018/1/10.
//  Copyright © 2018年 zhang gaotang. All rights reserved.
//

#import "DeviderLineDecorationView.h"

@implementation DeviderLineDecorationView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

-(void)setup{
    self.backgroundColor = COLOR_TABLE_CELL_BORDER;
}

@end
