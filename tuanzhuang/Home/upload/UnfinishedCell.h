//
//  UnfinishedCell.h
//  tuanzhuang
//
//  Created by red on 2018/2/27.
//  Copyright © 2018年 red. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UnfinishedModel.h"

@interface UnfinishedCell : UITableViewCell
-(void)cellWithData:(UnfinishedModel *)model multSelect:(BOOL)mult;
@end
