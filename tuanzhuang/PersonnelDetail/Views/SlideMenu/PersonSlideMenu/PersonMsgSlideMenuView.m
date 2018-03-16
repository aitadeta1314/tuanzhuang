//
//  PersonMsgSlideMenuView.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/21.
//  Copyright © 2017年 red. All rights reserved.
//

#import "PersonMsgSlideMenuView.h"
#import "GetLetter.h"

typedef NS_ENUM(NSUInteger, TextFieldStyle) {
    TextFieldStyle_Border,
    TextFieldStyle_Background
};

#define TEXT_COLOR_TITLE [UIColor blackColor]
#define TEXT_COLOR_CONTENT [UIColor whiteColor]

#define TEXT_FONT_TITLE [UIFont systemFontOfSize:18.0]
#define TEXT_FONT_CONTENT [UIFont systemFontOfSize:16.0]

static const CGFloat CORNER_RADIUS = 5.0;
static const CGFloat Seperate_Title = 20.0;
static const CGFloat Seperate_Content = 10.0;
static const CGFloat Sperate_Unit = 8.0;

static const CGFloat Line_Height = 40.0;

static const CGFloat Line_Seperate = 18.0;

static const CGFloat Content_Padding_Left = Slide_Content_Padding_Left + 20.0f;

@interface PersonMsgSlideMenuView()<UITextFieldDelegate>{

    UILabel *_companyTitleLabel;
    UILabel *_nameTitleLabel;
    UILabel *_departmentTitleLabel;
    UILabel *_sexTitleLabel;
    UILabel *_heightTitleLabel;
    UILabel *_heightUnitLabel;
    UILabel *_weightTitleLabel;
    UILabel *_weightUnitLabel;
}

@property(nonatomic,strong) UILabel *companyLabel;

@property(nonatomic,strong) ZZNumberField *nameTextField;

@property(nonatomic,strong) ZZNumberField *departmentTextField;

@property(nonatomic,strong) UIButton    *sexButton;

@property(nonatomic,strong) UIButton    *mtmButton;

@property(nonatomic,strong) ZZNumberField *heightField;

@property(nonatomic,strong) ZZNumberField *weightField;


@end

@implementation PersonMsgSlideMenuView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self addAllSubviews];
        [self layoutCustomSubviews];
    }
    
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.isNew) {
        self.nameTextField.hidden = NO;
        _nameTitleLabel.hidden = NO;
        
        self.sexButton.userInteractionEnabled = YES;
        self.sexButton.backgroundColor = [UIColor whiteColor];
        self.sexButton.layer.borderColor = COLOR_PERSION_INFO_SELECTED.CGColor;
        self.sexButton.layer.borderWidth = 1.0;
        [self.sexButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        self.departmentTextField.userInteractionEnabled = YES;
        self.departmentTextField.backgroundColor = [UIColor whiteColor];
        self.departmentTextField.layer.borderColor = COLOR_PERSION_INFO_SELECTED.CGColor;
        self.departmentTextField.layer.borderWidth = 1.0;
        self.departmentTextField.textColor = [UIColor blackColor];
    }else{
        self.nameTextField.hidden = YES;
        _nameTitleLabel.hidden = YES;
        self.sexButton.userInteractionEnabled = NO;
        self.departmentTextField.userInteractionEnabled = NO;
    }
}


#pragma mark - Public Methods
-(void)reloadData{
    
    self.nameTextField.text = self.personModel.name;
    
    self.companyLabel.text = self.companyModel.companyname;
    
    self.departmentTextField.text = self.personModel.department;
    
    NSString *sexStr = self.personModel.gender == 0 ? @"女" : @"男";
    [self.sexButton setTitle:sexStr forState:UIControlStateNormal];
    
    [self setMTMButtonSelected:self.personModel.mtm];
    
    if (self.personModel.height > 0) {
        self.heightField.text = [NSString stringWithFormat:@"%.1f",self.personModel.height];
    }else{
        self.heightField.text = @"";
    }
    
    if (self.personModel.weight > 0) {
        self.weightField.text = [NSString stringWithFormat:@"%.1f",self.personModel.weight];
    }else{
        self.weightField.text = @"";
    }
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - Privagte Layout Methods
-(void)layoutCustomSubviews{
    
    [self layoutCompanySubviews];
    [self layoutNameSubviews];
    [self layoutDepartmentSubviews];
    [self layoutSexSubviews];
    [self layoutHeightSubviews];
    [self layoutWeightSubviews];
    [self layoutMTMButtonSubviews];
    
}

-(void)layoutCompanySubviews{
    
    weakObjc(self);
    
    [_companyTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(Content_Padding_Left);
        make.centerY.equalTo(weakself).with.offset(-Line_Height/2 - Line_Seperate/2);
    }];
    
    [self.companyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_companyTitleLabel);
        make.left.equalTo(_companyTitleLabel.mas_right).with.offset(Seperate_Content);
        make.width.mas_equalTo(530);
        make.height.mas_equalTo(Line_Height);
    }];
}

-(void)layoutNameSubviews{
    
    weakObjc(self);
    
    [_nameTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(weakself.companyLabel.mas_right).with.offset(Seperate_Title);
        make.centerY.equalTo(self.companyLabel);
    }];
    
    [self.nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameTitleLabel.mas_right).with.offset(Seperate_Content);
        make.centerY.equalTo(_nameTitleLabel);
        make.width.mas_equalTo(113);
        make.height.mas_equalTo(Line_Height);
    }];
    
}

-(void)layoutDepartmentSubviews{
    
    weakObjc(self);
    
    [_departmentTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(Content_Padding_Left);
        make.centerY.equalTo(weakself).with.offset(Line_Height/2 + Line_Seperate/2);
    }];
    
    [_departmentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_departmentTitleLabel);
    make.left.equalTo(_departmentTitleLabel.mas_right).with.offset(Seperate_Content);
        make.width.mas_equalTo(122);
        make.height.mas_equalTo(Line_Height);
    }];
}

-(void)layoutSexSubviews{
    
    [_sexTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_departmentTitleLabel);
        make.left.equalTo(_departmentTextField.mas_right).with.offset(Seperate_Title);
    }];
    
    [self.sexButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_sexTitleLabel);
        make.left.equalTo(_sexTitleLabel.mas_right).with.offset(Seperate_Content);
        make.height.mas_equalTo(Line_Height);
        make.width.mas_equalTo(60);
    }];
}

-(void)layoutHeightSubviews{
    
    [_heightTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_departmentTitleLabel);
        make.left.equalTo(_sexButton.mas_right).with.offset(Seperate_Title);
    }];
    
    [self.heightField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_heightTitleLabel);
        make.left.equalTo(_heightTitleLabel.mas_right).with.offset(Seperate_Content);
        make.height.mas_equalTo(Line_Height);
        make.width.mas_equalTo(60);
    }];
    
    [_heightUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_heightTitleLabel);
        make.left.equalTo(_heightField.mas_right).with.offset(Sperate_Unit);
    }];
    
}

-(void)layoutWeightSubviews{
    [_weightTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_departmentTitleLabel);
        make.left.equalTo(_heightUnitLabel.mas_right).with.offset(Seperate_Title);
    }];
    
    [self.weightField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_weightTitleLabel);
        make.left.equalTo(_weightTitleLabel.mas_right).with.offset(Seperate_Content);
        make.height.mas_equalTo(Line_Height);
        make.width.mas_equalTo(60);
    }];
    
    [_weightUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_weightTitleLabel);
        make.left.equalTo(_weightField.mas_right).with.offset(Sperate_Unit);
    }];
}

-(void)layoutMTMButtonSubviews{
    
    [self.mtmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_weightUnitLabel);
        make.left.mas_equalTo(self.nameTextField.mas_left);
        make.height.mas_equalTo(Line_Height);
        make.width.mas_equalTo(113);
    }];
    
}

#pragma mark - Private Helper Methods

/**
 * 添加自视图
 **/
-(void)addAllSubviews{
    //公司
    _companyTitleLabel = [[UILabel alloc] init];
    [self addTitleLabel:_companyTitleLabel withText:@"公司"];
    
    //姓名
    _nameTitleLabel = [[UILabel alloc] init];
    [self addTitleLabel:_nameTitleLabel withText:@"姓名"];
    
    //部门
    _departmentTitleLabel = [[UILabel alloc] init];
    [self addTitleLabel:_departmentTitleLabel withText:@"部门"];
    
    //性别
    _sexTitleLabel = [[UILabel alloc] init];
    [self addTitleLabel:_sexTitleLabel withText:@"性别"];
    
    //身高
    _heightTitleLabel = [[UILabel alloc] init];
    [self addTitleLabel:_heightTitleLabel withText:@"身高"];
    
    //身高单位
    _heightUnitLabel  = [[UILabel alloc] init];
    [self addTitleLabel:_heightUnitLabel withText:@"cm"];
    
    //体重
    _weightTitleLabel  = [[UILabel alloc] init];
    [self addTitleLabel:_weightTitleLabel withText:@"体重"];
    
    //体重单位
    _weightUnitLabel = [[UILabel alloc] init];
    [self addTitleLabel:_weightUnitLabel withText:@"kg"];
    
    self.companyLabel = [[UILabel alloc] init];
    [self addContentLabel:self.companyLabel];
    self.companyLabel.font = [UIFont systemFontOfSize:18.0 weight:1];
    
    self.nameTextField = [[ZZNumberField alloc] init];
    self.nameTextField.delegate = self;
    [self addTextField:self.nameTextField];
    
    self.departmentTextField = [[ZZNumberField alloc] init];
    [self addTextField:self.departmentTextField withStyle:TextFieldStyle_Background];
    self.departmentTextField.delegate = self;
    
    self.sexButton = [[UIButton alloc] init];
    self.sexButton.backgroundColor = COLOR_PERSION_INFO_SELECTED;
    self.sexButton.layer.cornerRadius = CORNER_RADIUS;
    self.sexButton.titleLabel.textColor = [UIColor whiteColor];
    self.sexButton.titleLabel.font = TEXT_FONT_CONTENT;
    self.sexButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.sexButton addTarget:self action:@selector(sexButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.sexButton];
    
    self.heightField = [[ZZNumberField alloc] init];
    self.heightField.keyboard = KEYBOARDTYPE_NUMBER;
    self.heightField.clearsOnBeginEditing = YES;
    self.heightField.delegate = self;
    [self addTextField:self.heightField];
    
    self.weightField = [[ZZNumberField alloc] init];
    self.weightField.keyboard = KEYBOARDTYPE_NUMBER;
    self.weightField.clearsOnBeginEditing = YES;
    self.weightField.delegate = self;
    [self addTextField:self.weightField];
    
    self.mtmButton = [[UIButton alloc] init];
    [self.mtmButton setTitle:@"MTM" forState:UIControlStateNormal];
    self.mtmButton.layer.cornerRadius = CORNER_RADIUS;
    self.mtmButton.titleLabel.font = TEXT_FONT_CONTENT;
    self.mtmButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.mtmButton.layer.borderColor = COLOR_PERSION_INFO_SELECTED.CGColor;
    [self.mtmButton addTarget:self action:@selector(mtmButtonAciton:) forControlEvents:UIControlEventTouchUpInside];
    [self.mtmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.mtmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.contentView addSubview:self.mtmButton];
    
    [self setMTMButtonSelected:NO];
    
}

-(void)addTitleLabel:(UILabel *)label withText:(NSString *)text{
    label.textColor = TEXT_COLOR_TITLE;
    label.font = TEXT_FONT_TITLE;
    label.text = text;
    [self.contentView addSubview:label];
}

-(void)addContentLabel:(UILabel *)label{
    label.font = TEXT_FONT_CONTENT;
    label.textColor = TEXT_COLOR_CONTENT;
    
    label.layer.cornerRadius = CORNER_RADIUS;
    label.layer.backgroundColor = COLOR_PERSION_INFO_SELECTED.CGColor;
    label.layer.masksToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    
    [self.contentView addSubview:label];
}

-(void)addTextField:(UITextField *)textField{
    textField.borderStyle = UITextBorderStyleNone;
    textField.layer.cornerRadius = CORNER_RADIUS;
    textField.layer.borderColor = COLOR_PERSION_INFO_SELECTED.CGColor;
    textField.layer.borderWidth = 1.0;
    textField.textColor = [UIColor blackColor];
    textField.font = TEXT_FONT_CONTENT;
    textField.textAlignment = NSTextAlignmentCenter;
    
    [self.contentView addSubview:textField];
}

-(void)addTextField:(UITextField *)textField withStyle:(NSInteger)style {
    
    [self addTextField:textField];
    if (style == TextFieldStyle_Background) {
        textField.layer.borderWidth = 0;
        textField.textColor = [UIColor whiteColor];
        textField.backgroundColor = COLOR_PERSION_INFO_SELECTED;
    }
}

#pragma mark - UITextField Delegate

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (self.nameTextField == textField) {
        self.personModel.name = self.nameTextField.text;
        if (self.nameTextField.text.isValidString) {
            self.menuTitle = self.nameTextField.text;
            self.personModel.firstletter = [GetLetter firstLetterOfString:self.nameTextField.text];
        }else{
            self.menuTitle = @"输入姓名";
        }
        
    }else if (self.departmentTextField == textField){
        self.personModel.department = self.departmentTextField.text;
    }else if (self.heightField == textField){
        CGFloat height = [self.heightField.text floatValue];
        
        if (height > 0) {
            self.personModel.height = height;
            self.heightField.text = [NSString stringWithFormat:@"%.1f",self.personModel.height];
        }else{
            if (self.personModel.height > 0) {
                self.heightField.text = [NSString stringWithFormat:@"%.1f",self.personModel.height];
            }else{
                self.heightField.text = @"";
            }
        }
        
    }else if (self.weightField == textField){
        CGFloat weight = [self.weightField.text floatValue];
        
        if (weight > 0) {
            self.personModel.weight = weight;
            self.weightField.text = [NSString stringWithFormat:@"%.1f",self.personModel.weight];
        }else{
            if (self.personModel.weight > 0) {
                self.weightField.text = [NSString stringWithFormat:@"%.1f",self.personModel.weight];
            }else{
                self.weightField.text = @"";
            }
        }
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

#pragma mark - Button Action
-(void)sexButtonAction:(id)sender{
    
    NSString *sexStr = self.sexButton.titleLabel.text;
    
    if ([sexStr isEqualToString:@"男"]) {
        self.personModel.gender = 0;
    }else{
        self.personModel.gender = 1;
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [self resignFirstResponder];
    
    [self reloadData];
    
    //性别修改
    if (self.sexChanged) {
        self.sexChanged();
    }
    
}

-(void)mtmButtonAciton:(id)sender{
    
    BOOL selected = !self.mtmButton.selected;
    
    [self setMTMButtonSelected:selected];
    
    self.personModel.mtm = selected;
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
}

-(void)setMTMButtonSelected:(BOOL)selected{
    
    self.mtmButton.selected = selected;

    if (selected) {
        self.mtmButton.backgroundColor = COLOR_PERSION_INFO_SELECTED;
        self.mtmButton.layer.borderWidth = 0.0;
    }else{
        self.mtmButton.backgroundColor = [UIColor whiteColor];
        self.mtmButton.layer.borderWidth = 1.0;
    }
}




@end
