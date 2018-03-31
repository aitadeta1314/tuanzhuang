//
//  ZZNumberField.m
//  NumKeyBoard
//
//  Created by zm on 2016/11/21.
//  Copyright © 2016年 zmMac. All rights reserved.
//

#import "ZZNumberField.h"
#import "hwlib.h"


/** 更新以后使用*/
#define keyboardWidth      SCREEN_W             // 键盘宽度
#define keyboardHeight     0.371*SCREEN_W       // 键盘高度
#define topViewHeight      0.132*keyboardHeight // 上面显示文字一行
#define kGrayButtonWidth   0.178*SCREEN_W       // 182px
#define kWhiteButtonWidth  0.195*SCREEN_W       // 白色按键宽度：200px
#define kWhiteButtonHeight 0.184*keyboardHeight // 白色按键高度：70px
#define kSpaceInterval     0.010*SCREEN_W       // 10px

#define CHAR_FONT_SIZE  [UIFont systemFontOfSize:26]  // 字符字体大小
#define NUMBER_FONTSIZE [UIFont systemFontOfSize:36] // 数字字体大小
#define TEXTFIELD_FONT_SIZE [UIFont systemFontOfSize:16]// textfield字体da'xiao

#define FONT_COLOR            RGBColor(51, 51, 51)    // 字体颜色
#define BACKGROUND_COLOR      RGBColor(215, 216, 220) // 内容背景颜色
#define GRAY_COLOR            RGBColor(171, 179, 192) // 背景灰按钮
#define LINE_COLOR            RGBColor(157, 157, 165) // 特殊字符按钮之间颜色

/** 同步码数字键盘*/
#define syncCodeSpaceInterval    4    // 按键上下左右间隔
#define syncCodeButtonWidth      ((keyboardWidth-4*4)/3)  // 按键宽度
#define syncCodeButtonHeight     ((keyboardHeight-4*4)/4) // 按键高度
#define syncCodeNUMBER_COLOR     RGBColor(87, 84, 87)     // 数字背景色
#define syncCodeNONNUM_COLOR     RGBColor(138, 135, 138)  // 非数字背景色
#define syncCode_SpaceInterval_Color RGBColor(56, 60, 61) // 间隔颜色


// 数字键盘
static NSString * const kNumberButton[] = {
    @"1", @"2", @"3",
    @"4", @"5", @"6",
    @"7", @"8", @"9",
    @".", @"0", @" ",
};

@interface ZZNumberField ()

- (void)updateLabel;  // 更新数字键盘输入字符
- (void)updateTextfield:(NSString *)str;  // 更新手写板输入字符

- (void)doDeleteChar; // 删除书写板输入字符
- (void)clearInputTextField;// 清空输入框

@end

@interface ZZNumericInputView() {
    
    /*****手写板使用参数 ↓ *****/
    int timer;
    Boolean stop;
    BOOL isChangeChar;
    short sTrace[2048];
    int nTraceCount;
    
    UIButton * cand1;
    UIButton * cand2;
    UIButton * cand3;
    UIButton * cand4;
    UIButton * cand5;
    UIButton * cand6;
    UIButton * cand7;
    UIButton * cand8;
    UIButton * cand9;
    UIButton * cand10;
    UIButton * resignBtn;
    UIView   * shadeView;
    /*****手写板使用参数 ↑ *****/
}

@end

@implementation ZZNumericInputView

+ (ZZNumericInputView *)sharedInputView
{
    static ZZNumericInputView *view = nil;
    if (view == nil) {
        
        view = [[ZZNumericInputView alloc] initWithFrame:CGRectMake(0, 0, keyboardWidth, keyboardHeight)];
    }
    return view;
}

- (void)setCustomKeyboardType:(KEYBOARDTYPE)customKeyboardType {
    if (_customKeyboardType != customKeyboardType) {
        _customKeyboardType = customKeyboardType;
        [self updateButtonFrame];
    }
}

- (void)setCustomWritingPadType:(WRITINGPAD_TYPE)customWritingPadType {
    if (_customWritingPadType != customWritingPadType) {
        _customWritingPadType = customWritingPadType;
        UIButton *btn = (UIButton *)[self.padImgView viewWithTag:100003];
        if (customWritingPadType == WRITINGPAD_TYPE_SEARCH) {
            
            [btn setTitle:@"搜索" forState:UIControlStateNormal];
        } else {
            [btn setTitle:@"确定" forState:UIControlStateNormal];
        }
    }
}

- (void)layoutSubviews{
    
    [self updateButtonFrame];
    
}
#pragma mark - 重要更新
- (void)updateButtonFrame{
    
    if (_customKeyboardType == KEYBOARDTYPE_NUMBER) {

        self.bgView.hidden = NO;
        self.padImgView.hidden = YES;
        self.syncBGView.hidden = YES;
    }
    else if (_customKeyboardType == KEYBOARDTYPE_WRITINGPAD) {
        self.bgView.hidden = YES;
        self.padImgView.hidden = NO;
        self.syncBGView.hidden = YES;
    } else if (_customKeyboardType == KEYBOARDTYPE_NUMBER_SYNCCODE) {
        self.bgView.hidden = YES;
        self.padImgView.hidden = YES;
        self.syncBGView.hidden = NO;
    }
    
}
#pragma mark - 同步码数字键盘
- (UIView *)syncBGView {
    if (!_syncBGView) {
        _syncBGView = [[UIView alloc] initWithFrame:self.frame];
        _syncBGView.backgroundColor = syncCode_SpaceInterval_Color;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGes:)];
        [_syncBGView addGestureRecognizer:pan];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
        [_syncBGView addGestureRecognizer:tap];
        [self addSubview:_syncBGView];
    }
    return _syncBGView;
}

- (void)layoutSyncCodeNumberKeyboard {
    for (int i = 0; i < 4; i ++) {
        for (int j = 0; j < 3; j ++) {
            UIButton *numberBtn = [[UIButton alloc] initWithFrame:CGRectMake(syncCodeSpaceInterval+(syncCodeButtonWidth+syncCodeSpaceInterval)*j, syncCodeSpaceInterval + (syncCodeButtonHeight+syncCodeSpaceInterval)*i, syncCodeButtonWidth, syncCodeButtonHeight)];
            [self.syncBGView addSubview:numberBtn];
            [numberBtn setTitleColor:RGBColor(255, 255, 255) forState:UIControlStateNormal];
            if (![kNumberButton[3*i+j] isEqualToString:@"."]) {
                
                [numberBtn setTitle:kNumberButton[3*i+j] forState:UIControlStateNormal];
                [numberBtn setBackgroundColor:syncCodeNUMBER_COLOR];
                if ([kNumberButton[3*i+j] isEqualToString:@" "]) {
                    
                    [numberBtn setBackgroundColor:syncCodeNONNUM_COLOR];
                }
            } else {
                
                [numberBtn setBackgroundColor:syncCodeNONNUM_COLOR];
            }
            
            numberBtn.titleLabel.font = NUMBER_FONTSIZE;
            if (i == 3 && j == 2) {
                // 空格键
                [numberBtn setImage:[UIImage imageNamed:@"delete_icon"] forState:UIControlStateNormal];
            }
            if (![kNumberButton[3*i+j] isEqualToString:@"."]) {
                
                [numberBtn addTarget:self action:@selector(syncCodeNumberClick:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

- (void)syncCodeNumberClick:(UIButton *)numberBtn {
    NSString *str = [numberBtn titleForState:UIControlStateNormal];
    
    if ([str isEqualToString:@" "]) {
        // 删除
        [activeField doDeleteChar];
        if ([activeField.numDelegate respondsToSelector:@selector(monitorSyncCodeKeyboardDeleteClick:)]) {
            [activeField.numDelegate monitorSyncCodeKeyboardDeleteClick:activeField];
        }
    } else {
        // 数字点击
        [self specialCharClick:numberBtn];
    }
}

#pragma mark - 数字键盘
/**
 将数字键盘按钮添加到bgView上

 @return 背景按钮bgView
 */
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:self.frame];
        _bgView.backgroundColor = BACKGROUND_COLOR;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGes:)]; // 为了避免滑动背景的时候，有可能出现文字的场景...
        [_bgView addGestureRecognizer:pan];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
        [_bgView addGestureRecognizer:tap];
        [self addSubview:_bgView];
    }
    return _bgView;
}

- (void)panGes:(UIPanGestureRecognizer *)gesture {
    NSLog(@"pan 手势");
}

- (void)tapGes:(UITapGestureRecognizer *)gesture {
    NSLog(@"tap 手势");
}

- (void)createButton{
    // 顶部空白view
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, keyboardWidth, topViewHeight)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:topView];
    
    // 释放键盘按钮
    UIButton *resignBtn = [[UIButton alloc] init];
    [topView addSubview:resignBtn];
    [resignBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(CGRectGetWidth(self.bgView.frame)/11);
        make.height.mas_equalTo(50);
        make.right.mas_equalTo(topView);
        make.centerY.equalTo(topView);
    }];
    [resignBtn setImage:[UIImage imageNamed:@"keyboard_icon"] forState:UIControlStateNormal];
    [resignBtn addTarget:self action:@selector(resignKeyboardMethod) forControlEvents:UIControlEventTouchUpInside];
    
    // 内容背景view
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame), keyboardWidth, keyboardHeight - topViewHeight)];
    [self.bgView addSubview:contentView];
    
    // 左侧view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kGrayButtonWidth+2*kSpaceInterval, keyboardHeight-topViewHeight)];
    leftView.backgroundColor = [UIColor clearColor];
    [contentView addSubview:leftView];
    
    
    // 右侧view
    UIView *rightView = [[UIView alloc] init];
    [contentView addSubview:rightView];
    rightView.backgroundColor = [UIColor clearColor];
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(contentView);
        make.top.equalTo(contentView);
        make.bottom.equalTo(contentView);
        make.width.equalTo(leftView);
    }];
    
    // 中间view
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame), 0, keyboardWidth-2*CGRectGetWidth(leftView.frame), CGRectGetHeight(leftView.frame))];
    [contentView addSubview:centerView];
    contentView.backgroundColor = [UIColor clearColor];
    
    // 布局左侧view
    [self layoutSubViewWithLeftView:leftView];
    
    // 布局右侧view
    [self layoutSubViewWithRightView:rightView];
    
    // 布局中间View
    [self layoutSubViewWithCenterView:centerView];

}

/**
 布局数字键盘左侧view

 @param leftView 左侧背景view
 */
- (void)layoutSubViewWithLeftView:(UIView *)leftView {
    // 返回按钮
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(kSpaceInterval, CGRectGetHeight(leftView.frame)-kSpaceInterval-kWhiteButtonHeight, kGrayButtonWidth, kWhiteButtonHeight)];
    [leftView addSubview:backBtn];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"button_grey_bg"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    backBtn.titleLabel.font = CHAR_FONT_SIZE;
    [backBtn setTitleColor:FONT_COLOR forState:UIControlStateNormal];
    
    // 特殊字符背景view
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(kSpaceInterval, kSpaceInterval, CGRectGetWidth(backBtn.frame), CGRectGetHeight(leftView.frame)-CGRectGetHeight(backBtn.frame)-3*kSpaceInterval)];
    bgView.backgroundColor = LINE_COLOR;
    [leftView addSubview:bgView];
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = 5.0f;
    
    // 特殊字符按钮
    CGFloat btn_H = (CGRectGetHeight(bgView.frame)-2)/3;
    NSArray *charArr = @[@"%", @"-", @"@"];
    for (int i = 0; i < 3; i ++) {
        UIButton *specialChar = [[UIButton alloc] initWithFrame:CGRectMake(0, (1+btn_H)*i, CGRectGetWidth(bgView.frame), btn_H)];
        specialChar.backgroundColor = GRAY_COLOR;
        [bgView addSubview:specialChar];
        [specialChar setTitle:charArr[i] forState:UIControlStateNormal];
        specialChar.titleLabel.font = CHAR_FONT_SIZE;
        [specialChar setTitleColor:FONT_COLOR forState:UIControlStateNormal];
        [specialChar addTarget:self action:@selector(specialCharClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

/**
 布局右侧view

 @param rightView 右侧背景view
 */
- (void)layoutSubViewWithRightView:(UIView *)rightView {
    NSArray *funArr = @[@"", @"清空", @"上一个", @"下一个"];
    for (int i = 0; i < funArr.count; i ++) {
        UIButton *funBtn = [[UIButton alloc] initWithFrame:CGRectMake(kSpaceInterval, kSpaceInterval + (kSpaceInterval + kWhiteButtonHeight)*i, kGrayButtonWidth, kWhiteButtonHeight)];
        [rightView addSubview:funBtn];
        [funBtn setTitle:funArr[i] forState:UIControlStateNormal];
        funBtn.titleLabel.font = CHAR_FONT_SIZE;
        if (i < 2) {
            if (i == 0) {
                // 删除
                [funBtn setImage:[UIImage imageNamed:@"delete_icon"] forState:UIControlStateNormal];
            } else {
                
                [funBtn setTitleColor:FONT_COLOR forState:UIControlStateNormal];
            }
            [funBtn setBackgroundImage:[UIImage imageNamed:@"button_grey_bg"] forState:UIControlStateNormal];
        } else {
            [funBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [funBtn setBackgroundImage:[UIImage imageNamed:@"button_blue_bg"] forState:UIControlStateNormal];
        }
        [funBtn addTarget:self action:@selector(functionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

/**
 布局中间view

 @param centerView 中间背景view
 */
- (void)layoutSubViewWithCenterView:(UIView *)centerView {
    for (int i = 0; i < 4; i ++) {
        for (int j = 0; j < 3; j ++) {
            UIButton *numberBtn = [[UIButton alloc] initWithFrame:CGRectMake((kWhiteButtonWidth+kSpaceInterval)*j, kSpaceInterval + (kWhiteButtonHeight+kSpaceInterval)*i, kWhiteButtonWidth, kWhiteButtonHeight)];
            [centerView addSubview:numberBtn];
            [numberBtn setTitleColor:FONT_COLOR forState:UIControlStateNormal];
            [numberBtn setTitle:kNumberButton[3*i+j] forState:UIControlStateNormal];
            numberBtn.titleLabel.font = NUMBER_FONTSIZE;
            if (i == 3 && j == 2) {
                // 空格键
                [numberBtn setImage:[UIImage imageNamed:@"space_icon"] forState:UIControlStateNormal];
            }
            [numberBtn setBackgroundImage:[UIImage imageNamed:@"number_bg"] forState:UIControlStateNormal];
            [numberBtn addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}
#pragma mark - 数字键盘 按钮点击方法
/**
 返回键  切换到手写板
 */
- (void)backBtnClick {
    [self changeKeyboardType];
}

/**
 特殊字符按钮点击
 */
- (void)specialCharClick:(UIButton *)sender {
    NSString * btnStr = [sender titleForState:UIControlStateNormal];
    
    [activeField updateTextfield:btnStr];
}

/**
 功能按钮【删除、清空、上一个、下一个】

 @param funBtn 功能按钮
 */
- (void)functionButtonClick:(UIButton *)funBtn {
    NSString *str = [funBtn titleForState:UIControlStateNormal];
    
    if ([str isEqualToString:@""]) {
        // 删除
        [activeField doDeleteChar];
        [self dealHideUnderline];
    } else if ([str isEqualToString:@"清空"]) {
        // 清空
        [self dealHideUnderline];
        [activeField clearInputTextField];
    } else if ([str isEqualToString:@"上一个"]) {
        [self dealHideUnderline];
        [[IQKeyboardManager sharedManager] goPrevious];
    } else if ([str isEqualToString:@"下一个"]) {
        [self dealHideUnderline];
        [[IQKeyboardManager sharedManager] goNext];
    }
}

/**
 数字按钮点击

 @param numberBtn 数字按钮
 */
- (void)numberClick:(UIButton *)numberBtn {
    [self specialCharClick:numberBtn];
}

#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0.25f green:0.25f blue:0.25f alpha:1];
        [self createButton];
        [self addSubview:self.padImgView];
        [self addButtons];
        [self layoutSyncCodeNumberKeyboard];
    }
    return self;
}

- (void)becomeActiveField:(ZZNumberField *)field
{
    activeField = field;
    if (isChangeChar) {  // 如果有下划线
        isChangeChar = NO;
    }
}

- (void)resignActiveField:(ZZNumberField *)field
{
    if (isChangeChar) {  // 如果有下划线
        isChangeChar = NO;
    }
    if (activeField == field) activeField = nil;
}

/**
 切换键盘
 */
- (void)changeKeyboardType {
    if (_customKeyboardType == KEYBOARDTYPE_NUMBER) {
        
        self.bgView.hidden = YES;
        self.padImgView.hidden = NO;
        activeField.keyboard = KEYBOARDTYPE_WRITINGPAD;
    }
    else if (_customKeyboardType == KEYBOARDTYPE_WRITINGPAD) {
        self.bgView.hidden = NO;
        self.padImgView.hidden = YES;
        activeField.keyboard = KEYBOARDTYPE_NUMBER;
    }
}

// MARK: UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible
{
    return YES;
}

// MARK: UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}

#pragma mark - 手写板方法

- (UIImageView *)padImgView {
    if (!_padImgView) {
        _padImgView = [[UIImageView alloc] initWithFrame:self.frame];
        _padImgView.backgroundColor = BACKGROUND_COLOR;
        _padImgView.userInteractionEnabled = YES;
        
        nTraceCount = 0;
        timer = 0;
        stop = true;
        isChangeChar = NO;
        
        // init hw engine
        [hwlib WWRecognitionInit:0 :0];
        //并行队列
        dispatch_queue_t queue = dispatch_queue_create("concurrent_queue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(queue, ^{
            NSLog(@"current thread:%@",[NSThread currentThread]);
            [self timerContorl];

        });
        
        UIView *topView = [[UIView alloc] init];
        [_padImgView addSubview:topView];
        topView.backgroundColor = [UIColor whiteColor];
        [topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_padImgView);
            make.width.equalTo(_padImgView);
            make.height.mas_equalTo(topViewHeight);
            make.left.equalTo(_padImgView);
        }];
        
        // 右侧view
        UIView *rightView = [[UIView alloc] init];
        [_padImgView addSubview:rightView];
        rightView.backgroundColor = BACKGROUND_COLOR;
        [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_padImgView);
            make.top.equalTo(topView.mas_bottom);
            make.bottom.equalTo(_padImgView);
            make.width.mas_equalTo(kGrayButtonWidth+2*kSpaceInterval);
        }];
        
        [self layoutPadViewWithRightView:rightView];
        
    }
    return _padImgView;
}

/**
 布局手写板右侧view
 
 @param rightView 右侧背景view
 */
- (void)layoutPadViewWithRightView:(UIView *)rightView {
    NSArray *funArr = @[@"", @"清空", @"123", @"搜索"];
    for (int i = 0; i < funArr.count; i ++) {
        UIButton *funBtn = [[UIButton alloc] initWithFrame:CGRectMake(kSpaceInterval, kSpaceInterval + (kSpaceInterval + kWhiteButtonHeight)*i, kGrayButtonWidth, kWhiteButtonHeight)];
        [rightView addSubview:funBtn];
        funBtn.tag = 100000+i;
        if (i == funArr.count-1) {
            if (self.customWritingPadType == WRITINGPAD_TYPE_SEARCH) {
                // 显示搜索
                [funBtn setTitle:funArr[i] forState:UIControlStateNormal];
            }
            else {
                [funBtn setTitle:@"确定" forState:UIControlStateNormal];
            }
        } else {
            
            [funBtn setTitle:funArr[i] forState:UIControlStateNormal];
        }
        funBtn.titleLabel.font = CHAR_FONT_SIZE;
        if (i < 3) {
            if (i == 0) {
                // 删除
                [funBtn setImage:[UIImage imageNamed:@"delete_icon"] forState:UIControlStateNormal];
            } else {
                
                [funBtn setTitleColor:FONT_COLOR forState:UIControlStateNormal];
            }
            [funBtn setBackgroundImage:[UIImage imageNamed:@"button_grey_bg"] forState:UIControlStateNormal];
        } else {
            [funBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [funBtn setBackgroundImage:[UIImage imageNamed:@"button_blue_bg"] forState:UIControlStateNormal];
        }
        [funBtn addTarget:self action:@selector(padViewFuncClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)addButtons {
    CGFloat btn_width = CGRectGetWidth(self.padImgView.frame) / 11;
    for (NSInteger i = 0; i < 11; i ++) {
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btn_width*i, 0, btn_width, 50)];
        [self.padImgView addSubview:btn];
        btn.titleLabel.font = [UIFont systemFontOfSize:26];
        btn.tag = i+1000;
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        if (i == 10) {
            [btn setImage:[UIImage imageNamed:@"keyboard_icon"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(resignKeyboardMethod) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            [btn addTarget:self action:@selector(candButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }
    
    cand1 = (UIButton*)[self viewWithTag:1000];
    cand2 = (UIButton*)[self viewWithTag:1001];
    cand3 = (UIButton*)[self viewWithTag:1002];
    cand4 = (UIButton*)[self viewWithTag:1003];
    cand5 = (UIButton*)[self viewWithTag:1004];
    cand6 = (UIButton*)[self viewWithTag:1005];
    cand7 = (UIButton*)[self viewWithTag:1006];
    cand8 = (UIButton*)[self viewWithTag:1007];
    cand9 = (UIButton*)[self viewWithTag:1008];
    cand10 = (UIButton*)[self viewWithTag:1009];
    resignBtn = (UIButton *)[self viewWithTag:1010];
}

- (void)timerContorl {
    while (true) {
        [NSThread sleepForTimeInterval:0.05f];
        if (stop) {
            timer = 0;
        }
        if (timer < 1000) {
            timer += 50;
        } else if (timer >= 1000) {
            // 清除面板 主线程更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [self clearImage];
//                [self candButtonClick:cand1];
                [self addUnderline];
                isChangeChar = YES; // 加下划线代表能够替换这个字符
            });
            timer = 0;
            stop = true;
            
        }
        
    }
}

- (void)addUnderline {
    NSString * text = [activeField text];
    NSString * str = [cand1 titleForState:UIControlStateNormal];
    [activeField setText:[NSString stringWithFormat:@"%@%@", text, str]];
    //添加下划线
    if (activeField != nil && text != nil) {
    
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:activeField.text];
        [attributedStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(activeField.text.length-1,1)];
        activeField.attributedText = attributedStr;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    stop = true;
    /// 在写下个字的时候如果还有下划线（代表字符能够修改），则删除下划线，默认选中第一个。
    if (isChangeChar) {
        [self candButtonClick:cand1];
    }
    /// 手按下的时候 隐藏按钮文字
    [cand1 setTitle:@"" forState:UIControlStateNormal];
    [cand2 setTitle:@"" forState:UIControlStateNormal];
    [cand3 setTitle:@"" forState:UIControlStateNormal];
    [cand4 setTitle:@"" forState:UIControlStateNormal];
    [cand5 setTitle:@"" forState:UIControlStateNormal];
    [cand6 setTitle:@"" forState:UIControlStateNormal];
    [cand7 setTitle:@"" forState:UIControlStateNormal];
    [cand8 setTitle:@"" forState:UIControlStateNormal];
    [cand9 setTitle:@"" forState:UIControlStateNormal];
    [cand10 setTitle:@"" forState:UIControlStateNormal];
    
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.padImgView];
    
    sTrace[nTraceCount++] = location.x;
    sTrace[nTraceCount++] = location.y;
    
    UIGraphicsBeginImageContext(self.padImgView.frame.size);
    [self.padImgView.image drawInRect:CGRectMake(0, 0, self.padImgView.frame.size.width, self.padImgView.frame.size.height)];
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 4);                // set sk width
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), YES);
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);         // set 线条平滑
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1); // set color
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.padImgView];
    CGPoint pastLocation = [touch previousLocationInView:self.padImgView];
    
    sTrace[nTraceCount++] = location.x;
    sTrace[nTraceCount++] = location.y;
    
    // draw lines
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), pastLocation.x, pastLocation.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), location.x, location.y);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.padImgView.image = UIGraphicsGetImageFromCurrentImageContext();
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.padImgView];
    
    sTrace[nTraceCount++] = location.x;
    sTrace[nTraceCount++] = location.y;
    sTrace[nTraceCount++] = -1;
    sTrace[nTraceCount++] = 0;
    
    sTrace[nTraceCount++] = -1;
    sTrace[nTraceCount++] = -1;
    NSString * cand1Str = [hwlib WWRecognizeChar:sTrace :10 :0xFFFF];
    
    nTraceCount--;
    nTraceCount--;
    
    [cand1 setTitle:[cand1Str substringWithRange:NSMakeRange(0, 1)] forState:UIControlStateNormal];
    [cand2 setTitle:[cand1Str substringWithRange:NSMakeRange(1, 1)] forState:UIControlStateNormal];
    [cand3 setTitle:[cand1Str substringWithRange:NSMakeRange(2, 1)] forState:UIControlStateNormal];
    [cand4 setTitle:[cand1Str substringWithRange:NSMakeRange(3, 1)] forState:UIControlStateNormal];
    [cand5 setTitle:[cand1Str substringWithRange:NSMakeRange(4, 1)] forState:UIControlStateNormal];
    [cand6 setTitle:[cand1Str substringWithRange:NSMakeRange(5, 1)] forState:UIControlStateNormal];
    [cand7 setTitle:[cand1Str substringWithRange:NSMakeRange(6, 1)] forState:UIControlStateNormal];
    [cand8 setTitle:[cand1Str substringWithRange:NSMakeRange(7, 1)] forState:UIControlStateNormal];
    [cand9 setTitle:[cand1Str substringWithRange:NSMakeRange(8, 1)] forState:UIControlStateNormal];
    [cand10 setTitle:[cand1Str substringWithRange:NSMakeRange(9, 1)] forState:UIControlStateNormal];
    
    UIGraphicsEndImageContext();
    
    stop = false;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIGraphicsEndImageContext();
    [self clearImage];
}


- (void)clearImage
{
    nTraceCount = 0;
    self.padImgView.image = UIGraphicsGetImageFromCurrentImageContext();
    
}

/** 显示字符识别结果的button*/
- (void)candButtonClick:(id)sender
{
    stop = true;
    UIButton * button = (UIButton*)sender;
    NSString * btnStr = [button titleForState:UIControlStateNormal];
    
    if (isChangeChar) {
        // 点击按钮替换默认选择的字符,并且去掉下划线
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithAttributedString:activeField.attributedText];
        NSUInteger leng = activeField.attributedText.length;
        [attributedStr removeAttribute:NSUnderlineStyleAttributeName range:NSMakeRange(leng - 1, 1)];
        [attributedStr replaceCharactersInRange:NSMakeRange(leng-1, 1) withAttributedString:[[NSAttributedString alloc] initWithString:btnStr attributes:nil]];
        activeField.attributedText = attributedStr;
        
    }
    else {
        [activeField updateTextfield:btnStr];
    }
    isChangeChar = NO;
    
    [self buttonClick:sender];
    
}

/** 重写按钮*/
- (void)buttonClick:(id)sender
{
    nTraceCount = 0;
    self.padImgView.image = UIGraphicsGetImageFromCurrentImageContext();
}
#pragma mark - 手写板功能按钮
/**
 释放第一响应者
 */
- (void)resignKeyboardMethod {
    [activeField resignFirstResponder];
}

/**
 手写板功能按钮
 
 @param funBtn 功能按钮
 */
- (void)padViewFuncClick:(UIButton *)funBtn {
    NSString *str = [funBtn titleForState:UIControlStateNormal];
    
    if ([str isEqualToString:@""]) {
        // 删除
//        [activeField doDeleteChar];
        NSMutableAttributedString *beforeStr;
        if (activeField.selectedTextRange.empty) {
            // 选中的文本为空的话，正常删除
            beforeStr = [[NSMutableAttributedString alloc] initWithAttributedString:activeField.attributedText];
            if (beforeStr.length > 0) {
                NSRange range = NSMakeRange([beforeStr length] - 1, 1);
                [beforeStr deleteCharactersInRange:range];
                NSUInteger leng = beforeStr.length;
                [beforeStr removeAttribute:NSUnderlineStyleAttributeName range:NSMakeRange(0, leng)];
            }
            else {
                beforeStr = nil;
            }
        } else {
            // 选中的文本不为空，这里操作是删除textfield中的text值。
            beforeStr = nil;
        }
        activeField.attributedText = beforeStr;
        // 在删除一个字符之后需要将此状态改为NO
        isChangeChar = NO;
    } else if ([str isEqualToString:@"清空"]) {
        // 清空
        [self dealHideUnderline];
        [activeField clearInputTextField];
    } else if ([str isEqualToString:@"123"]) {
        [self dealHideUnderline];
        [self changeKeyboardType];
        
    } else if ([str isEqualToString:@"搜索"]) {
        if ([activeField.numDelegate respondsToSelector:@selector(didSearchClicked)]) {
            [self dealHideUnderline];
            [activeField.numDelegate didSearchClicked];
        }
    } else if ([str isEqualToString:@"确定"]) {
        [self dealHideUnderline];
        [activeField resignFirstResponder];
    }
    
}

/**
 处理隐藏下划线
 */
- (void)dealHideUnderline {
    if (isChangeChar) {  // 如果有下划线
        NSMutableAttributedString * beforeStr = [[NSMutableAttributedString alloc] initWithAttributedString:activeField.attributedText];
        NSUInteger leng = beforeStr.length;
        [beforeStr removeAttribute:NSUnderlineStyleAttributeName range:NSMakeRange(0, leng)];
        activeField.attributedText = beforeStr;
        isChangeChar = NO;
    }
    
}

#pragma mark -

@end


@implementation ZZNumberField

- (void)initSubviews
{
    ZZNumericInputView *view = [ZZNumericInputView sharedInputView];
    self.inputView = view;
    if (self.delegate == nil) {
        self.delegate = view;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self initSubviews];
}

- (void)setKeyboard:(KEYBOARDTYPE)keyboard {
    if (_keyboard != keyboard) {
        _keyboard = keyboard;
        ZZNumericInputView *view = [ZZNumericInputView sharedInputView];
        view.customKeyboardType = keyboard;
    }
}

- (void)setWritingPadType:(WRITINGPAD_TYPE)writingPadType {
    if (_writingPadType != writingPadType) {
        _writingPadType = writingPadType;
        [self initSubviews];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        
        [self initSubviews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self initSubviews];
    }
    return self;
}

- (void)dealloc
{
    [[ZZNumericInputView sharedInputView] resignActiveField:self];
}

/**
 手写板更新textfield

 @param str 新识别的字符
 */
- (void)updateTextfield:(NSString *)str {
    
    NSMutableString *beforeStr;
    if (self.selectedTextRange.empty) {
        beforeStr = [NSMutableString stringWithFormat:@"%@%@",self.text,str];
    } else {
        beforeStr = [NSMutableString stringWithString:str];
    }
    [self setText:beforeStr];
}

- (void)doDeleteChar {
    NSMutableString *beforeStr;
    if (self.selectedTextRange.empty) {
        // 选中的文本为空的话，正常删除
        beforeStr = [NSMutableString stringWithFormat:@"%@",self.text];
        if (beforeStr.length > 0) {
            NSRange range = NSMakeRange([beforeStr length] - 1, 1);
            [beforeStr deleteCharactersInRange:range];
        }
        else {
            beforeStr = nil;
        }
    } else {
        // 选中的文本不为空，这里操作是删除textfield中的text值。
        beforeStr = nil;
    }
    [self setText:beforeStr];
}

/**
 清空textfield
 */
- (void)clearInputTextField {
    [self setText:nil];
}


// MARK: UIResponder

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    // Don't allow actions that we cannot support properly.
    if (action == @selector(selectAll:) || action == @selector(copy:)) {
        return [super canPerformAction:action withSender:sender];
    } else {
        return NO;
    }
}

- (BOOL)becomeFirstResponder
{
    // 在成为第一响应者的时候需要将textfield的下划线富文本移除
    NSMutableAttributedString * beforeStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    NSUInteger leng = beforeStr.length;
    [beforeStr removeAttribute:NSUnderlineStyleAttributeName range:NSMakeRange(0, leng)];
    self.attributedText = beforeStr;
    
    
    if ([super becomeFirstResponder]) {
        ZZNumericInputView *view = [ZZNumericInputView sharedInputView];
        view.customKeyboardType = self.keyboard;
        view.customWritingPadType = self.writingPadType;
        [view becomeActiveField:self];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)resignFirstResponder
{
    // 在释放第一响应者的时候需要将textfield的下划线富文本移除
    NSMutableAttributedString * beforeStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    NSUInteger leng = beforeStr.length;
    [beforeStr removeAttribute:NSUnderlineStyleAttributeName range:NSMakeRange(0, leng)];
    self.attributedText = beforeStr;
    
    if ([super resignFirstResponder]) {
        [[ZZNumericInputView sharedInputView] resignActiveField:self];
        return YES;
    } else {
        return NO;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
