//
//  CategoryCollectionViewCell.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/22.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CountChangedBlock)(NSInteger newCount,UILabel *titleLabel);

@interface CategoryCollectionViewCell : UICollectionViewCell

@property(nonatomic,assign) NSInteger count;
@property(nonatomic,strong) NSString *title;

@property(nonatomic,copy) CountChangedBlock changedBlock;

@end
