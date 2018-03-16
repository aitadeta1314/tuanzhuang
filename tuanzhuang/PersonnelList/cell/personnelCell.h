//
//  personnelCell.h
//  tuanzhuang
//
//  Created by red on 2017/12/4.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PersonnelModel;

@interface personnelCell : UITableViewCell
-(void)cellWithData:(PersonnelModel *)model linehide:(BOOL)hide needoffset:(BOOL)needoffset;
@end
