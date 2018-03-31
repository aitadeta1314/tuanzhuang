//
//  ConfigurationViewController.m
//  tuanzhuang
//
//  Created by Fenly on 2017/12/1.
//  Copyright © 2017年 red. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "UIButton+AlignContent.h"
#import "PPNumberButton.h"

#define HORFHEIGHT 50  // 头部label、textfield高度
#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]

#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

@interface ConfigurationViewController ()<UITextFieldDelegate>

/**
 *  项数组
 */
@property (nonatomic, strong) NSArray *itemArr;
/**
 *  数据数组
 */
@property (nonatomic, strong) NSMutableArray *dataArr;


/**
 *  背景view
 */
@property (nonatomic, strong) UIView *bgView;
/**
 *  显示view
 */
@property (nonatomic, strong) UIView *showView;
/**
 *  头部view
 */
@property (nonatomic, strong) UIView *headerView;
/**
 *  单位名称label
 */
@property (nonatomic, strong) UILabel *nameLabel;
/**
 *  tf
 */
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UIView *lineView;
/**
 *  内容view
 */
@property (nonatomic, strong) IQPreviousNextView *centerView;

/**
 *  底部视图
 */
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

/** 保存成为第一响应者的textfield*/
@property (nonatomic, strong) ZZNumberField *becomeFirstNumberField;

@end

@implementation ConfigurationViewController

- (instancetype)initWithItemArray:(NSDictionary *)itemDic topText:(NSString *)nameText{
    
    if (self = [super init]) {
        
        self.view.backgroundColor = [UIColor clearColor];
        self.modalPresentationStyle = UIModalPresentationCustom;
        
        
        _itemArr = @[@"T",@"A",@"B",@"C",@"CY",@"CD",@"D",@"E"];
        // 因为是字典，在这里确定固定顺序
        for (NSInteger i = 0; i < _itemArr.count; i ++) {
            [self.dataArr addObject:[itemDic valueForKey:_itemArr[i]]];
        }
        _companyName = nameText;
        [self setupView];
        
    }
    return self;
}

- (void)setupView {
    // 添加背景View
    [self.view addSubview:self.bgView];
    // 弹框bgView
    [self.bgView addSubview:self.showView];
    // 头部视图
    [self.showView addSubview:self.headerView];
    
    [self.headerView addSubview:self.nameLabel];
    
    [self.headerView addSubview:self.nameTextField];
    
    [self.headerView addSubview:self.lineView];
    
    // 内容视图
    [self.showView addSubview:self.centerView];
    // 底部视图
    [self.showView addSubview:self.bottomView];
    [self.bottomView addSubview:self.saveBtn];
    [self.bottomView addSubview:self.cancelBtn];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_becomeFirstNumberField resignFirstResponder];
}

#pragma mark - 懒加载
- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        CGFloat x = 0;
        CGFloat h = CGRectGetHeight(self.showView.frame)*0.25;
        CGFloat y = CGRectGetHeight(self.showView.frame)-h;
        CGFloat w = CGRectGetWidth(self.showView.frame);
        _bottomView.frame = CGRectMake(x, y, w, h);
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

- (UIButton *)saveBtn {
    if (!_saveBtn) {
        _saveBtn = [[UIButton alloc] init];
        CGFloat w = CGRectGetWidth(self.cancelBtn.frame);
        CGFloat h = CGRectGetHeight(self.cancelBtn.frame);
        CGFloat x = CGRectGetWidth(self.showView.frame)/2+30;
        CGFloat y = CGRectGetMinY(self.cancelBtn.frame);
        _saveBtn.frame = CGRectMake(x, y, w, h);
        [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _saveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [_saveBtn setBackgroundImage:[UIImage imageNamed:@"button_blue_bg"] forState:UIControlStateNormal];
        [_saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _saveBtn;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc]init];
        CGFloat w = 130;
        CGFloat x = CGRectGetWidth(self.showView.frame)/2-30-w;
        CGFloat h = 44;
        CGFloat y = (CGRectGetHeight(self.bottomView.frame)-h)/2;
        _cancelBtn.frame = CGRectMake(x, y, w, h);
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"button_blue_bg"] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}


- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc]initWithFrame:self.view.bounds];
        _bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    }
    return _bgView;
}

- (UIView *)showView {
    if (!_showView) {
        _showView = [[UIView alloc] initWithFrame:self.view.bounds];
        CGFloat w = SCREEN_W * 0.732;
        CGFloat h = w * 0.667;
        CGFloat x = (SCREEN_W - w) / 2;
        CGFloat y = (SCREEN_H - h) / 2;
        _showView.frame = CGRectMake(x, y, w, h);
        _showView.backgroundColor = [UIColor whiteColor];
        _showView.layer.masksToBounds = YES;
        _showView.layer.cornerRadius = 10;
        
    }
    return _showView;
}



- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        CGFloat w = 0.606 * CGRectGetWidth(self.showView.frame);
        CGFloat h = 0.182 * CGRectGetHeight(self.showView.frame);
        CGFloat x = (CGRectGetWidth(self.showView.frame) - w) / 2;
        CGFloat y = 0;
        _headerView.frame = CGRectMake(x, y, w, h);
        _headerView.backgroundColor = [UIColor whiteColor];
    
    }
    return _headerView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        CGFloat w = CGRectGetWidth(self.headerView.frame) / 4;
        CGFloat h = HORFHEIGHT;
        CGFloat x = 0;
        CGFloat y = (CGRectGetHeight(self.headerView.frame)-h)/2;
        _nameLabel.frame = CGRectMake(x, y, w, h);
        _nameLabel.text = @"单位名称：";
        _nameLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    return _nameLabel;
}

- (UITextField *)nameTextField {
    if (!_nameTextField) {
        _nameTextField = [[UITextField alloc] init];
        CGFloat w = CGRectGetWidth(self.headerView.frame) - CGRectGetWidth(self.nameLabel.frame);
        CGFloat h = HORFHEIGHT-10;
        CGFloat x = CGRectGetMaxX(self.nameLabel.frame);
        CGFloat y = (CGRectGetHeight(self.headerView.frame) - h) / 2;
        _nameTextField.frame = CGRectMake(x, y, w, h);
        _nameTextField.borderStyle = UITextBorderStyleNone;
        _nameTextField.textAlignment = NSTextAlignmentCenter;
        _nameTextField.userInteractionEnabled = NO;
        _nameTextField.text = _companyName;
        _nameTextField.font = [UIFont boldSystemFontOfSize:18];
    }
    return _nameTextField;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        CGFloat w = CGRectGetWidth(self.nameTextField.frame);
        CGFloat h = 1;
        CGFloat x = CGRectGetMinX(self.nameTextField.frame);
        CGFloat y = CGRectGetMaxY(self.nameTextField.frame);
        _lineView.frame = CGRectMake(x, y, w, h);
        _lineView.backgroundColor = RGBColor(204, 204, 204);
    }
    return _lineView;
}

- (IQPreviousNextView *)centerView {
    if (!_centerView) {
        _centerView = [[IQPreviousNextView alloc] init];
        CGFloat w = CGRectGetWidth(self.showView.frame);
        CGFloat h = CGRectGetHeight(self.showView.frame)*0.568;
        CGFloat y = CGRectGetMaxY(self.headerView.frame);
        CGFloat x = 0;
        _centerView.frame = CGRectMake(x, y, w, h);
        _centerView.backgroundColor = [UIColor whiteColor];
        
        CGFloat every_w = w/3; // 每项宽
        CGFloat every_h = h/3; // 每项高
        CGFloat itemSub_w = (every_w - every_w/6/2)/5; // 减按钮的宽
        CGFloat itemSub_h = itemSub_w; // 减按钮的高
        CGFloat itemSub_y = (every_h - itemSub_h)/2;   // y
        CGFloat itemForMinus_x = every_w/5;          // 减按钮的x
        for (int i = 0; i < 3; i ++) {
            for (int j = 0; j < 3; j ++) {
                if (i == 2 && j == 2) {
                    break;
                }
                UIView *itemView = [[UIView alloc] init];
                CGFloat item_x = every_w * j;
                CGFloat item_y = every_h * i;
                CGFloat item_w = every_w;
                CGFloat item_h = every_h;
                itemView.tag = i*3+j;
                itemView.frame = CGRectMake(item_x, item_y, item_w, item_h);
                itemView.backgroundColor = [UIColor whiteColor];
                [_centerView addSubview:itemView];
            
                CGFloat minus_x = itemForMinus_x;
                CGFloat minus_y = itemSub_y;
                CGFloat minus_w = itemSub_w;
                CGFloat minus_h = itemSub_h;
                    
                PPNumberButton *ppView = [[PPNumberButton alloc] initWithFrame:CGRectMake(minus_x, minus_y, minus_w*3, minus_h)];
                ppView.textField.delegate = self;
                ppView.textField.tintColor = [UIColor orangeColor];
                ppView.textField.tag = i*3+j + 100;
                ppView.decreaseTitle = @"-";
                ppView.increaseTitle = @"+";
                ppView.borderWidth = 0.8f;
                ppView.buttonTitleFont = 20;
                ppView.inputFieldFont = 20;
                ppView.borderColor = [UIColor lightGrayColor];
                ppView.minValue = 0;
                ppView.maxValue = MAXVALUE;
                ppView.tag = i * 3 + j + 1000;
                ppView.currentNumber = [self.dataArr[i*3+j] integerValue];
                [itemView addSubview:ppView];
                weakObjc(ppView);
                ppView.resultBlock = ^(NSInteger number, BOOL increaseStatus) {
                    NSLog(@"number:%ld",number);
                    [_becomeFirstNumberField resignFirstResponder];
                    NSInteger index = weakppView.tag-1000;
                    for (int i = 0; i < 3; i ++) {
                        for (int j = 0; j < 3; j ++) {
                            if (i == 2 && j == 2) {
                                break;
                            }
                            UIView *itemView = [self.centerView viewWithTag:i*3+j];
                            PPNumberButton *ppTempView = [itemView viewWithTag:i*3+j+1000];
                            if (index == i*3+j) {
                                
                                ppTempView.borderColor = [UIColor orangeColor];
                            } else {
                                ppTempView.borderColor = [UIColor lightGrayColor];
                            }
                        }
                    }
                    
                    NSString *textStr = [NSString stringWithFormat:@"%ld",(long)number];
                    // 显示之后更新self.dataArr数组 同步配置信息
                    [self syncConfigurationInfoWithIndex:index andTextStr:textStr];
                };
                
                // item项
                UILabel *itemLb = [[UILabel alloc] init];
                CGFloat itemlb_x = CGRectGetMaxX(ppView.frame);
                CGFloat itemlb_y = itemSub_y;
                CGFloat itemlb_w = itemSub_w;
                CGFloat itemlb_h = itemSub_h;
                itemLb.frame = CGRectMake(itemlb_x, itemlb_y, itemlb_w, itemlb_h);
                itemLb.text = _itemArr[i*3+j];
                itemLb.textAlignment = NSTextAlignmentCenter;
                [itemView addSubview:itemLb];
                
            }
        }
    }
    return _centerView;
}

#pragma mark - uitextfieldDelegate
- (void)textFieldDidBeginEditing:(ZZNumberField *)textField {
    _becomeFirstNumberField = textField;
    // 防止在第一次全选（并且textfield值没有改变）之后，第二次成为第一响应者的时候不会出现选中状态。
    [textField performSelector:@selector(selectAll:) withObject:nil afterDelay:0.0f];
   
    NSInteger index = textField.tag - 100;

    for (int i = 0; i < 3; i ++) {
        for (int j = 0; j < 3; j ++) {
            if (i == 2 && j == 2) {
                break;
            }

            UIView *itemView = [self.centerView viewWithTag:i*3+j];
            PPNumberButton *ppView = [itemView viewWithTag:i*3+j + 1000];
            if (index == i*3+j) {
                ppView.borderColor = [UIColor orangeColor];
            } else {
                ppView.borderColor = [UIColor lightGrayColor];
            }
        }
    }
}

- (void)textFieldDidEndEditing:(ZZNumberField *)textField {

    if (![NSString isNumber:textField.text]) {
        textField.text = @"";
    } else {
        if ([textField.text intValue] > MAXVALUE) {
            textField.text = [NSString stringWithFormat:@"%d", MAXVALUE];
        }
        NSInteger index = textField.tag - 100;
        // 结束编辑的时候更新self.dataArr数组 和 配置信息
        [self syncConfigurationInfoWithIndex:index andTextStr:textField.text];
    }
}

/** 保存按钮*/
- (void)saveBtnClick {
    
    if (self.saveSelectBlock) {
        /// 每次加减按钮点击都会更新数据源self.dataArr  返回数据直接使用self.dataArr
        
        NSMutableString *configurationStr = [[NSMutableString alloc] init];
        for (NSInteger i = 0; i < self.dataArr.count; i ++) {
            if ([self.dataArr[i] integerValue] > 0) {
                if ([configurationStr isValidString]) {
                    
                    configurationStr = [NSMutableString stringWithFormat:@"%@,%@-%@",configurationStr,self.dataArr[i],_itemArr[i]];
                }
                else {
                    configurationStr = [NSMutableString stringWithFormat:@"%@-%@",self.dataArr[i],_itemArr[i]];
                }
            }
        }
        self.saveSelectBlock(configurationStr);
    }
    [self cancelBtnClick];
}

/** 取消按钮*/
- (void)cancelBtnClick {
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

#pragma mark -  同步配置信息 和 self.dataArr
- (void)syncConfigurationInfoWithIndex:(NSUInteger)index andTextStr:textStr {
    
    [self.dataArr replaceObjectAtIndex:index withObject:textStr];
    NSMutableString *configurationStr = [[NSMutableString alloc] init];
    for (NSInteger i = 0; i < self.dataArr.count; i ++) {
        if ([self.dataArr[i] integerValue] > 0) {
            
            configurationStr = [NSMutableString stringWithFormat:@"%@%@%@",configurationStr,self.dataArr[i],_itemArr[i]];
        }
    }
    
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    } completion:^(BOOL finished) {
        
    }];
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
