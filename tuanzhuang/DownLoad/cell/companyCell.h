//
//  companyCell.h
//  tuanzhuang
//
//  Created by red on 2017/11/29.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>
@class companyModel;
typedef void(^downloadBlock)(NSInteger index);
@interface companyCell : UITableViewCell
-(void)cellWithData:(companyModel *)model showSelect:(BOOL)show keyWords:(NSString *)keywords andIndex:(NSInteger)index;

+(void)downloadWithBlock:(downloadBlock)block;
@end
