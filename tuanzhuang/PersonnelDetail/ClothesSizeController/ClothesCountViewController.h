//
//  ClothesCountViewController.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/8.
//  Copyright © 2018年 red. All rights reserved.
//

#import "SuperViewController.h"

typedef void(^ChooseCategoryChangedBlock)(CategoryModel *category);

@interface ClothesCountViewController : SuperViewController

@property(nonatomic,copy) ChooseCategoryChangedBlock changedBlock;

@property(nonatomic,strong) NSArray *categoryArray;

-(void)reloadData;

@end
