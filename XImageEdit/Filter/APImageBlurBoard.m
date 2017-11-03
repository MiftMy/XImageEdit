//
//  APImageFilterBoard.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/13.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageBlurBoard.h"
@interface APImageBlurBoard()
{
    APBlurType oldType;
    CGFloat maxRadius;
    
    //移动
    CGPoint orgCenter;
    CGPoint beginPoint;
    
    //缩放
    CGFloat oldRadius;
    BOOL isOneTouch;//两个手指变一个
    
    CGFloat oldRatation;
    
}

@end
@implementation APImageBlurBoard

- (void)awakeFromNib {
    [super awakeFromNib];
    _gradientWith = 30;
    _radius = 50;
    _rotationAngle = 0;
    oldType = APBlurTypeNone;
    _type = APBlurTypeNone;
    
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panHandle:)];
    [self addGestureRecognizer:panGR];
    UIPinchGestureRecognizer *pinchGR = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchHandle:)];
    [self addGestureRecognizer:pinchGR];
    UIRotationGestureRecognizer *rotatinGR = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotaionHandle:)];
    [self addGestureRecognizer: rotatinGR];
}

- (void)layoutSubviews {
    orgCenter = _drawCenter = self.center;
    maxRadius = MAX(self.bounds.size.width, self.bounds.size.height);
}

- (void)setType:(APBlurType)type {
    if (type != _type) {
        oldType = _type;
        _type = type;
    }
}

- (void)showMask {
    if (self.type == APBlurTypeNone) {
        _type = oldType;
        [self setNeedsDisplay];
    }
}
- (void)hideMask {
    if (oldType == APBlurTypeNone) {
        oldType = self.type;
        _type = APBlurTypeNone;
        [self setNeedsDisplay];
    }
}

- (void)flashMask {
    [UIView animateWithDuration:1 animations:^{
        self.type = oldType;
        [self setNeedsDisplay];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 animations:^{
            self.type = APBlurTypeNone;
            [self setNeedsDisplay];
        }];
    }];
}

#pragma mark - UIGestureRecognizer
//移动
- (void)panHandle:(id)sender {
    UIPanGestureRecognizer *gr = (UIPanGestureRecognizer *)sender;
    CGPoint point = [gr locationInView:self];
    if (gr.state == UIGestureRecognizerStateBegan) {
        beginPoint = point;
        orgCenter = self.drawCenter;
        [self gestureBegin];
    }
    if (gr.state == UIGestureRecognizerStateChanged || gr.state == UIGestureRecognizerStateEnded) {
        CGPoint offset = CGPointMake(point.x-beginPoint.x, point.y-beginPoint.y);
        CGAffineTransform t =  CGAffineTransformMakeTranslation(offset.x, offset.y);
        self.drawCenter = CGPointApplyAffineTransform(orgCenter , t);
        
        if (gr.state == UIGestureRecognizerStateEnded) {
            [self gestureEnd];
        }
    }
    [self setNeedsDisplay];
}
//缩放
- (void)pinchHandle:(id)sender {
    UIPinchGestureRecognizer *gr = (UIPinchGestureRecognizer *)sender;
    if (gr.state == UIGestureRecognizerStateBegan) {
        oldRadius = self.radius;
        isOneTouch = NO;
        [self gestureBegin];
    }
    if (gr.state == UIGestureRecognizerStateChanged) {
        if (gr.numberOfTouches == 1 ) {
            if (!isOneTouch) {
                isOneTouch = YES;
                beginPoint = [gr locationInView:self];
                return;
            }
            [self panHandle:sender];
        } else {
            CGFloat temRadius = oldRadius*gr.scale;
            if (temRadius < 0) {
                temRadius = 0;
            }
            if (temRadius > maxRadius) {
                temRadius = maxRadius;
            }
            self.radius = temRadius;
        }
    }
    if (gr.state == UIGestureRecognizerStateEnded) {
        [self gestureEnd];
    }
    [self setNeedsDisplay];
}
//旋转
- (void)rotaionHandle:(id)sender {
    if (self.type != APBlurTypeCircle) {
        UIRotationGestureRecognizer *gr = (UIRotationGestureRecognizer *)sender;
        if (gr.state == UIGestureRecognizerStateBegan) {
            oldRatation = self.rotationAngle;
            [self gestureBegin];
        }
        if (gr.state == UIGestureRecognizerStateChanged || gr.state == UIGestureRecognizerStateEnded) {
            NSLog(@"rotation:%.2f", gr.rotation);
            self.rotationAngle = oldRatation + gr.rotation;
            if (gr.state == UIGestureRecognizerStateEnded) {
                [self gestureEnd];
            }
        }
        [self setNeedsDisplay];
    }
}
- (void)gestureBegin {
    self.type = oldType;
    if (self.touchBeginBlock) {
        self.touchBeginBlock();
    }
}
- (void)gestureEnd {
    oldType = self.type;
    self.type = APBlurTypeNone;
    if (self.touchEndBlock) {
        self.touchEndBlock();
    }
}
//向量旋转公式：[x*cosA-y*sinA  x*sinA+y*cosA]
- (CGPoint)rotationPoint:(CGPoint)point rotation:(CGFloat)angle {
    point = CGPointMake(point.x-self.drawCenter.x, point.y-self.drawCenter.y);
    CGFloat sinVal = sin(angle);
    CGFloat cosVal = cos(angle);
    point = CGPointMake(point.x*cosVal-point.y*sinVal+self.drawCenter.x, point.y*cosVal+point.x*sinVal+self.drawCenter.y);
    return point;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
#pragma mark - draw
- (void)drawRect:(CGRect)rect {
    if (self.type == APBlurTypeNone) {
        return;
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    UIColor *clearColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    UIColor *whiteColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    // 渐变色的颜色
    NSArray *colorArr1 = @[(id)clearColor.CGColor, (id)whiteColor.CGColor];
    NSArray *colorArr2 = @[(id)whiteColor.CGColor, (id)clearColor.CGColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colorArr1, NULL);
    CGGradientRef gradient2 = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colorArr2, NULL);
    // 释放色彩空间
    CGColorSpaceRelease(colorSpace);
    colorSpace = NULL;
    
    // 获取当前context
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (self.type == APBlurTypeLine) {
        //上边朦胧
        CGPoint beginLeft = CGPointMake(self.drawCenter.x, self.drawCenter.y - self.gradientWith - self.radius/2);
        CGPoint endLeft = CGPointMake(self.drawCenter.x, self.drawCenter.y - self.radius/2);
        beginLeft = [self rotationPoint:beginLeft rotation:self.rotationAngle];
        endLeft = [self rotationPoint:endLeft rotation:self.rotationAngle];
        CGContextDrawLinearGradient(ctx, gradient2, beginLeft, endLeft, kCGGradientDrawsBeforeStartLocation);
        
        //下边朦胧
        CGPoint beginRigth = CGPointMake(self.drawCenter.x, self.drawCenter.y + self.radius/2);
        CGPoint endRight = CGPointMake(self.drawCenter.x, self.drawCenter.y + self.gradientWith + self.radius/2);
        beginRigth = [self rotationPoint:beginRigth rotation:self.rotationAngle];
        endRight = [self rotationPoint:endRight rotation:self.rotationAngle];
        CGContextDrawLinearGradient(ctx, gradient, beginRigth, endRight, kCGGradientDrawsAfterEndLocation);
    }
    
    if (self.type == APBlurTypeCircle) {
        CGContextDrawRadialGradient(ctx, gradient, self.drawCenter, self.radius, self.drawCenter, self.radius + self.gradientWith, kCGGradientDrawsAfterEndLocation);
    }
    
    if (self.type == APBlurTypeEllipse) {
        CGPoint endCenter = self.drawCenter;
        endCenter.y += 20;
        CGContextDrawRadialGradient(ctx, gradient, self.drawCenter, self.radius, endCenter, self.radius + self.gradientWith, kCGGradientDrawsAfterEndLocation);
    }

    // 释放gradient
    CGGradientRelease(gradient);
    CGGradientRelease(gradient2);
    gradient = NULL;
    gradient2 = NULL;
}


@end
