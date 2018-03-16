//
//  SynCodeView.m
//  tuanzhuang
//
//  Created by red on 2018/2/25.
//  Copyright © 2018年 red. All rights reserved.
//

#import "SynCodeView.h"
#define w 270.0
#define h 196.0

#define label_tag 1000
#define textfield_size 50.0
#define button_w 90.0
#define button_h 36.0
#define closebutton_size 20
#define view_cornerRadius 10
#define button_cornerRadius 7

@interface SynCodeView()<ZZNumberFieldDelegate>
@property (nonatomic, strong) UIView * noticeView;/**<提示框*/
@property (nonatomic, strong) UILabel * nameLabel;/**<姓名label*/
@property (nonatomic, strong) UIButton * cancleBtn;/**<取消按钮*/
@property (nonatomic, strong) UIButton * confirmBtn;/**<确定按钮*/
@property (nonatomic, strong) UIButton * closeBtn;/**<关闭按钮*/
@property (nonatomic, strong) ZZNumberField * textfield;/**<*/
@end

@implementation SynCodeView

#pragma mark - 初始化
-(instancetype)init
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
        self.backgroundColor = RGBColorAlpha(0, 0, 0, 0.5);
        self.hidden = YES;
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
        self.backgroundColor = RGBColorAlpha(0, 0, 0, 0.5);
        self.hidden = YES;
    }
    return self;
}

#pragma mark - 布局
//弹框布局
-(void)layoutNoticeView
{
    [self.noticeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(100);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(w);
        make.height.mas_equalTo(h);
    }];
}

//"姓名"label布局
-(void)layoutNameLabel
{
    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.noticeView).offset(10);
        make.left.mas_equalTo(self.noticeView).offset(20);
        make.right.mas_equalTo(self.closeBtn.mas_left).offset(-20);
        make.height.mas_equalTo(36);
    }];
}

//“关闭”按钮布局
-(void)layoutCloseButton
{
    CGFloat offset;
    if (self.type == FILLIN_SYNCODE) {
        offset = -20-closebutton_size;
    } else {
        offset = 0;
    }
    [self.closeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nameLabel);
        make.left.mas_equalTo(self.noticeView.mas_right).offset(offset);
        make.size.mas_equalTo(CGSizeMake(closebutton_size, closebutton_size));
    }];
}

//“取消”按钮布局
-(void)layoutCancleButton
{
    [self.cancleBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.noticeView).offset((w-2*button_w)/3.0);
        make.bottom.mas_equalTo(self.noticeView).offset(-20);
        make.width.mas_equalTo(button_w);
        make.height.mas_equalTo(button_h);
    }];
}

//“确定”按钮布局
-(void)layoutConfirmButton
{
    CGFloat right_offset;
    if (_type == GENERATE_SYNCODE) {
        right_offset = -1*(w-2*button_w)/3.0;
    } else {
        right_offset = -1*(w-button_w)/2.0;
    }
    [self.confirmBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.noticeView).offset(right_offset);
        make.bottom.mas_equalTo(self.cancleBtn);
        make.width.mas_equalTo(button_w);
        make.height.mas_equalTo(button_h);
    }];
}

#pragma mark - 懒加载
-(UIView *)noticeView
{
    if (_noticeView == nil) {
        _noticeView = [[UIView alloc] init];
        _noticeView.backgroundColor = [UIColor whiteColor];
        _noticeView.layer.borderWidth = 0.6;
        _noticeView.layer.borderColor = RGBColor(204, 204, 204).CGColor;
        _noticeView.layer.cornerRadius = view_cornerRadius;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showkeyboard)];
        [_noticeView addGestureRecognizer:tap];
        [self addSubview:_noticeView];
    }
    return _noticeView;
}

-(UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        [self.noticeView addSubview:_nameLabel];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = RGBColor(51, 51, 51);
    }
    return _nameLabel;
}

-(UIButton *)closeBtn
{
    if (_closeBtn == nil) {
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
        [self.noticeView addSubview:_closeBtn];
    }
    return _closeBtn;
}

-(UIButton *)cancleBtn
{
    if (_cancleBtn == nil) {
        _cancleBtn = [[UIButton alloc] init];
        _cancleBtn.backgroundColor = [UIColor whiteColor];
        _cancleBtn.layer.cornerRadius = button_cornerRadius;
        _cancleBtn.layer.borderColor = RGBColor(0, 122, 255).CGColor;
        _cancleBtn.layer.borderWidth = 0.6;
        _cancleBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_cancleBtn setTitle:@"取  消" forState:UIControlStateNormal];
        [_cancleBtn setTitleColor:RGBColor(0, 122, 255) forState:UIControlStateNormal];
        [_cancleBtn addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
        [self.noticeView addSubview:_cancleBtn];
    }
    return _cancleBtn;
}

-(UIButton *)confirmBtn
{
    if (_confirmBtn == nil) {
        _confirmBtn = [[UIButton alloc] init];
        _confirmBtn.backgroundColor = [UIColor whiteColor];
        _confirmBtn.layer.cornerRadius = button_cornerRadius;
        _confirmBtn.layer.borderColor = RGBColor(0, 122, 255).CGColor;
        _confirmBtn.layer.borderWidth = 0.6;
        _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_confirmBtn setTitle:@"确  定" forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:RGBColor(0, 122, 255) forState:UIControlStateNormal];
        [_confirmBtn addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
        [self.noticeView addSubview:_confirmBtn];
    }
    return _confirmBtn;
}

-(ZZNumberField *)textfield
{
    if (_textfield == nil) {
        _textfield = [[ZZNumberField alloc] init];
        _textfield.numDelegate = self;
        _textfield.keyboard = KEYBOARDTYPE_NUMBER_SYNCCODE;
        [self addSubview:_textfield];
    }
    return _textfield;
}

#pragma mark - set方法
-(void)setType:(SynCodeViewType)type
{
    _type = type;
    self.closeBtn.hidden = type == GENERATE_SYNCODE;
    self.cancleBtn.hidden = type == FILLIN_SYNCODE;
    if (_type == FILLIN_SYNCODE) {
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        _syncode = @"";
        [self clearnSyncodelabel];
    } else {
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    [self layoutNoticeView];
    [self layoutNameLabel];
    [self layoutCloseButton];
    [self layoutCancleButton];
    [self layoutConfirmButton];
    [self handleTextfields];
    [self confirmButtonEnable:type == GENERATE_SYNCODE];
}

-(void)setSyncode:(NSString *)syncode
{
    if (self.type == FILLIN_SYNCODE) {
        return;
    }
    _syncode = syncode;
    if (![self viewWithTag:label_tag]) {
        [self handleTextfields];
    }
    [self fillCode];
}

-(void)setName:(NSString *)name
{
    _name = name;
    self.nameLabel.text = [NSString stringWithFormat:@"%@的同步码",name];
}

#pragma mark - 创建textfield
-(void)handleTextfields
{
    for (int i = 0; i<4; i++) {
        UILabel * label = [self viewWithTag:label_tag+i];
        if (label == nil) {
            label = [[UILabel alloc] init];
            label.tag = label_tag + i;
            label.layer.masksToBounds = YES;
            label.layer.cornerRadius = button_cornerRadius;
            label.layer.borderWidth = 0.6;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:18];
            [self.noticeView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.noticeView).offset(20+i*(textfield_size+10));
                make.bottom.mas_equalTo(self.noticeView).offset(-82);
                make.size.mas_equalTo(CGSizeMake(textfield_size, textfield_size));
            }];
        }
        if (self.type == FILLIN_SYNCODE) {
            label.layer.borderColor = RGBColor(220, 220, 220).CGColor;
            label.backgroundColor = RGBColor(255, 255, 255);
            label.textColor = RGBColor(0, 122, 255);
        } else {
            label.layer.borderColor = RGBColor(0, 122, 255).CGColor;
            label.backgroundColor = RGBColor(0, 122, 255);
            label.textColor = RGBColor(255, 255, 255);
        }
    }
    
}

#pragma mark - 点击按钮方法
-(void)cancleAction
{
    self.hidden = YES;
    if (_type == FILLIN_SYNCODE) {
        [self removeTextfieldsTarget];
    }
}

static confirmBlock _block;
-(void)confirmAction
{
    self.hidden = YES;
    if (_block) {
        _block(self.syncode,self.type);
    }
    if (_type == FILLIN_SYNCODE) {
        [self removeTextfieldsTarget];
    }
}

+(void)clickConfirmButton:(confirmBlock)block
{
    _block = block;
}

#pragma mark - 私有方法
//显示弹框
-(void)show
{
    self.hidden = NO;
    if (_type == FILLIN_SYNCODE) {
        [self.textfield becomeFirstResponder];
        [self.textfield addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionOld context:nil];
    }
}

//显示键盘
-(void)showkeyboard
{
    if (_type == FILLIN_SYNCODE) {
        [self.textfield becomeFirstResponder];
    }
}

-(void)confirmButtonEnable:(BOOL)enable
{
    _confirmBtn.enabled = enable;
    if (enable) {
        _confirmBtn.layer.borderColor = RGBColor(0, 122, 255).CGColor;
        [_confirmBtn setTitleColor:RGBColor(0, 122, 255) forState:UIControlStateNormal];
    } else {
        _confirmBtn.layer.borderColor = RGBColor(105, 105, 105).CGColor;
        [_confirmBtn setTitleColor:RGBColor(105, 105, 105) forState:UIControlStateNormal];
    }
}

//随机生成4位字母
+(NSString *)randomString
{
    NSMutableString * randomString = [[NSMutableString alloc] init];
    for (int i = 0; i < 4; i ++) {
        int figure = arc4random() % 26;
        char c = 'A'+figure;
        [randomString appendFormat:@"%c",c];
    }
    return randomString;
}

//填充生成的同步码
-(void)fillCode
{
    NSMutableArray * codeArray = [NSMutableArray arrayWithCapacity:0];
    // 遍历字符串，按字符来遍历。每个字符将通过block参数中的substring传出
    [_syncode enumerateSubstringsInRange:NSMakeRange(0, _syncode.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        [codeArray addObject:substring];
    }];
    [self clearnSyncodelabel];
    for (int i = 0; i<4; i++) {
        UILabel * label = [self viewWithTag:label_tag+i];
        label.text = i<codeArray.count ? codeArray[i] : @"";
        label.layer.borderColor = label.text.length == 0 ? RGBColor(220, 220, 220).CGColor : RGBColor(0, 122, 255).CGColor;
    }
}

//清空同步码label
-(void)clearnSyncodelabel
{
    for (int i = 0; i<4; i++) {
        UILabel * label = [self viewWithTag:label_tag+i];
        label.text = @"";
    }
}

//移除监听
-(void)removeTextfieldsTarget
{
    self.syncode = @"";
    _textfield.text = @"";
    
    [_textfield removeObserver:self forKeyPath:@"text"];
    [_textfield resignFirstResponder];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    NSString * oldValue = [NSString stringWithFormat:@"%@",[change objectForKey:NSKeyValueChangeOldKey]];
    ZZNumberField * textfield = (ZZNumberField *)object;
    if (textfield.text.length > 4) {
        textfield.text = oldValue;
    }
    _syncode = textfield.text;
    [self fillCode];
    [self confirmButtonEnable:_syncode.length == 4];
    
}

@end
