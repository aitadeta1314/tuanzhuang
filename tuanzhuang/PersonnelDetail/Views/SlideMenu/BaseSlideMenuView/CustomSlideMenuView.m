//
//  CustomSlideMenuView.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2017/12/20.
//  Copyright © 2017年 red. All rights reserved.
//

#import "CustomSlideMenuView.h"

#define COLOR_MENU_TEXT [UIColor whiteColor]

#define CENTER_X_HIDDEN      (-CGRectGetWidth(self.bounds)/2 + Slide_Menu_Width)
#define CENTER_X_SHOW        (CGRectGetWidth(self.bounds)/2)

static const CGFloat Left_Line_Width = 20.0;

static const CGFloat duration_animation = 0.25;

static const NSInteger Tag_For_BackgroundView = 100001;

static NSString * const KEY_ANIMATION_SHOW_HIDDEN = @"key_animation_show_hidden";

@interface CustomSlideMenuView(){
    CALayer *_borderLayer;
    CALayer *_lineLayer;
    CAShapeLayer *_maskLayer;
    
    UIButton *_menuButton;
    
    CGPoint _oldTranslatePoint;
}

@end

@implementation CustomSlideMenuView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    
    return self;
    
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

-(void)setup{
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.contentView];
    [self layoutBaseSubviews];
    self.isOpen = NO;
    [self triggerSliderMenu:NO withAnimation:NO];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self layoutBaseSubviews];
}

-(void)dealloc{
    showMenuCount = 0;
}


-(void)layoutBaseSubviews{
    
    self.contentView.frame = self.bounds;
    
    [self setLeftLineLayer];
    [self setRightConerByMaskLayer];
    [self setBorderLayer];
    
    [self layoutMenuButton];
}


/**
 * 设置左边的竖线
 */
-(void)setLeftLineLayer{
    if (!_lineLayer) {
        _lineLayer = [[CALayer alloc] init];
        _lineLayer.backgroundColor = COLOR_PERSION_INFO_SELECTED.CGColor;
    }
    
    _lineLayer.frame = CGRectMake(0, 0, Left_Line_Width, CGRectGetHeight(self.bounds));
    
    [self.layer addSublayer:_lineLayer];
}

/**
 * 设置边框线
 */
-(void)setBorderLayer{
    
    if (!_borderLayer) {
        _borderLayer = [CALayer layer];
        
        _borderLayer.borderColor = COLOR_PERSION_INFO_SELECTED.CGColor;
        _borderLayer.borderWidth = 1.0;
    }
    
    _borderLayer.frame = self.bounds;
    
    [self.layer addSublayer:_borderLayer];
    
}

/**
 * 设置右边的圆角
 */
-(void)setRightConerByMaskLayer{
    
    if (!_maskLayer) {
        _maskLayer = [[CAShapeLayer alloc] init];
    }
    
    _maskLayer.frame = self.bounds;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
    
    _maskLayer.path = bezierPath.CGPath;
    
    self.layer.mask = _maskLayer;
}

/**
 * 布局菜单按钮
 */
-(void)layoutMenuButton{
    
    if (!_menuButton) {
        _menuButton = [[UIButton alloc] init];
        _menuButton.backgroundColor = COLOR_PERSION_INFO_SELECTED;
        _menuButton.titleLabel.textColor = COLOR_MENU_TEXT;
        _menuButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
        [self addSubview:_menuButton];
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panMenuButtonGestureAction:)];
        [_menuButton addGestureRecognizer:panGestureRecognizer];
        
        [_menuButton addTarget:self action:@selector(tapMenuButtonGestureAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    CGPoint point = CGPointMake(CGRectGetWidth(self.bounds) - Slide_Menu_Width, 0);
    
    _menuButton.frame = CGRectMake(point.x, point.y, Slide_Menu_Width, CGRectGetHeight(self.bounds));
    
    [self setMenuButtonTitleAlignCenter];
}

/**
 * 设置菜单按钮文字竖排居中对齐
 */
-(void)setMenuButtonTitleAlignCenter{
    
    _menuButton.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    CGFloat fontSize = _menuButton.titleLabel.font.pointSize;
    
    CGFloat padding = Slide_Menu_Width/2.0 - fontSize/2.0;
    
    [_menuButton setTitleEdgeInsets:UIEdgeInsetsMake(0, padding, 0, padding)];

}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
}


#pragma mark - Public Methods

-(void)openSlideMenu{
    [self triggerSliderMenu:YES withAnimation:YES];
}

-(void)closeSlideMenu{
    [self triggerSliderMenu:NO withAnimation:YES];
}

/**
 * 打开或关闭菜单
 */
-(void)triggerSliderMenu:(BOOL)open withAnimation:(BOOL)animation{
    
    if (self.isOpen != open) {
        open ? showMenuCount++ : showMenuCount--;
    }
    
    self.isOpen = open;
    
    CGPoint startPoint = self.layer.position;
    CGPoint endPoint = self.layer.position;
    
    if (open) {
        endPoint.x = CENTER_X_SHOW;
    }else{
        endPoint.x = CENTER_X_HIDDEN;
        
        [self resignFirstResponder];
    }
    
    //背景动画
    [self triggleBackgroundView:open withAnimation:animation];
    
    if (animation) {
        [self animationPositionFrom:startPoint toPosition:endPoint];
    }else{
        self.layer.position = endPoint;
    }
}

-(void)locationMenuAtPositionY:(CGFloat)positionY andSize:(CGSize)size inView:(UIView *)superView{
    
    self.isOpen = NO;
    
    [self addBackgroundViewInView:superView];
    
    CGPoint origin = CGPointMake(-size.width+Slide_Menu_Width, positionY);
    
    self.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
    
    [superView addSubview:self];
}

#pragma mark - PanGesture Recognizer Methods
-(void)panMenuButtonGestureAction:(UIPanGestureRecognizer *)recognizer{
    
    CGPoint point = [recognizer translationInView:self];
    
    CGPoint centerPoint = self.center;
    CGFloat centerPointX = centerPoint.x+point.x;
    
    [recognizer setTranslation:CGPointZero inView:self];
    
    if (centerPointX >= CENTER_X_HIDDEN && centerPointX <= CENTER_X_SHOW) {
        self.layer.position = CGPointMake(centerPointX, centerPoint.y);
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        _oldTranslatePoint = point;
    }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled){
        
        if (_oldTranslatePoint.x > 0) {
            [self triggerSliderMenu:YES withAnimation:YES];
        }else{
            [self triggerSliderMenu:NO withAnimation:YES];
        }
        
    }
    
}

-(void)tapMenuButtonGestureAction:(id)sender{
    [self triggerSliderMenu:!self.isOpen withAnimation:YES];
}

-(void)tapBackgroundViewGestureAction:(UIGestureRecognizer *)recognizer{
    if (self.hideAllSlideMenuBlock) {
        self.hideAllSlideMenuBlock();
    }
}

#pragma mark - Property Setting Methods

-(void)setMenuTitle:(NSString *)menuTitle{
    
    [_menuButton setTitle:menuTitle forState:UIControlStateNormal];
    
    [self setMenuButtonTitleAlignCenter];
}

-(UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
    }
    
    return _contentView;
}

-(void)setHideAllSlideMenuBlock:(HideAllSlideMenuBlock)hideAllSlideMenuBlock{
    _hideAllSlideMenuBlock = hideAllSlideMenuBlock;
    
    UIView *backgroudView = [self getBackgroundView];
    if([backgroudView.gestureRecognizers count] == 0){
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroundViewGestureAction:)];
        
        [backgroudView addGestureRecognizer:tapGesture];
    }
}

#pragma mark - Animation Methods
-(void)animationPositionFrom:(CGPoint)oldPosition toPosition:(CGPoint)newPosition{

    //usingSpringWithDamping : 弹簧的阻尼，影响弹簧“弹动”的幅度
    //initialSpringVelocity: 弹簧的速率（拉力），影响弹簧的“拉伸”的幅度
    [UIView animateWithDuration:duration_animation delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.center = newPosition;
    } completion:^(BOOL finished) {

    }];

    
}

#pragma mark - Private Helper Methods
-(void)addBackgroundViewInView:(UIView *)superView{
    UIView *backgroundView = [superView viewWithTag:Tag_For_BackgroundView];
    
    if (!backgroundView) {
        backgroundView = [[UIView alloc] init];
        backgroundView.tag = Tag_For_BackgroundView;
        backgroundView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        backgroundView.layer.zPosition = self.layer.zPosition - 1;
        backgroundView.hidden = YES;
        
        [superView addSubview:backgroundView];
        
        [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
}

-(UIView *)getBackgroundView{
    UIView *backgroundView = [self.superview viewWithTag:Tag_For_BackgroundView];
    return backgroundView;
}

-(void)triggleBackgroundView:(BOOL)show withAnimation:(BOOL)animation{
    UIView *view = [self getBackgroundView];
    
    if ((show && showMenuCount>1) || (!show && showMenuCount>0)) {
        return;
    }
    
    CGFloat alpha = 0.0;
    if (show) {
        alpha = 1.0;
        view.hidden = !show;
    }
    
    if (animation) {
        [UIView animateWithDuration:duration_animation animations:^{
            view.alpha = alpha;
        } completion:^(BOOL finished) {
            view.hidden = !show;
        }];
    }else{
        view.hidden = !show;
    }
    
}


-(void)reloadData{
    
}


-(BOOL)resignFirstResponder{
    
    for (UIView *view in self.contentView.subviews) {
        if ([view respondsToSelector:@selector(resignFirstResponder)]) {
            [view resignFirstResponder];
        }
    }
    
    return [super resignFirstResponder];
}

@end
