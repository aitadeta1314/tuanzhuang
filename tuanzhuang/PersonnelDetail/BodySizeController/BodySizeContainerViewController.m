//
//  BodySizeContainerViewController.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/28.
//  Copyright © 2017年 red. All rights reserved.
//

#import "BodySizeContainerViewController.h"

#import "BodySizeViewController.h"
#import "BodySizeAddtionalViewController.h"

#define EDGE_INSET_SIZE_INPUT   UIEdgeInsetsMake(0, 1, 0, 486)


@interface BodySizeContainerViewController ()

@property(nonatomic,strong) BodySizeViewController *sizeViewController;

@property(nonatomic,strong) BodySizeAddtionalViewController *addtionalViewController;

@property(nonatomic,strong) LockConverView *converView;

@end

@implementation BodySizeContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self layoutSubViewControllers];
    
    self.converView = [[LockConverView alloc] init];
    [self.view addSubview:self.converView];
    
    [self.converView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(EDGE_INSET_SIZE_INPUT);
    }];
    
    weakObjc(self);
    self.converView.unLockBlock = ^{
        
        if (weakself.unLockBlock) {
            weakself.unLockBlock();
        }
    };
    
    self.converView.hidden = !self.showLockView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)layoutSubViewControllers{
    
    self.sizeViewController = [[BodySizeViewController alloc] init];
    self.sizeViewController.personModel = self.personModel;
    
    self.addtionalViewController = [[BodySizeAddtionalViewController alloc] init];
    self.addtionalViewController.personModel = self.personModel;
    
    [self.view addSubview:self.sizeViewController.view];
    [self.view addSubview:self.addtionalViewController.view];
    
    [self.sizeViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(EDGE_INSET_SIZE_INPUT);
    }];
    
    weakObjc(self);
    
    self.sizeViewController.reloadAddtionalData = ^{
        [weakself.addtionalViewController reloadData];
    };
    
    [self.addtionalViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.offset(0);
        make.left.equalTo(weakself.sizeViewController.view.mas_right).with.offset(1);
        make.right.offset(0);
    }];
    
    UIView *linewView1 = [[UIView alloc] init];
    linewView1.backgroundColor = COLOR_TABLE_CELL_BORDER;
    
    [self.view addSubview:linewView1];
    
    [linewView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.sizeViewController.view.mas_right).with.offset(0);
        make.top.and.bottom.offset(0);
        make.width.mas_equalTo(1);
    }];
}

#pragma mark - Public Methods
-(void)reloadData{
    [self.sizeViewController reloadData];
    [self.addtionalViewController reloadData];
}

-(void)setShowLockView:(BOOL)showLockView{
    _showLockView = showLockView;
    self.converView.hidden = !showLockView;
}


@end
