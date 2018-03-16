//
//  WaterView.m
//  tuanzhuang
//
//  Created by red on 2018/3/6.
//  Copyright © 2018年 red. All rights reserved.
//

#import "WaterView.h"
@interface WaterView ()
@property (nonatomic, strong) NSTimer * rippleTimer;/**<计时器*/
@property (nonatomic, strong) UILabel * titleLabel;/**<标题label*/
@property (nonatomic, strong) UILabel * messageLabel;/**<提示语label*/
@property (nonatomic, strong) UIButton * clickButton;/**<*/
@property (nonatomic, strong) UILabel * stepLabel;/**<步骤label*/
@end

@implementation WaterView

-(instancetype)init
{
    if (self = [super init]) {
        [self layoutUI];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self layoutUI];
    }
    return self;
}

-(void)show
{
    self.rippleTimer = [NSTimer timerWithTimeInterval:1.3 target:self selector:@selector(addRippleLayer) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_rippleTimer forMode:NSRunLoopCommonModes];
}

-(void)stop
{
    [self closeRippleTimer];
//    [self removeAllSubLayers];
//    [self removeFromSuperview];
//    [self.layer removeAllAnimations];
}

#pragma mark - 页面布局
- (void)layoutUI
{
    self.backgroundColor = [UIColor clearColor];
    UIImageView * bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    bgImageView.image = [UIImage imageNamed:@"synchronization_bg.png"];
    [self addSubview:bgImageView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, SCREEN_W, 50)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:25];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLabel];
    
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.titleLabel.frame.size.height+self.titleLabel.frame.origin.y+20, SCREEN_W, 50)];
    self.messageLabel.font = [UIFont boldSystemFontOfSize:22];
    self.messageLabel.textColor = [UIColor whiteColor];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.messageLabel];
    
    self.stepLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 92, 92)];
    self.stepLabel.center = CGPointMake(self.center.x, self.bounds.size.height * 2.0/3.0+90);
    self.stepLabel.layer.borderWidth = 11.0;
    self.stepLabel.layer.borderColor = RGBColor(255, 255, 255).CGColor;
    self.stepLabel.layer.cornerRadius = 46;
    self.stepLabel.layer.masksToBounds = YES;
    self.stepLabel.textAlignment = NSTextAlignmentCenter;
    self.stepLabel.font = [UIFont boldSystemFontOfSize:40.0];
    self.stepLabel.textColor = RGBColor(255, 255, 255);
    [self addSubview:self.stepLabel];
    
    self.clickButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 180, 50)];
    self.clickButton.center = CGPointMake(self.center.x, self.bounds.size.height-50);
    self.clickButton.backgroundColor = RGBColor(0, 122, 255);
    self.clickButton.layer.cornerRadius = 3.0;
    self.clickButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.clickButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.clickButton];
    
    self.step = 1;
    self.status = SYN_NORMAL;
}

#pragma mark - set 方法
-(void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = _title;
}

-(void)setMessage:(NSString *)message
{
    _message = message;
    self.messageLabel.text = _message;
}

-(void)setStep:(int)step
{
    _step = step;
    self.stepLabel.text = [NSString stringWithFormat:@"%d",_step];
    [self handleButton];
}

-(void)setStatus:(SynDataStatus)status
{
    _status = status;
    self.stepLabel.backgroundColor = _status == SYN_ERROR ? RGBColor(255, 0, 0) : RGBColor(0, 122, 255);
    [self handleButton];
}

//根据 status、step 设置按钮标题、显示状态
-(void)handleButton
{
    switch (_step) {
        case 1:
        {
            self.clickButton.hidden = NO;
            if (_status == SYN_ERROR) {
                [self.clickButton setTitle:@"刷    新" forState:UIControlStateNormal];
            } else {
                [self.clickButton setTitle:@"取    消" forState:UIControlStateNormal];
            }
        }
            break;
        case 2:
        {
            self.clickButton.hidden = _status == SYN_NORMAL;
            [self.clickButton setTitle:@"刷    新" forState:UIControlStateNormal];
        }
            break;
        case 3:
        {
            self.clickButton.hidden = NO;
            if (_status == SYN_ERROR) {
                [self.clickButton setTitle:@"刷    新" forState:UIControlStateNormal];
            } else {
                [self.clickButton setTitle:@"完    成" forState:UIControlStateNormal];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - 添加波纹
- (void)addRippleLayer
{
    CAShapeLayer *rippleLayer = [[CAShapeLayer alloc] init];
    // 半径
    CGFloat rabius = 50;
    // 开始角
    CGFloat startAngle = -(1 - 0.03)*M_PI;
    // 中心点
    CGPoint point = CGPointMake(self.center.x, self.bounds.size.height * 2.0/3.0+50);
    // 结束角
    CGFloat endAngle = -0.03*M_PI;
    UIBezierPath *beginPath = [UIBezierPath bezierPathWithArcCenter:point radius:rabius startAngle:startAngle endAngle:endAngle clockwise:YES];
    rippleLayer.path = beginPath.CGPath;
    rippleLayer.strokeColor = [UIColor whiteColor].CGColor;
    rippleLayer.lineWidth = 1.5;
    rippleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:rippleLayer];
    
    UIBezierPath *endPath = [UIBezierPath bezierPathWithArcCenter:point radius:self.bounds.size.width/2.0 startAngle:startAngle endAngle:endAngle clockwise:YES];
    rippleLayer.path = endPath.CGPath;
    rippleLayer.opacity = 0.0;
    
    CABasicAnimation *rippleAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    rippleAnimation.fromValue = (__bridge id _Nullable)(beginPath.CGPath);
    rippleAnimation.toValue = (__bridge id _Nullable)(endPath.CGPath);
    rippleAnimation.duration = 5.0;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:0.6];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
    opacityAnimation.duration = 5.0;
    
    [rippleLayer addAnimation:opacityAnimation forKey:@""];
    [rippleLayer addAnimation:rippleAnimation forKey:@""];
    
    [self performSelector:@selector(removeRippleLayer:) withObject:rippleLayer afterDelay:5.0];
}

#pragma mark - 移除波纹
- (void)removeRippleLayer:(CAShapeLayer *)rippleLayer
{
    [rippleLayer removeFromSuperlayer];
    rippleLayer = nil;
}

- (void)removeAllSubLayers
{
    for (NSInteger i = 0; [self.layer sublayers].count > 0; i++) {
        [[[self.layer sublayers] firstObject] removeFromSuperlayer];
    }
}

- (void)closeRippleTimer
{
    if (_rippleTimer) {
        if ([_rippleTimer isValid]) {
            [_rippleTimer invalidate];
        }
        _rippleTimer = nil;
    }
}

#pragma mark - 点击按钮相关方法
static buttonBlock _block;
+(void)clickBlock:(buttonBlock)block
{
    _block = block;
}

-(void)buttonAction:(id)sender
{
    if (_block) {
        OperateType type = SYN_CANCLE;
        switch (_step) {
            case 1:
            {
                type = _status == SYN_ERROR ? SYN_REFRESH : SYN_CANCLE;
            }
                break;
            case 2:
            {
                type = SYN_REFRESH;
            }
                break;
            case 3:
            {
                type = _status == SYN_ERROR ? SYN_REFRESH : SYN_FINISH;
            }
                break;
        }
        _block(type);
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
