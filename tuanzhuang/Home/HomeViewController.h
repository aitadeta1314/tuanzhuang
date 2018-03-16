//
//  HomeViewController.h
//  tuanzhuang
//
//  Created by red on 2017/11/29.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : SuperViewController <UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

/**
 *  数据源数组
 */
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (strong, nonatomic) UICollectionView *collectionView;

@end
