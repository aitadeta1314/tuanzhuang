//
//  CustomCollectionFlowLayout.h
//  customCollectionLayout
//
//  Created by zhang gaotang on 2018/1/10.
//  Copyright © 2018年 zhang gaotang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCollectionFlowLayout : UICollectionViewFlowLayout

/**
 * section header vertical alignment
 * YES : align top line
 * NO  : align Section Center
 */
@property(nonatomic,assign) BOOL headerAlignTop;

//section header 与内容区的间隔
@property(nonatomic,assign) CGFloat headerSpacing;

@end
