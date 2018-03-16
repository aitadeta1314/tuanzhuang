//
//  SizeTableViewCell.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/26.
//  Copyright © 2017年 red. All rights reserved.
//

#import "SizeTableViewCell.h"

#define TITLE_FONT              [UIFont systemFontOfSize:20.0]
#define DETAIL_FONT             [UIFont systemFontOfSize:18.0]

#define COLOR_NORMAL            RGBColor(153,153,153)

#define COLOR_TITLE_REQUIRED    RGBColor(255, 0, 0)

#define COLOR_TITLE_SELECTED    RGBColor(51,51,51)

#define COLOR_INPUT_TEXT_SELECTED RGBColor(255,162,0)


@interface SizeTableViewCell()<UITextFieldDelegate>{
    NSInteger _minSize;
    NSInteger _maxSize;
    NSInteger _oldSizeValue;
    BodySizeCellStatus _oldStatus;
    
    UILabel *_bottomLine;
    
    BOOL _required;
}

@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UILabel *promptLabel;

@end

@implementation SizeTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self layoutCustomSubviews];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - Public Methods
/**
 * 配置净体cell显示的数据
 **/
-(void)setBodySizeTitle:(NSString *)title andSizeValue:(NSInteger)size andMinSize:(NSInteger)minSize andMaxSize:(NSInteger)maxSize isRequired:(BOOL)required{
    
    self.sizeTextField.enabled = YES;
    
    NSString *sizeValue = @"";
    if (size >0) {
        sizeValue = [NSString stringWithFormat:@"%ld",(long)size];
    }
    
    _oldSizeValue = [sizeValue integerValue];
    
    [self setTitle:title andSizeValue:sizeValue andMinSize:minSize andMaxSize:maxSize isRequired:required];
    
}

/**
 * 配置成衣cell显示的数据
 **/
-(void)setClothSizeTitle:(NSString *)title andSizeValue:(NSString *)sizeValue andMinSize:(NSInteger)minSize andMaxSize:(NSInteger)maxSize isRequired:(BOOL)required{
    
    self.sizeTextField.enabled = NO;
    
    [self setTitle:title andSizeValue:sizeValue andMinSize:minSize andMaxSize:maxSize isRequired:required];
}

/**
 * 净体与成衣的统一数据配置
 **/
-(void)setTitle:(NSString *)title andSizeValue:(NSString *)sizeValue andMinSize:(NSInteger)minSize andMaxSize:(NSInteger)maxSize isRequired:(BOOL)required{
    _minSize = minSize;
    _maxSize = maxSize;
    
    self.titleLabel.text = title;
    self.promptLabel.text = [NSString stringWithFormat:@"cm（范围：%ld-%ld）",(long)minSize,(long)maxSize];
    
    _required = required;
    if (_required) {
        self.titleLabel.textColor = COLOR_TITLE_REQUIRED;
    }else{
        self.titleLabel.textColor = COLOR_NORMAL;
    }
    
    self.sizeTextField.text = sizeValue;
}

-(void)setStatus:(BodySizeCellStatus)status{
    
    _status = status;
    
    UIColor *borderColor = [UIColor clearColor];
    CGFloat borderWidth = 0.0;
    UIColor *titleColor = COLOR_NORMAL;
    UIColor *inputColor = COLOR_NORMAL;
    UIColor *promptColor = COLOR_NORMAL;
    
    switch (status) {
        case BodySizeCellStatus_Selected:
            borderColor = COLOR_PERSION_INFO_SELECTED;
            borderWidth = 1.0;
            
            promptColor = COLOR_TITLE_SELECTED;
            titleColor = COLOR_TITLE_SELECTED;
            inputColor = COLOR_INPUT_TEXT_SELECTED;
            
            break;
        case BodySizeCellStatus_Warning:
            borderColor = [UIColor redColor];
            borderWidth = 1.0;
            
            inputColor = COLOR_INPUT_TEXT_SELECTED;
            titleColor = COLOR_TITLE_SELECTED;
            promptColor = COLOR_TITLE_SELECTED;
            
        default:
            break;
    }
    
    self.contentView.layer.borderColor = borderColor.CGColor;
    self.contentView.layer.borderWidth = borderWidth;
    
    self.sizeTextField.textColor = inputColor;
    self.promptLabel.textColor = promptColor;

    if (_required) {
        self.titleLabel.textColor = COLOR_TITLE_REQUIRED;
    }else{
        self.titleLabel.textColor = titleColor;
    }
    
}



#pragma mark - UITextField Delegate Methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    _oldStatus = self.status;
    [self setStatus:BodySizeCellStatus_Selected];
    
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    [self setStatus:_oldStatus];
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSString *checkNumStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    
    NSInteger size = [textField.text integerValue];
    
    if (checkNumStr.length > 0) {
        //非整型数据
        if (_oldSizeValue == 0) {
            textField.text = @"";
        }else{
            textField.text = [NSString stringWithFormat:@"%ld",_oldSizeValue];
        }
    }else if (_oldSizeValue != size){
        _oldSizeValue = size;
        if (size == 0) {
            textField.text = @"";
        }
        
        if (self.sizeChangedBlock) {
            self.sizeChangedBlock(size);
        }
    }
}

/**
 * 限制输入的尺寸在指定范围内
 **/
-(void)limitInputSize:(UITextField *)textField{
    if (textField.text.isValidString) {
        NSInteger size = [textField.text integerValue];
        NSInteger newSize = size;
        
        if (_maxSize > _minSize) {
            newSize = newSize < _minSize ? _minSize : newSize;
            newSize = newSize > _maxSize ? _maxSize : newSize;
            
            if (newSize != size) {
                textField.text = [NSString stringWithFormat:@"%ld",newSize];
            }
            
            _oldSizeValue = newSize;
            
            if (self.sizeChangedBlock) {
                self.sizeChangedBlock(newSize);
            }
        }else{
            textField.text = [NSString stringWithFormat:@"%ld",_oldSizeValue];
        }
        
    }else if (_oldSizeValue > 0){
        textField.text = [NSString stringWithFormat:@"%ld",_oldSizeValue];
    }
}

#pragma mark - Layout Custom Subviews
-(void)layoutCustomSubviews{
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = TITLE_FONT;
    self.sizeTextField = [[ZZNumberField alloc] init];
    self.sizeTextField.keyboard = KEYBOARDTYPE_NUMBER;
    self.sizeTextField.font = TITLE_FONT;
    self.sizeTextField.textAlignment = NSTextAlignmentCenter;
    self.sizeTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.sizeTextField.returnKeyType = UIReturnKeyNext;
    self.promptLabel = [[UILabel alloc] init];
    self.promptLabel.font = DETAIL_FONT;
    
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.sizeTextField];
    [self.contentView addSubview:self.promptLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.mas_offset(30);
        make.width.mas_equalTo(120);
    }];
    

    [self.promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.mas_offset(268);
    }];
    
    [self.sizeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.mas_offset(90);
        make.right.offset(-200);
        make.top.offset(4);
        make.bottom.offset(-4);
    }];
    
    _bottomLine = [[UILabel alloc] init];
    _bottomLine.backgroundColor = COLOR_TABLE_CELL_BORDER;
    [self.contentView addSubview:_bottomLine];
    
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.offset(0);
        make.height.mas_equalTo(1.0);
    }];
    
    self.sizeTextField.delegate = self;
}

@end
