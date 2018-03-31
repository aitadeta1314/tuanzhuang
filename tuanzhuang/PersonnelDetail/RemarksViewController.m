//
//  RemarksViewController.m
//  tuanzhuang
//
//  Created by red on 2017/12/13.
//  Copyright © 2017年 red. All rights reserved.
//

#import "RemarksViewController.h"
#import "signView.h"
#import "generatePicture.h"
#import "PersonnelModel+Helper.h"

static const CGFloat size = 50.0;
static const CGFloat scale = 1.2;

@interface RemarksViewController ()
@property (strong, nonatomic)signView *remarkView;
@property (nonatomic, strong) UIButton * writeBtn;/**<“写”按钮*/
@property (nonatomic, strong) UIButton * eraseBtn;/**<”橡皮擦“按钮*/
@property (nonatomic, strong) UIButton * clearBtn;/**<“清空”按钮*/
@property (assign, nonatomic)BOOL write;
@end

@implementation RemarksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //标注短袖长
    [self.personnelmodel setHasShortSleeveFlag];
    
    [self addBackButton];
    _write = YES;
    [self addRightButtonWithTitle:@"保存"];
    self.title = @"备注信息";
    [self.remarkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(TOPNAVIGATIONBAR_H, 0, 0, 0));
    }];
    
    self.writeBtn.selected = YES;
    [self.writeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.remarkView).offset(30);
        make.centerX.mas_equalTo(self.remarkView.mas_right).offset(-20-size*scale*0.5);
        make.size.mas_equalTo(CGSizeMake(size*scale, size*scale));
    }];
    [self.eraseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.writeBtn.mas_bottom).offset(15);
        make.centerX.mas_equalTo(self.writeBtn);
        make.size.mas_equalTo(CGSizeMake(size, size));
    }];
    [self.clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.eraseBtn.mas_bottom).offset(15);
        make.centerX.mas_equalTo(self.eraseBtn);
        make.size.mas_equalTo(CGSizeMake(size, size));
    }];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(signView *)remarkView
{
    if (_remarkView == nil) {
        if (self.personnelmodel.remark == nil) {
            _remarkView = [[signView alloc] init];
        } else {
            _remarkView = [[signView alloc] initWithImage:[UIImage imageWithData:self.personnelmodel.remark]];
        }
        [self.view addSubview:_remarkView];
    }
    return _remarkView;
}

-(UIButton *)writeBtn
{
    if (_writeBtn == nil) {
        _writeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:_writeBtn];
        _writeBtn.imageView.contentMode = UIViewContentModeScaleToFill;
        [_writeBtn setBackgroundColor:RGBColorAlpha(0, 176, 224, 0.8)];
        [_writeBtn setImage:[UIImage imageNamed:@"pencil_icon_unslected"] forState:UIControlStateNormal];
        [_writeBtn setImage:[UIImage imageNamed:@"pencil_icon_selected"] forState:UIControlStateSelected];
        [_writeBtn addTarget:self action:@selector(writeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _writeBtn;
}

-(UIButton *)eraseBtn
{
    if (_eraseBtn == nil) {
        _eraseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:_eraseBtn];
        [_eraseBtn setBackgroundColor:RGBColorAlpha(204, 204, 204, 0.8)];
        [_eraseBtn setImage:[UIImage imageNamed:@"eraser_icon_unselected"] forState:UIControlStateNormal];
        [_eraseBtn setImage:[UIImage imageNamed:@"eraser_icon_selected"] forState:UIControlStateSelected];
        [_eraseBtn addTarget:self action:@selector(eraseAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _eraseBtn;
}

-(UIButton *)clearBtn
{
    if (_clearBtn == nil) {
        _clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:_clearBtn];
        [_clearBtn setBackgroundColor:RGBColorAlpha(204, 204, 204, 0.8)];
        [_clearBtn setImage:[UIImage imageNamed:@"empty_icon_unselected"] forState:UIControlStateNormal];
        [_clearBtn setImage:[UIImage imageNamed:@"empty_icon_selected"] forState:UIControlStateSelected];
        [_clearBtn addTarget:self action:@selector(clearAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearBtn;
}

#pragma mark - 按钮方法
-(void)backButtonPressed
{
    if (self.remarkView.editing) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"是否要保存本次编辑？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction * sureAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (self.remarkView.cleared) {
                self.personnelmodel.remark = nil;
            } else {
                self.personnelmodel.remark = [generatePicture generateImageDataOfView:_remarkView];
            }
            //[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [sureAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
        [alert addAction:cancleAction];
        [alert addAction:sureAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)rightButtonPress
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"您确定要保存此备注吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * sureAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.remarkView.cleared) {
            self.personnelmodel.remark = nil;
        } else {
            self.personnelmodel.remark = [generatePicture generateImageDataOfView:_remarkView];
        }
        //[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [sureAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alert addAction:cancleAction];
    [alert addAction:sureAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)writeAction
{
    if (self.writeBtn.selected) {
        return;
    }
    self.writeBtn.selected = YES;
    [self.writeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(size*scale, size*scale));
    }];
    self.writeBtn.backgroundColor = RGBColorAlpha(0, 176, 224, 0.8);
    
    self.eraseBtn.selected = NO;
    [self.eraseBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(size, size));
    }];
    self.eraseBtn.backgroundColor = RGBColorAlpha(204, 204, 204, 0.8);
    
    self.clearBtn.selected = NO;
    [self.clearBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(size, size));
    }];
    self.clearBtn.backgroundColor = RGBColorAlpha(204, 204, 204, 0.8);
    [self.remarkView write];
}

-(void)eraseAction
{
    if (self.eraseBtn.selected) {
        return;
    }
    self.eraseBtn.selected = YES;
    [self.eraseBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(size*scale, size*scale));
    }];
    self.eraseBtn.backgroundColor = RGBColorAlpha(0, 176, 224, 0.8);
    
    self.writeBtn.selected = NO;
    [self.writeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(size, size));
    }];
    self.writeBtn.backgroundColor = RGBColorAlpha(204, 204, 204, 0.8);
    
    self.clearBtn.selected = NO;
    [self.clearBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(size, size));
    }];
    self.clearBtn.backgroundColor = RGBColorAlpha(204, 204, 204, 0.8);
    [self.remarkView erase];
}

-(void)clearAction
{
    if ([self.personnelmodel hasShortSleeveSize]) {
        [self showHUDMessage:@"短袖长有数据不能清除字迹操作" andDelay:1.5];
        return;
    }
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"您确定要清除全部字迹吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.remarkView clearImage];
    }];
    [sureAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alert addAction:sureAction];
    [alert addAction:cancleAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
