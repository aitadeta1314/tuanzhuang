//
//  SynCodeView.h
//  tuanzhuang
//
//  Created by red on 2018/2/25.
//  Copyright © 2018年 red. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    FILLIN_SYNCODE,/**<输入同步码*/
    GENERATE_SYNCODE,/**<生成同步码*/
}SynCodeViewType;

typedef void(^confirmBlock)(NSString * code, SynCodeViewType type);
@interface SynCodeView : UIView
@property (nonatomic, assign) SynCodeViewType type;/**<同步码弹框类型*/
@property (nonatomic, strong) NSString * syncode;/**<同步码*/
@property (nonatomic, strong) NSString * name;/**<姓名*/

-(void)show;
+(void)clickConfirmButton:(confirmBlock)block;
//随机生成4位字母
+(NSString *)randomString;
@end
