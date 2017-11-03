//
//  APMiddleSlider.m
//  XMFilter
//
//  Created by mifit on 2017/9/1.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APMiddleSlider.h"
@interface APMiddleSlider()
{
    CGPoint touchPoint;
    CGFloat offsetY;
    BOOL isInit;
}
@end
@implementation APMiddleSlider
- (void)awakeFromNib {
    [super awakeFromNib];
    [self initData];
    
    
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initData];
    }
    return self;
}

- (void)initData {
    offsetY = 10;
    _minValue = -10;
    _maxValue = 20;
    _value = 0;
    touchPoint = CGPointMake(15, 0);
    _thumbRect = CGRectZero;
    isInit = NO;
}
- (void)layoutSubviews {
    if (!isInit) {
        
        if (CGRectEqualToRect(CGRectZero, _thumbRect)) {
            _thumbRect = CGRectMake(self.frame.size.width/2-15, self.frame.size.height/2-15+offsetY, 30, 30);
        } else {
            CGFloat h = _thumbRect.size.height;
            CGFloat w = _thumbRect.size.width;
            _thumbRect = CGRectMake(self.frame.size.width/2-w/2, self.frame.size.height/2-h/2+offsetY, w, h);
        }
        
        touchPoint = CGPointMake(self.frame.size.width/2, 0);
        isInit = YES;
    }
}

- (void)setValue:(CGFloat)value {
    if (!(_value - value > -0.00001 && _value - value < 0.00001)) {
        _value = value;
        touchPoint = [self valueToTouchPoint:value];
        [self setNeedsDisplay];
    }
}

- (void)setMinValue:(CGFloat)minValue {
    _minValue = minValue;
    [self setNeedsDisplay];
}

- (void)setMaxValue:(CGFloat)maxValue {
    _maxValue = maxValue;
    [self setNeedsDisplay];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    //画slider
    [self loadSliderWithContext:context];
    //画滑块
    [self loadThumWithContext:context];
}
//画滑块
- (void)loadThumWithContext:(CGContextRef)context {

    //有背景图则用背景图 没有就画圆
    if (self.thumbImage) {
        [self.thumbImage drawInRect: self.thumbRect];
    } else {
        CGContextAddEllipseInRect(context, self.thumbRect);
        [[UIColor whiteColor] set];
        CGContextFillPath(context);
    }
    NSString *str = [NSString stringWithFormat:@"%.2f", _value];
    CGRect rect = self.thumbRect;
    rect.origin.y -= 20;
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
    CGSize size = [str boundingRectWithSize:CGSizeMake(50, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    rect.origin.x += (rect.size.width-size.width)/2;
    rect.size.width = size.width;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName:[UIColor whiteColor]};
    [str drawInRect:rect withAttributes:dict];
}

//画滑杆内容
- (void)loadSliderWithContext:(CGContextRef)context {
    CGRect frame = self.bounds;
    CGFloat midY = CGRectGetMidY(frame)+offsetY;
    CGFloat midX = CGRectGetMidX(frame);
    CGFloat maxX = CGRectGetMaxX(frame);
    
    //进度背景//2a2c36
    CGFloat halfWidth = self.thumbRect.size.width/2;
    CGContextSetLineWidth(context, 2); // 线的宽度
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetRGBStrokeColor(context, 42.0/255, 44.0/255, 54.0/255, 1);
    CGContextMoveToPoint(context, halfWidth, midY);
    CGContextAddLineToPoint(context, maxX - halfWidth, midY);
    CGContextStrokePath(context);
    
    //中间块
    CGContextSetLineWidth(context, 1); // 线的宽度
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextMoveToPoint(context, midX, midY-3);
    CGContextAddLineToPoint(context, midX, midY+3);
    CGContextStrokePath(context);
    
    //进度
    CGContextSetLineWidth(context, 2);
    if (touchPoint.x < midX) {
        CGContextMoveToPoint(context, midX-2, midY);
    } else {
        CGContextMoveToPoint(context, midX+2, midY);
    }
    CGContextSetRGBStrokeColor(context, 2.0/255, 137.0/255, 1, 1);
    CGContextAddLineToPoint(context, touchPoint.x, midY);
    CGContextStrokePath(context);
}

//开始拖动
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event {
    CGPoint point = [touch locationInView:self];
    
    //可滑动范围
    if (!CGRectContainsPoint(self.thumbRect, point)) {
        return NO;
    }
    
    CGFloat halfWidth = self.thumbRect.size.width/2;
    if (point.x < halfWidth) {
        point.x = halfWidth;
    }
    if (point.x > self.frame.size.width-halfWidth) {
        point.x = self.frame.size.width-halfWidth;
    }
    _value = [self touchPointToVal:point];
    touchPoint = point;
    [self setNeedsDisplay];
    if (self.valueChanged) {
        self.valueChanged(_value);
    }
    return YES;
}


//持续拖动
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event {
    CGPoint point = [touch locationInView:self];
    CGFloat halfWidth = self.thumbRect.size.width/2;
    if (point.x < halfWidth) {
        point.x = halfWidth;
    }
    if (point.x > self.frame.size.width-halfWidth) {
        point.x = self.frame.size.width-halfWidth;
    }
    touchPoint = point;
    _value = [self touchPointToVal:point];
    CGRect tem = self.thumbRect;
    tem.origin.x = point.x-self.thumbRect.size.width/2;
    self.thumbRect = tem;
    [self setNeedsDisplay];
    if (self.valueChanged) {
        self.valueChanged(_value);
    }
    return YES;
}

//拖动结束
- (void)endTrackingWithTouch:(nullable UITouch *)touch withEvent:(nullable UIEvent *)event {
    CGPoint point = [touch locationInView:self];
    CGFloat halfWidth = self.thumbRect.size.width/2;
    if (point.x < halfWidth) {
        point.x = halfWidth;
    }
    if (point.x > self.frame.size.width-halfWidth) {
        point.x = self.frame.size.width-halfWidth;
    }
    touchPoint = point;
    _value = [self touchPointToVal:point];
    CGRect tem = self.thumbRect;
    tem.origin.x = point.x-self.thumbRect.size.width/2;
    self.thumbRect = tem;
    [self setNeedsDisplay];
    if (self.valueChanged) {
        self.valueChanged(_value);
    }
}

- (CGFloat)touchPointToVal:(CGPoint)point {
    CGFloat width = (self.frame.size.width - self.thumbRect.size.width)/2;
    CGFloat curVal = 0;
    if (point.x <= self.frame.size.width/2) {
        CGFloat curWidth = point.x - self.thumbRect.size.width/2;
        curWidth = width - curWidth;
        curVal = curWidth/width * self.minValue;
    } else {
        CGFloat curWidth = point.x - self.frame.size.width/2;
        curVal = curWidth/width * self.maxValue;
    }
    return curVal;
}

- (CGPoint)valueToTouchPoint:(CGFloat)val {
    CGFloat width = (self.frame.size.width - self.thumbRect.size.width)/2;
    if (val >= 0) {
        CGFloat persent = val / _maxValue;
        CGFloat curWidth = width * persent;
        return CGPointMake(curWidth + CGRectGetMidX(self.frame), 0);
    } else {
        CGFloat persent = val / _minValue;
        CGFloat curWidth = width * persent;
        return CGPointMake(CGRectGetMidX(self.frame) - curWidth, 0);
    }
}
@end
