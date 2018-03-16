//
//  CustomSlideMenuView.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/20.
//  Copyright © 2017年 red. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonnelModel+Helper.h"

static const CGFloat Slide_Menu_Width = 60.0f;

static const CGFloat Slide_Content_Padding_Left = 20.0f;

typedef void(^HideAllSlideMenuBlock)(void);

/**
 * 当前界面显示的菜单数量
 **/
static NSInteger showMenuCount = 0;

@interface CustomSlideMenuView : UIView<CAAnimationDelegate>

@property(nonatomic,strong) CompanyModel *companyModel;
@property(nonatomic,strong) PersonnelModel *personModel;

@property(nonatomic,strong) UIView *contentView;

/**
 * menu title
 */
@property(nonatomic,strong) NSString *menuTitle;

@property(nonatomic,assign) BOOL isOpen;

@property(nonatomic,copy) HideAllSlideMenuBlock hideAllSlideMenuBlock;

-(void)openSlideMenu;

-(void)closeSlideMenu;

-(void)locationMenuAtPositionY:(CGFloat)positionY andSize:(CGSize)size inView:(UIView *)superView;

-(void)reloadData;

@end

