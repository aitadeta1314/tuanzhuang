//
//  UploadModel.h
//  tuanzhuang
//
//  Created by red on 2018/3/13.
//  Copyright © 2018年 red. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    UNFINISH = 0,/**<未完成*/
    UPLOADABLE,/**<可上传*/
    NOUPLOADDATAS,/**<无可上传数据*/
    UPLOADING,/**<正在上传*/
    UPLOADED,/**<上传完成*/
    UPLOADFAILURE,/**<上传失败*/
}UploadStatus;

@interface UploadModel : NSObject
@property (nonatomic, strong) CompanyModel * companymodel;/**<公司model*/
@property (nonatomic, assign) UploadStatus status;/**<状态*/
@end
