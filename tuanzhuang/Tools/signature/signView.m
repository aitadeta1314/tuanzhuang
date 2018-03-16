//
//  signView.m
//  tuanzhuang
//
//  Created by red on 2017/12/15.
//  Copyright © 2017年 red. All rights reserved.
//

#import "signView.h"

@interface signView () {
    short sTrace[2048];
    int nTraceCount;
    float sk_width;
    float r;
    float g;
    float b;
    BOOL eraser;
}

@property (nonatomic, strong) UIView * eraserView;

@end
@implementation signView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        r = g = b = 0;
        sk_width = 4;
        nTraceCount = 0;
    }
    return self;
}

-(instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        r = g = b = 0;
        sk_width = 4;
        nTraceCount = 0;
    }
    return self;
}

-(instancetype)initWithImage:(UIImage *)image {
    if (self = [super initWithImage:image]) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        r = g = b = 0;
        sk_width = 4;
        nTraceCount = 0;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _editing = YES;
    if (eraser == NO) {
        _cleared = NO;
    }
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    self.eraserView.center = location;
    self.eraserView.hidden = NO;
    
    sTrace[nTraceCount++] = location.x;
    sTrace[nTraceCount++] = location.y;
    
    UIGraphicsBeginImageContext(self.frame.size);
    [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), sk_width);                // set sk width
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), YES);
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);         // set 线条平滑
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), r, g, b, 1); // set color
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGPoint pastLocation = [touch previousLocationInView:self];
    
    self.eraserView.center = location;
    
    sTrace[nTraceCount++] = location.x;
    sTrace[nTraceCount++] = location.y;
    
    // draw lines
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), pastLocation.x, pastLocation.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), location.x, location.y);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.image = UIGraphicsGetImageFromCurrentImageContext();
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    self.eraserView.center = location;
    self.eraserView.hidden = YES;
    
    sTrace[nTraceCount++] = location.x;
    sTrace[nTraceCount++] = location.y;
    sTrace[nTraceCount++] = -1;
    sTrace[nTraceCount++] = 0;
    
    sTrace[nTraceCount++] = -1;
    sTrace[nTraceCount++] = -1;
    nTraceCount--;
    nTraceCount--;
    
    UIGraphicsEndImageContext();
}

//橡皮擦
-(UIView *)eraserView
{
    if (_eraserView == nil && eraser) {
        _eraserView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sk_width, sk_width)];
        _eraserView.backgroundColor = RGBColorAlpha(0, 0, 0, 0.3);
        _eraserView.layer.cornerRadius = sk_width/2.0;
        [self addSubview:_eraserView];
    }
    return _eraserView;
}

-(void)write
{
    eraser = NO;
    sk_width = 4;
    r = g = b = 0;
    _eraserView = nil;
}

-(void)erase
{
    eraser = YES;
    sk_width = 50;
    r = g = b = 1;
}

- (void)clearImage
{
    _editing = YES;
    _cleared = YES;
    nTraceCount = 0;
    self.image = UIGraphicsGetImageFromCurrentImageContext();
}

@end
