//
//  SeasonCountCollectionViewCell.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/4.
//  Copyright © 2018年 red. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPNumberButton.h"

typedef void(^ValueChangedBlock)(NSString *categoryCode,NSInteger summerCount,NSInteger winterCount);

typedef void(^VoidBlock)(void);

IB_DESIGNABLE
@interface SeasonCountCollectionViewCell : UICollectionViewCell

@property(nonatomic,strong) NSString *categoryCode;
@property(nonatomic,assign) NSInteger summerCount;
@property(nonatomic,assign) NSInteger winterCount;

@property(nonatomic,assign) NSInteger maxCount;

@property(nonatomic,copy) ValueChangedBlock changedBlock;

@property(nonatomic,copy) VoidBlock openBlock;

/**
 * 是否为展开状态
 */
@property(nonatomic,assign) BOOL isOpen;


/**
 * 配置数据
 **/
-(void)configCategoryCode:(NSString *)code summerCount:(NSInteger)sCount winterCount:(NSInteger)wCount;

@end
