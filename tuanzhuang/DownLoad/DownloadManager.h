//
//  DownloadManager.h
//  tuanzhuang
//
//  Created by red on 2018/3/22.
//  Copyright © 2018年 red. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^failureBlock)(NSArray * failureArray);
@interface DownloadManager : NSObject
-(void)stop;
-(void)handleDownloadDatas:(NSArray *)missionArray andCover:(BOOL)cover andFailureMissions:(failureBlock)failuremissions;
-(PersonnelModel *)customerInfo:(NSDictionary *)customerdic andCompany:(CompanyModel *)company;
@end
