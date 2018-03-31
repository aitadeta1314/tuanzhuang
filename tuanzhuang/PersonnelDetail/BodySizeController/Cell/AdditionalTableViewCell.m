//
//  AdditionalTableViewCell.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/3/28.
//  Copyright © 2018年 red. All rights reserved.
//

#import "AdditionalTableViewCell.h"
#import "PPNumberButton.h"
#import "AdditionModel+Helper.h"
#import "CategoryAddRangeModel.h"
#import "NSManagedObject+Coping.h"
#import "CategoryModel+Helper.h"

typedef enum : NSUInteger {
    ADDITION_SLEEVE     = 1001,     //袖长
    ADDITION_SHOULDER   = 1002,     //肩宽
    ADDITION_CLOTHES    = 1003,     //后衣长
    ADDITION_WAIST      = 1004,     //腰围
    ADDITION_PANTS      = 1005,     //裤长
    ADDITION_SKIRT      = 1006,     //裙长
    ADDITION_INCREASE   = 1007,     //加放量
    ADDITION_PLEAT      = 1008      //褶皱按钮
} ADDITION_ELEMENT;

#define BUTTON_BACKGROUND_COLOR [UIColor colorWithRed:0.286 green:0.565 blue:0.886 alpha:1.00]
#define SEASON_BUTTON_BACKGROUND_COLOR  RGBColor(200, 200, 200)

static const NSTimeInterval DELAY_HIDDEN_PICKERVIEW = 1.0f;

static const CGFloat TOP_PADDING = 20.0f;
static const CGFloat HEIGHT_ELEMENT = 50.0f;

@interface AdditionalTableViewCell()<UITextFieldDelegate,PPNumberButtonDelegate,UIPickerViewDelegate,UIPickerViewDataSource>{
    
    NSInteger _oldValue;
    
}

@property(nonatomic,assign) IBOutlet UILabel *titleLabel;        //品类名

//加放量
@property (weak, nonatomic) IBOutlet UITextField *increaseTextField;

//夏季
@property(nonatomic,assign) IBOutlet UIButton *summerButton;

//冬季
@property(nonatomic,assign) IBOutlet UIButton *winterButton;

@property (weak, nonatomic) IBOutlet UIButton *pleatButton;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

//西裤：无褶\单褶\双褶
@property(nonatomic,assign) CLOTHES_PLEAT_TYPE pleatType;

//冬季、夏季
@property(nonatomic,assign) SEASON_TYPE seasonType;

//加放量的频率与范围
@property(nonatomic,strong) NSArray *rangeArray;

@property(nonatomic,strong) NSArray *tempRangeArray;

@end

@implementation AdditionalTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self setupCustomSubViews];
}

-(void)setupCustomSubViews{
    //config size input TextField
    _increaseTextField.borderStyle = UITextBorderStyleNone;
    _increaseTextField.textAlignment = NSTextAlignmentCenter;
    _increaseTextField.layer.borderColor = RGBColor(204, 204, 204).CGColor;
    _increaseTextField.layer.borderWidth = 0.5f;
    _increaseTextField.layer.cornerRadius = 5.0f;
    _increaseTextField.delegate = self;
    
    //setup pickerView
    self.pickerView.hidden = YES;
    
    //PPNumberButton Delegate
    [self setupAllNumberButton];
    
    self.pleatButton.layer.cornerRadius = 5.0;
    self.pleatButton.layer.masksToBounds = YES;
    
    self.summerButton.layer.cornerRadius = 5.0;
    self.summerButton.layer.masksToBounds = YES;
    
    self.winterButton.layer.cornerRadius = 5.0;
    self.winterButton.layer.masksToBounds = YES;
}

#pragma mark - Public Methods
-(void)setTitle:(NSString *)title andAddtionModel:(AdditionModel *)addtion{
    self.addtionModel = addtion;
    
    //显示对应的元素
    [self layoutSubviewsByAddition:addtion];
    
    //根据品类确定提示“袖长”、“短袖长”
    [self setupSleevePromptLabelByCategoryCode:addtion.category.cate];
    
    //获取加放量范围
    [self configIncreaseRangeByAddition:addtion];
    
    //设置褶皱按钮状态
    if (PERSON_GENDER_WOMEN == addtion.category.personnel.gender) {
        [self configEnablePleatButton:NO];
    }else{
        [self configEnablePleatButton:YES];
    }
    
    self.pleatType = addtion.value_pleat;
    self.titleLabel.text = title;
    
    [self configNumberButtonsFromAddition:addtion];
    self.increaseTextField.text = [NSString stringWithFormat:@"%d",addtion.increase];
}


#pragma mark - Propery Setting Methods

-(void)setPleatType:(CLOTHES_PLEAT_TYPE)pleatType{
    _pleatType = pleatType;
    
    NSString *title;
    
    switch (_pleatType) {
        case CLOTHES_PLEAT_TYPE_NONE:
            title = STRING_CLOTHES_NO_PLEAT;
            break;
        case CLOTHES_PLEAT_TYPE_SINGLE:
            title = STRING_CLOTHES_SINGLE_PLEAT;
            break;
        case CLOTHES_PLEAT_TYPE_DOUBLE:
            title = STRING_CLOTHES_DOUBLE_PLEAT;
            break;
            
        default:
            break;
    }
    
    [self.pleatButton setTitle:title forState:UIControlStateNormal];
}

-(void)setSeasonType:(SEASON_TYPE)seasonType{
    
    _seasonType = seasonType;
    
    switch (_seasonType) {
        case SEASON_TYPE_NONE:{
            self.summerButton.backgroundColor = SEASON_BUTTON_BACKGROUND_COLOR;
            self.winterButton.backgroundColor = SEASON_BUTTON_BACKGROUND_COLOR;
            break;
        }
        case SEASON_TYPE_SUMMER:
        {
            self.summerButton.backgroundColor = COLOR_PERSION_INFO_SELECTED;
            self.winterButton.backgroundColor = SEASON_BUTTON_BACKGROUND_COLOR;
            break;
        }
        case SEASON_TYPE_WINTER:
        {
            self.summerButton.backgroundColor = SEASON_BUTTON_BACKGROUND_COLOR;
            self.winterButton.backgroundColor = COLOR_PERSION_INFO_SELECTED;
            break;
        }
            
        default:
            break;
    }
    
}


#pragma mark - Layout After Config Data

/**
 * 根据品类，显示对应的元素
 */
-(void)layoutSubviewsByAddition:(AdditionModel *)addition{
    
    BOOL hidden;
    
    hidden = addition.hasSleeveLong ? NO : YES;
    [self setHidden:hidden byAdditionType:ADDITION_SLEEVE];
    
    hidden = addition.hasShoulderWidth ? NO : YES;
    [self setHidden:hidden byAdditionType:ADDITION_SHOULDER];
    
    hidden = addition.hasClothesLong ? NO : YES;
    [self setHidden:hidden byAdditionType:ADDITION_CLOTHES];
    
    hidden = addition.hasWaist ? NO : YES;
    [self setHidden:hidden byAdditionType:ADDITION_WAIST];
    
    hidden = addition.hasPantsLong ? NO : YES;
    [self setHidden:hidden byAdditionType:ADDITION_PANTS];
    
    hidden = addition.hasSkirtLong ? NO : YES;
    [self setHidden:hidden byAdditionType:ADDITION_SKIRT];
    
    hidden = addition.hasPleatOption ? NO : YES;
    [self setHidden:hidden byAdditionType:ADDITION_PLEAT];
}

/**
 * 根据品类的设置“袖长”、“短袖长”标签
 **/
-(void)setupSleevePromptLabelByCategoryCode:(NSString *)categoryCode{
    
    UILabel *sleeveLabel;
    for (UIView *subview in self.contentView.subviews) {
        if (subview.tag == ADDITION_SLEEVE && [subview isKindOfClass:[UILabel class]]) {
            sleeveLabel = (UILabel *)subview;
            break;
        }
    }
    
    if (sleeveLabel) {
        
        if ([categoryCode isEqualToString:Category_Code_CD]) {
            sleeveLabel.text = @"（短袖长）";
        }else{
            sleeveLabel.text = @"（袖长）";
        }
        
    }
    
}

-(void)configEnablePleatButton:(BOOL)enable{
    if (enable) {
        self.pleatButton.backgroundColor = BUTTON_BACKGROUND_COLOR;
        self.pleatButton.enabled = YES;
    }else{
        self.pleatButton.backgroundColor = SEASON_BUTTON_BACKGROUND_COLOR;
        self.pleatButton.enabled = NO;
    }
}

/**
 * 配置加放量的范围
 **/
-(void)configIncreaseRangeByAddition:(AdditionModel *)addition{
    
    //获取加放量范围
    CategoryAddRangeModel *rangeModel = [CategoryAddRangeModel rangeModelByCategory:addition.category.cate withPleatType:addition.value_pleat];
    
    NSArray *rangeArray;
    
    if (PERSON_GENDER_MAN == addition.category.personnel.gender) {
        rangeArray = rangeModel.manRangeArray;
    }else{
        rangeArray = rangeModel.womenRangeArray;
    }
    
    self.rangeArray = rangeArray;
    
    //没有加放量范围设置状态
    if ([rangeArray count] == 0) {
        [self enableAllNumberButton:NO];
        
        //季节按钮无效
        self.seasonType = SEASON_TYPE_NONE;
        self.winterButton.enabled = NO;
        self.summerButton.enabled = NO;
    }else{
        [self enableAllNumberButton:YES];
        
        self.seasonType = addition.season;
        self.winterButton.enabled = YES;
        self.summerButton.enabled = YES;
    }
}

#pragma mark - UITextField Delegate Methods
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if ([self.rangeArray count]>0) {
        [self showPickerView:YES];
    }
    
    return NO;
}

#pragma mark - UIPikerView DataSource Methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.tempRangeArray count];
}

#pragma mark - UIPickerView Delegate Methods

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSString *title = [NSString stringWithFormat:@"%@",self.tempRangeArray[row]];
    
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    self.increaseTextField.text = self.tempRangeArray[row];
    
    [self performSelector:@selector(hiddenPickerView) withObject:nil afterDelay:DELAY_HIDDEN_PICKERVIEW];
}


#pragma mark - PPNumberButton Delegate Methods
-(void)pp_numberButton:(PPNumberButton *)numberButton number:(NSInteger)number increaseStatus:(BOOL)increaseStatus{
    [self valueChangedAction];
}

#pragma mark - PPNumberButton Private Helper Methods
/**
 * 从模型配置界面数据
 **/
-(void)configNumberButtonsFromAddition:(AdditionModel *)addition{
    
    for (UIView *subview in self.contentView.subviews) {
        if ([subview isKindOfClass:[PPNumberButton class]]) {
            PPNumberButton *button = (PPNumberButton *)subview;
            
            NSInteger value = [[addition valueForKey:[self getAdditionKey:button.tag]] integerValue];
            button.currentNumber = value;
            
        }
    }
    
}

/**
 * 将界面数据赋值到模型
 */
-(void)configAdditionFromNumberButtons:(AdditionModel *)addition{
    
    for (UIView *subview in self.contentView.subviews) {
        if ([subview isKindOfClass:[PPNumberButton class]]) {
            PPNumberButton *button = (PPNumberButton *)subview;
            [addition setValue:@(button.currentNumber) forKey:[self getAdditionKey:button.tag]];
        }
    }
    
}

/**
 * 获取对应的模型的KEY
 */
-(NSString *)getAdditionKey:(ADDITION_ELEMENT)element{
    NSString *key;
    switch (element) {
        case ADDITION_SLEEVE:
            key = @"value_sleeve";
            break;
        case ADDITION_CLOTHES:
            key = @"value_clothes";
            break;
        case ADDITION_SHOULDER:
            key = @"value_shoulder";
            break;
        case ADDITION_WAIST:
            key = @"value_waist";
            break;
        case ADDITION_PANTS:
            key = @"value_pants";
            break;
        case ADDITION_SKIRT:
            key = @"value_skirt";
            break;
        case ADDITION_PLEAT:
            key = @"value_pleat";
            break;
        case ADDITION_INCREASE:
            key = @"increase";
            break;
            
        default:
            break;
    }
    
    return key;
}


-(void)setupAllNumberButton{
    for (UIView *subview in self.contentView.subviews) {
        
        if ([subview isKindOfClass:[PPNumberButton class]]) {
            PPNumberButton *button = (PPNumberButton *)subview;
            button.delegate = self;
            button.minValue = 0;
            button.maxValue = NSIntegerMax;
            button.displayZeroNumber = NO;
            button.currentNumber = 0;
        }
        
    }
}

-(void)enableAllNumberButton:(BOOL)enable{
    
    for (UIView *subview in self.contentView.subviews) {
        
        if ([subview isKindOfClass:[PPNumberButton class]]) {
            PPNumberButton *button = (PPNumberButton *)subview;
            
            if (enable) {
                button.maxValue = NSIntegerMax;
                button.editing = YES;
            }else{
                button.maxValue = 0;
                button.editing = NO;
            }
            
        }
        
    }
    
}

-(PPNumberButton *)getNumberButton:(ADDITION_ELEMENT)element{
    
    PPNumberButton *button;
    
    for (UIView *subview in self.contentView.subviews) {
        if (subview.tag == element && [subview isKindOfClass:[PPNumberButton class]]) {
            button = (PPNumberButton *)subview;
            break;
        }
    }
    
    return button;
}

/**
 * 设置界面元素显示或隐藏
 */
-(void)setHidden:(BOOL)hidden byAdditionType:(ADDITION_ELEMENT)element{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag == %@",@(element)];
    
    NSArray *subviewArray = [self.contentView.subviews filteredArrayUsingPredicate:predicate];
    
    for (UIView *subview in subviewArray) {
        
        subview.hidden = hidden;
        
        //设置高度
        for (NSLayoutConstraint *constraint in subview.constraints) {
            
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                if (hidden) {
                    constraint.constant = 0;
                }else{
                    constraint.constant = HEIGHT_ELEMENT;
                }
            }
        }
    }
    
    //设置顶部距离
    predicate = [NSPredicate predicateWithFormat:@"identifier == %@",[NSString stringWithFormat:@"%ld",element]];
    NSArray *topConstraints = [self.contentView.constraints filteredArrayUsingPredicate:predicate];
    
    for (NSLayoutConstraint *constraint in topConstraints) {
        if (hidden) {
            constraint.constant = 0;
        }else{
            constraint.constant = TOP_PADDING;
        }
    }
  
}

#pragma mark - Action Methods

-(void)valueChangedAction{
    
    CategoryModel *category = self.addtionModel.category;
    
    NSMutableArray *changedAdditions = [NSMutableArray array];
    
    if (self.seasonType != self.addtionModel.season) {
        //季节变更
        AdditionModel *seasonAddition = [category getAdditionItemBySeason:self.seasonType];
        
        if (seasonAddition) {
            [self.addtionModel copyAttributesFrom:seasonAddition];
        }else{
            //重置addition 数据
            [self.addtionModel reset];
            self.addtionModel.season = self.seasonType;
        }
        
        [changedAdditions addObject:self.addtionModel];
        
    }else{
        
        self.addtionModel.increase = [self.increaseTextField.text integerValue];
        self.addtionModel.season = self.seasonType;
        
        [self configAdditionFromNumberButtons:self.addtionModel];
        [self configNumberButtonsFromAddition:self.addtionModel];
        
        //更改褶皱，修改加放量默认值
        if (self.addtionModel.value_pleat != self.pleatType) {
            self.addtionModel.value_pleat = self.pleatType;
            [self.addtionModel resetIncreaseByPleatOption];
        }
        
        //同步其他的加放量数据
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"season == %d",self.addtionModel.season];
        NSSet *additionSet = [category.addition filteredSetUsingPredicate:predicate];
        
        for (AdditionModel *model in additionSet) {
            if (model != self.addtionModel) {
                [model copyAttributesFrom:self.addtionModel];
            }
            [changedAdditions addObject:model];
        }
    }
    
    if (self.changedBlock) {
        self.changedBlock(changedAdditions);
    }
}


-(IBAction)pleatButtonAction:(id)object{
    NSInteger nextState = (self.pleatType + 1)%3;
    
    [self setPleatType:nextState];
    
    [self valueChangedAction];
}

-(IBAction)didSelectSeasonButton:(id)sender{
    
    if (self.winterButton == sender) {
        self.seasonType = SEASON_TYPE_WINTER;
    }else{
        self.seasonType = SEASON_TYPE_SUMMER;
    }
    
    [self valueChangedAction];
    
}

#pragma mark - Picker Show OR Hidden
-(void)hiddenPickerView{
    [self showPickerView:NO];
}

-(void)showPickerView:(BOOL)show{
    
    if (self.pickerViewDisplayBlock) {
        self.pickerViewDisplayBlock(show);
    }
    
    self.tempRangeArray = self.rangeArray;
    [self.pickerView reloadAllComponents];
    
    NSInteger increase = [self.increaseTextField.text integerValue];
    
    if (show) {
        
        _oldValue = increase;
        
        self.pickerView.hidden = NO;
        self.pickerView.alpha = 0;
        
        NSInteger index = [self getRangeIndexByValue:increase];
        [self.pickerView selectRow:0 inComponent:0 animated:NO];
        
        [UIView animateWithDuration:0.05 animations:^{
            self.increaseTextField.alpha = 0;
            self.pickerView.alpha = 1;
        } completion:^(BOOL finished) {
            [self.pickerView selectRow:index inComponent:0 animated:YES];
            [self performSelector:@selector(hiddenPickerView) withObject:nil afterDelay:DELAY_HIDDEN_PICKERVIEW];
        }];
        
    }else{
        
        weakObjc(self);
        [UIView animateWithDuration:0.05 animations:^{
            self.increaseTextField.alpha = 1;
            self.pickerView.alpha = 0;
        } completion:^(BOOL finished) {
            self.pickerView.hidden = YES;
            
            if (_oldValue != increase) {
                [weakself valueChangedAction];
            }
            
        }];
        
    }
}

/**
 * 获取加放量数值所在范围的位置
 */
-(NSInteger)getRangeIndexByValue:(NSInteger)value{
    
    NSInteger index = 0;
    
    for (int i=0; i<[self.tempRangeArray count]; i++) {
        if (value == [self.tempRangeArray[i] integerValue]) {
            index = i;
            break;
        }
    }
    return index;
}

#pragma mark - Class Methods
+(CGFloat)getCellHeightByAddition:(AdditionModel *)additional{
    CGFloat cellHeight  = TOP_PADDING * 2 + HEIGHT_ELEMENT;
    
    if (additional.hasClothesLong) {
        cellHeight += HEIGHT_ELEMENT + TOP_PADDING;
    }
    
    if (additional.hasShoulderWidth) {
        cellHeight += HEIGHT_ELEMENT + TOP_PADDING;
    }
    
    if (additional.hasSleeveLong) {
        cellHeight += HEIGHT_ELEMENT + TOP_PADDING;
    }
    
    if (additional.hasWaist) {
        cellHeight += HEIGHT_ELEMENT + TOP_PADDING;
    }
    
    if (additional.hasPantsLong) {
        cellHeight += HEIGHT_ELEMENT + TOP_PADDING;
    }
    
    if (additional.hasSkirtLong) {
        cellHeight += HEIGHT_ELEMENT + TOP_PADDING;
    }
    
    if (additional.hasPleatOption) {
        cellHeight += HEIGHT_ELEMENT + TOP_PADDING;
    }
    
    return cellHeight;
}



@end
