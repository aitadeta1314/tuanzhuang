//
//  WaterView.h
//  tuanzhuang
//
//  Created by red on 2018/3/6.
//  Copyright © 2018年 red. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    SYN_NORMAL = 0,/**<数据同步正常*/
    SYN_ERROR,/**<数据同步异常*/
}SynDataStatus;

typedef enum {
    SYN_REFRESH = 0,/**<刷新*/
    SYN_CANCLE,/**<取消*/
    SYN_FINISH,/**<完成*/
}OperateType;

typedef void(^buttonBlock)(OperateType type);

@interface WaterView : UIView
@property (nonatomic, copy) NSString * title;/**<标题*/
@property (nonatomic, copy) NSString * message;/**<提示语*/
@property (nonatomic, assign) int step;/**<第几步*/
@property (nonatomic, assign) SynDataStatus status;/**<数据同步状态*/

-(void)show;
-(void)stop;
+(void)clickBlock:(buttonBlock)block;
@end
