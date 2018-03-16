//
//  ClothesSizeInputView.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/8.
//  Copyright © 2018年 red. All rights reserved.
//

#import "ClothesSizeInputView.h"

@interface ClothesSizeInputView()<PPNumberButtonDelegate>
@property (weak, nonatomic) IBOutlet PPNumberButton *summerButton;
@property (weak, nonatomic) IBOutlet PPNumberButton *winterButton;

@end

@implementation ClothesSizeInputView

-(void)awakeFromNib{
    [super awakeFromNib];
    self.summerButton.delegate = self;
    self.winterButton.delegate = self;
    self.summerButton.displayZeroNumber = NO;
    self.winterButton.displayZeroNumber = NO;
    
}

#pragma mark - Public Methods
-(void)reset{
    self.summerSize = 0;
    self.winterSize = 0;
    self.minSummerSize = 0;
    self.maxSummerSize = 0;
    self.minWinterSize = 0;
    self.maxWinterSize = 0;
}

-(void)setSummerSize:(NSInteger)sSize winterSize:(NSInteger)wSize minSize:(NSInteger)beginSize maxSize:(NSInteger)endSize{
    
    self.minSummerSize = 0;
    self.maxSummerSize = NSIntegerMax;
    self.minWinterSize = 0;
    self.maxWinterSize = NSIntegerMax;
    
    self.summerSize = sSize;
    self.winterSize = wSize;
}

#pragma mark - Setter Methods
-(void)setSummerSize:(NSInteger)summerSize{
    self.summerButton.currentNumber = summerSize;
}

-(void)setWinterSize:(NSInteger)winterSize{
    self.winterButton.currentNumber = winterSize;
}

-(void)setMinSummerSize:(NSInteger)minSummerSize{
    _minSummerSize = minSummerSize;
    self.summerButton.minValue = minSummerSize;
}

-(void)setMaxSummerSize:(NSInteger)maxSummerSize{
    _maxSummerSize = maxSummerSize;
    self.summerButton.maxValue = maxSummerSize;
    
    if (maxSummerSize == 0) {
        self.summerButton.editing = NO;
    }else{
        self.summerButton.editing = YES;
    }
}

-(void)setMinWinterSize:(NSInteger)minWinterSize{
    _minWinterSize = minWinterSize;
    self.winterButton.minValue = minWinterSize;
}

-(void)setMaxWinterSize:(NSInteger)maxWinterSize{
    _maxWinterSize = maxWinterSize;
    self.winterButton.maxValue = maxWinterSize;
    
    if (maxWinterSize == 0) {
        self.winterButton.editing = NO;
    }else{
        self.winterButton.editing = YES;
    }
}

#pragma mark - Getter Methods

-(NSInteger)summerSize{
    return self.summerButton.currentNumber;
}

-(NSInteger)winterSize{
    return self.winterButton.currentNumber;
}

#pragma mark - PPNumberButton Delegate Methods
-(void)pp_numberButton:(PPNumberButton *)numberButton number:(NSInteger)number increaseStatus:(BOOL)increaseStatus{
    
    if (self.changedBlock) {
        self.changedBlock(self.summerSize, self.winterSize);
    }
    
}

@end
