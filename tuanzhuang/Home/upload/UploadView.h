//
//  UploadView.h
//  tuanzhuang
//
//  Created by zhuang on 2017/12/8.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadView : SuperViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray * uploadDatasArray;/**<需要上传的数据*/

@end
