//
//  SeasonCountCollectionViewCell.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/4.
//  Copyright © 2018年 red. All rights reserved.
//

#import "SeasonCountCollectionViewCell.h"


#define COLOR_BUTTON_OPEN_STATUS    skyColor
#define COLOR_BUTTON_CLOSE_STATUS   RGBColor(200, 200, 200)

@interface SeasonCountCollectionViewCell()<PPNumberButtonDelegate>

@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet PPNumberButton *winterButton;
@property (weak, nonatomic) IBOutlet PPNumberButton *summerButton;

@end

@implementation SeasonCountCollectionViewCell

-(void)awakeFromNib{
    [super awakeFromNib];
    
    self.winterButton.delegate = self;
    self.summerButton.delegate = self;
    
    [self setCategoryButtonBackgroundColorByStatus];
}

#pragma mark - Public Methods

-(void)configCategoryCode:(NSString *)code summerCount:(NSInteger)sCount winterCount:(NSInteger)wCount{
    self.categoryCode = code;
    self.summerCount = sCount;
    self.winterCount = wCount;
}

#pragma mark - Setting Methods
-(void)setIsOpen:(BOOL)isOpen{
    _isOpen = isOpen;
    
    [self setCategoryButtonBackgroundColorByStatus];
}

-(void)setCategoryCode:(NSString *)categoryCode{
    _categoryCode = categoryCode;
    
    [self.categoryButton setTitle:categoryCode forState:UIControlStateNormal];
}

-(void)setSummerCount:(NSInteger)summerCount{
    self.summerButton.currentNumber = summerCount;
}

-(void)setWinterCount:(NSInteger)winterCount{
    self.winterButton.currentNumber = winterCount;
}

-(void)setMaxCount:(NSInteger)maxCount{
    
    _maxCount = maxCount;
    
    self.summerButton.maxValue = maxCount;
    self.winterButton.maxValue = maxCount;
}

- (void)pp_numberButton:(PPNumberButton *)numberButton number:(NSInteger)number increaseStatus:(BOOL)increaseStatus{
    
    NSInteger diffCount = self.maxCount - number;
    if (self.summerButton == numberButton) {
        self.winterCount = diffCount;
    }else if (self.winterButton == numberButton){
        self.summerCount = diffCount;
    }
    
    if (self.changedBlock) {
        self.changedBlock(self.categoryCode, self.summerCount, self.winterCount);
    }
}

#pragma mark - Getter Methods
-(NSInteger)summerCount{
    return self.summerButton.currentNumber;
}

-(NSInteger)winterCount{
    return self.winterButton.currentNumber;
}

-(IBAction)categoryButtonTapAction:(UIButton *)button{
    //当前状态为隐藏状态才能执行
    if (self.openBlock && !self.isOpen) {
        self.openBlock();
    }
}

-(void)setCategoryButtonBackgroundColorByStatus{
    UIColor *bgColor = COLOR_BUTTON_CLOSE_STATUS;
    
    if (self.isOpen) {
        bgColor = COLOR_BUTTON_OPEN_STATUS;
    }
    
    self.categoryButton.backgroundColor = bgColor;
}


@end
