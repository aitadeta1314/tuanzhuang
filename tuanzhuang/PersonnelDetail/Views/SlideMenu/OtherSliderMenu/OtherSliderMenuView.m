//
//  OtherSliderMenuView.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/8.
//  Copyright © 2018年 red. All rights reserved.
//

#import "OtherSliderMenuView.h"
#import "CenterAlignButton.h"


@interface OtherSliderMenuView()
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet CenterAlignButton *pasteButton;

@end


@implementation OtherSliderMenuView


-(void)awakeFromNib{
    [super awakeFromNib];
    
    [self bringSubviewToFront:self.stackView];
}

-(void)reloadData{
    [self configCancleButtonStatus];
    
    [self configCopyButtonStatus];
    [self configRemarkButtonStatus];
    [self configSignedButtonStatus];
    
    [self configCopyOtherButtonStatus];
    
    [self configHistoryButtonStatus];
}

-(IBAction)menuButtonTapAction:(id)sender{
    
    UIButton *button = (UIButton *)sender;
    
    NSInteger tag = button.tag;
    
    if (self.tapBlock) {
        self.tapBlock(tag);
    }
    
}

#pragma mark - Private Helper Methods
-(void)configCopyButtonStatus{
    UIButton *button = [self.stackView viewWithTag:SLIDER_BUTTON_ITEM_TYPE_COPY];
    
    if ([CommonData shareCommonData].personModelForCoping == self.personModel) {
        button.selected = YES;
    }else{
        button.selected = NO;
    }
}

-(void)configPasteButtonStatus{
    UIButton *button = [self.stackView viewWithTag:SLIDER_BUTTON_ITEM_TYPE_PASTER];
    
    if ([CommonData shareCommonData].personModelForCoping && [CommonData shareCommonData].personModelForCoping != self.personModel) {
        button.enabled = YES;
    }else{
        button.enabled = NO;
    }
}


-(void)configRemarkButtonStatus{
    UIButton *button = [self.stackView viewWithTag:SLIDER_BUTTON_ITEM_TYPE_REMARK];
    
    if (self.personModel.remark) {
        button.selected = YES;
    }else{
        button.selected = NO;
    }
}

-(void)configSignedButtonStatus{
    UIButton *button = [self.stackView viewWithTag:SLIDER_BUTTON_ITEM_TYPE_SIGNED];
    
    if (self.personModel.sign) {
        button.selected = YES;
    }else{
        button.selected = NO;
    }
}

-(void)configHistoryButtonStatus{
    UIButton *button = [self.stackView viewWithTag:SLIDER_BUTTON_ITEM_TYPE_HISTORY];
    
    if (self.personModel.history) {
        button.selected = YES;
    }else{
        button.selected = NO;
    }
}

-(void)configCopyOtherButtonStatus{
    
    UIButton *copyOtherButton = [self.stackView viewWithTag:SLIDER_BUTTON_ITEM_TYPE_COPY_OTHER];
    
    if ([[CommonData shareCommonData] copiedOtherContainPerson:self.personModel]) {
        copyOtherButton.selected = YES;
    }else{
        copyOtherButton.selected = NO;
    }
}

-(void)configCancleButtonStatus{
    
    if (self.showCancelButton) {
        self.pasteButton.tag = SLIDER_BUTTON_ITEM_TYPE_CANCEL_PASTER;
        self.pasteButton.selected = YES;
    }else{
        self.pasteButton.tag = SLIDER_BUTTON_ITEM_TYPE_PASTER;
        self.pasteButton.selected = NO;
        
        [self configPasteButtonStatus];
    }
}

@end
