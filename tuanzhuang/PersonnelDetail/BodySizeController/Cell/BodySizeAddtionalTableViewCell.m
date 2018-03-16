//
//  BodySizeAddtionalTableViewCell.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/27.
//  Copyright © 2017年 red. All rights reserved.
//

#import "BodySizeAddtionalTableViewCell.h"
#import "AdditionModel+Helper.h"
#import "CategoryModel+Helper.h"
#import "NSManagedObject+Coping.h"

#define BUTTON_BACKGROUND_COLOR [UIColor colorWithRed:0.286 green:0.565 blue:0.886 alpha:1.00]
#define SEASON_BUTTON_BACKGROUND_COLOR  RGBColor(200, 200, 200)

static const CGFloat HEIGHT_ROW = 50.0f;

static const CGFloat PADDING_ROW = 20.0f;

static const CGFloat HEIGHT_PICKERVIEW = 100.0f;

static const NSTimeInterval DELAY_HIDDEN_PICKERVIEW = 1.0f;

#import "PPNumberButton.h"

@interface BodySizeAddtionalTableViewCell()<UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,PPNumberButtonDelegate>{
    
    NSInteger _oldValue;
    
}

@property(nonatomic,assign) IBOutlet UILabel *titleLabel;        //品类名

//袖长输入框
@property(nonatomic,assign) IBOutlet PPNumberButton *sleevesInputButton;

//后衣长输入框
@property(nonatomic,assign) IBOutlet PPNumberButton *clotheLongInputButton;

//肩宽输入框
@property(nonatomic,assign) IBOutlet PPNumberButton *shoulderInputButton;

//腰围输入框
@property(nonatomic,assign) IBOutlet PPNumberButton *waistInputButton;

//裤长
@property(nonatomic,assign) IBOutlet PPNumberButton *pantsLongInputButton;

//裙长
@property(nonatomic,assign) IBOutlet PPNumberButton *skirtLongInputButton;

//加放量的输入框
@property(nonatomic,assign) IBOutlet UITextField *valueTextFiled;

//有褶选选择按钮
@property(nonatomic,assign) IBOutlet UIButton *pleatButton;

//加放量范围选择
@property(nonatomic,strong) UIPickerView *pickerView;

//夏季
@property(nonatomic,assign) IBOutlet UIButton *summerButton;

//冬季
@property(nonatomic,assign) IBOutlet UIButton *winterButton;

@end;

@implementation BodySizeAddtionalTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    [self setupCustomSubViews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupCustomSubViews{
    //config size input TextField
    _valueTextFiled.borderStyle = UITextBorderStyleNone;
    _valueTextFiled.textAlignment = NSTextAlignmentCenter;
    _valueTextFiled.layer.borderColor = RGBColor(204, 204, 204).CGColor;
    _valueTextFiled.layer.borderWidth = 0.5f;
    _valueTextFiled.layer.cornerRadius = 5.0f;
    _valueTextFiled.delegate = self;
    
    //setup pickerView
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_valueTextFiled);
        make.width.equalTo(_valueTextFiled.mas_width);
        make.height.mas_equalTo(HEIGHT_PICKERVIEW);
    }];
    self.pickerView.hidden = YES;
    
    //PPNumberButton Delegate
    [self configPPNumberButton:self.sleevesInputButton];
    [self configPPNumberButton:self.clotheLongInputButton];
    [self configPPNumberButton:self.shoulderInputButton];
    [self configPPNumberButton:self.waistInputButton];
    [self configPPNumberButton:self.pantsLongInputButton];
    [self configPPNumberButton:self.skirtLongInputButton];
    
    self.pleatButton.layer.cornerRadius = 5.0;
    self.pleatButton.layer.masksToBounds = YES;
    
    self.summerButton.layer.cornerRadius = 5.0;
    self.summerButton.layer.masksToBounds = YES;
    
    self.winterButton.layer.cornerRadius = 5.0;
    self.winterButton.layer.masksToBounds = YES;
}

/**
 * 配置PPNumber按钮
 */
-(void)configPPNumberButton:(PPNumberButton *)button{
    button.delegate = self;
    button.minValue = 0;
    button.maxValue = NSIntegerMax;
    button.displayZeroNumber = NO;
    button.currentNumber = 0;
}

#pragma mark - Public Methods
-(void)setTitle:(NSString *)title andValue:(NSInteger)value andValueRange:(NSArray<NSNumber *> *)rangeArray{
    
    self.titleLabel.text = title;
    self.valueTextFiled.text = [NSString stringWithFormat:@"%ld",value];
    self.rangeArray = rangeArray;
    
    if ([self.rangeArray count] == 0) {
        self.pleatButton.backgroundColor = SEASON_BUTTON_BACKGROUND_COLOR;
        self.pleatButton.enabled = NO;
    }else{
        self.pleatButton.backgroundColor = BUTTON_BACKGROUND_COLOR;
        self.pleatButton.enabled = YES;
    }
    
    [self.pickerView reloadAllComponents];
}

/**
 * 赋值模型数据
 */
-(void)setTitle:(NSString *)title andAddtionModel:(AdditionModel *)addtion{
    self.addtionModel = addtion;
    
    self.pleatType = addtion.value_pleat;
    
    self.seasonType = addtion.season;
    
    self.sleevesInputButton.currentNumber = addtion.value_sleeve;
    self.clotheLongInputButton.currentNumber = addtion.value_clothes;
    self.shoulderInputButton.currentNumber = addtion.value_shoulder;
    self.waistInputButton.currentNumber = addtion.value_waist;
    self.pantsLongInputButton.currentNumber = addtion.value_pants;
    self.skirtLongInputButton.currentNumber = addtion.value_skirt;
    
    CategoryAddRangeModel *rangeModel = [CategoryAddRangeModel rangeModelByCategory:addtion.category.cate withPleatType:addtion.value_pleat];
    
    [self setTitle:title andValue:addtion.increase andValueRange:rangeModel.rangeArray];
    
    [self layoutCustomSubviewsByAddtional:addtion];
    
    [self setupSleevePromptLabelByCategoryCode:addtion.category.cate];
}

#pragma mark - Public Class Methods

+(CGFloat)getCellHeightByAddition:(AdditionModel *)additional{
    CGFloat cellHeight  = PADDING_ROW * 2 + HEIGHT_ROW;
    
    if (additional.hasClothesLong) {
        cellHeight += HEIGHT_ROW + PADDING_ROW;
    }
    
    if (additional.hasShoulderWidth) {
        cellHeight += HEIGHT_ROW + PADDING_ROW;
    }
    
    if (additional.hasSleeveLong) {
        cellHeight += HEIGHT_ROW + PADDING_ROW;
    }
    
    if (additional.hasWaist) {
        cellHeight += HEIGHT_ROW + PADDING_ROW;
    }
    
    if (additional.hasPantsLong) {
        cellHeight += HEIGHT_ROW + PADDING_ROW;
    }
    
    if (additional.hasSkirtLong) {
        cellHeight += HEIGHT_ROW + PADDING_ROW;
    }
    
    if (additional.hasPleatOption) {
        cellHeight += HEIGHT_ROW + PADDING_ROW;
    }
    
    return cellHeight;
}


#pragma mark - Property Setting Methods

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

-(void)setValue:(NSInteger)value{
    
    self.valueTextFiled.text = [NSString stringWithFormat:@"%ld",(long)value];
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

#pragma mark - Property Getting Methods

-(UIPickerView *)pickerView{
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        
        [self.contentView addSubview:_pickerView];
    }
    
    return _pickerView;
}

-(NSInteger)value{
    
    NSInteger value = 0;
    
    if (self.valueTextFiled.text.isValidString) {
        value = [self.valueTextFiled.text integerValue];
    }
    
    return value;
}


#pragma mark - Please Button Tap Action
-(IBAction)pleatButtonAction:(id)object{
    NSInteger nextState = (self.pleatType + 1)%3;
    
    [self setPleatType:nextState];
    
    [self valueChangedAction];
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
    return [self.rangeArray count];
}

#pragma mark - UIPickerView Delegate Methods

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSString *title = [NSString stringWithFormat:@"%@",self.rangeArray[row]];
    
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    self.value = [self.rangeArray[row] integerValue];
    
    [self performSelector:@selector(hiddenPickerView) withObject:nil afterDelay:DELAY_HIDDEN_PICKERVIEW];
}

#pragma mark - PPNumber Delegate Methods

-(void)pp_numberButton:(PPNumberButton *)numberButton number:(NSInteger)number increaseStatus:(BOOL)increaseStatus{
    
    [self valueChangedAction];
    
}

#pragma mark - Private Helper Methods

-(void)hiddenPickerView{
    [self showPickerView:NO];
}

-(void)showPickerView:(BOOL)show{
    
    if (self.pickerViewDisplayBlock) {
        self.pickerViewDisplayBlock(show);
    }
    
    if (show) {
        _oldValue = self.value;
        
        self.pickerView.hidden = NO;
        self.pickerView.alpha = 0;
        
        NSInteger index = [self getRangeIndexByValue:self.value];
        [self.pickerView selectRow:0 inComponent:0 animated:NO];
        
        [UIView animateWithDuration:0.05 animations:^{
            self.valueTextFiled.alpha = 0;
            self.pickerView.alpha = 1;
        } completion:^(BOOL finished) {
            [self.pickerView selectRow:index inComponent:0 animated:YES];
            [self performSelector:@selector(hiddenPickerView) withObject:nil afterDelay:DELAY_HIDDEN_PICKERVIEW];
        }];

    }else{
        
        weakObjc(self);
        [UIView animateWithDuration:0.05 animations:^{
            self.valueTextFiled.alpha = 1;
            self.pickerView.alpha = 0;
        } completion:^(BOOL finished) {
            self.pickerView.hidden = YES;
            
            if (_oldValue != self.value) {
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
    
    for (int i=0; i<[self.rangeArray count]; i++) {
        if (value == [self.rangeArray[i] integerValue]) {
            index = i;
            break;
        }
    }
    return index;
}

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
        self.addtionModel.increase = self.value;
        self.addtionModel.season = self.seasonType;
        self.addtionModel.value_clothes = self.clotheLongInputButton.currentNumber;
        self.addtionModel.value_pants = self.pantsLongInputButton.currentNumber;
        self.addtionModel.value_pleat = self.pleatType;
        self.addtionModel.value_shoulder = self.shoulderInputButton.currentNumber;
        self.addtionModel.value_skirt = self.skirtLongInputButton.currentNumber;
        self.addtionModel.value_sleeve = self.sleevesInputButton.currentNumber;
        self.addtionModel.value_waist = self.waistInputButton.currentNumber;
        
        //同步其他的加放量数据
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"season == %d",self.addtionModel.season];
        NSSet *additionSet = [category.addition filteredSetUsingPredicate:predicate];
        
        for (AdditionModel *model in additionSet) {
            if (model != self.addtionModel) {
                [model copyAttributesFrom:self.addtionModel];
                
                [changedAdditions addObject:model];
            }
        }
    }
    
    if (self.changedBlock) {
        self.changedBlock(changedAdditions);
    }
}

/**
 * 根据附加值，布局视图
 */
-(void)layoutCustomSubviewsByAddtional:(AdditionModel *)addtional{
    
    if (addtional.hasSleeveLong) {
        //显示袖长
        self.sleevesInputButton.superview.hidden = NO;
    }else{
        //隐藏袖长
        self.sleevesInputButton.superview.hidden = YES;
    }
    
    if (addtional.hasShoulderWidth) {
        //显示肩宽
        self.shoulderInputButton.superview.hidden = NO;
    }else{
        //隐藏肩宽
        self.shoulderInputButton.superview.hidden = YES;
    }
    
    if (addtional.hasClothesLong) {
        //显示后衣长
        self.clotheLongInputButton.superview.hidden = NO;
    }else{
        //隐藏后衣长
        self.clotheLongInputButton.superview.hidden = YES;
    }
    
    if (addtional.hasWaist) {
        //显示腰围
        self.waistInputButton.superview.hidden = NO;
    }else{
        //隐藏腰围
        self.waistInputButton.superview.hidden = YES;
    }
    
    if (addtional.hasPantsLong) {
        //显示裤长
        self.pantsLongInputButton.superview.hidden = NO;
    }else{
        //隐藏裤长
        self.pantsLongInputButton.superview.hidden = YES;
    }
    
    if (addtional.hasSkirtLong) {
        //显示裙长
        self.skirtLongInputButton.superview.hidden = NO;
    }else{
        //隐藏裙长
        self.skirtLongInputButton.superview.hidden = YES;
    }
    
    if (addtional.hasPleatOption) {
        //显示皱褶按钮
        self.pleatButton.superview.hidden = NO;
    }else{
        //隐藏皱褶按钮
        self.pleatButton.superview.hidden = YES;
    }
}

/**
 * 根据品类的设置“袖长”、“短袖长”标签
 **/
-(void)setupSleevePromptLabelByCategoryCode:(NSString *)categoryCode{
    
    UILabel *sleeveLabel;
    
    for (UIView *subview in self.sleevesInputButton.superview.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
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

#pragma mark - Season Button Selected Action
-(IBAction)didSelectSeasonButton:(id)sender{
    
    if (self.winterButton == sender) {
        self.seasonType = SEASON_TYPE_WINTER;
    }else{
        self.seasonType = SEASON_TYPE_SUMMER;
    }
    
    [self valueChangedAction];
    
}
@end
