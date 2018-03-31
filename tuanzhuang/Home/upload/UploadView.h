//
//  UploadView.h
//  tuanzhuang
//
//  Created by zhuang on 2017/12/8.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CHECKHISTORY = 0,/**<获取检测是否存在历史数据所需要的参数*/
    UPLOADDATAS,/**<上传数据所需要的参数*/
}parameterType;

@interface UploadView : SuperViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray * uploadDatasArray;/**<需要上传的数据*/

@end
