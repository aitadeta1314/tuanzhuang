//
//  consultViewController.h
//  tuanzhuang
//
//  Created by red on 2018/1/22.
//  Copyright © 2018年 red. All rights reserved.
//

#import "SuperViewController.h"

typedef void(^ChooseCopyPersonBlock)(PersonnelModel *personModel);

@interface consultViewController : SuperViewController
@property (nonatomic, strong) CompanyModel * companymodel;/**<公司信息model*/

@property(nonatomic,copy) ChooseCopyPersonBlock copyPersonBlock;

@end
