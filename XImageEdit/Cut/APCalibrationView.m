//
//  APCalibrationView.m
//  XMGestureFallthrough
//
//  Created by mifit on 2017/9/25.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APCalibrationView.h"
@interface APCalibrationView()
<
UIScrollViewDelegate
>
{
    UIScrollView *scrollView;
    UIImageView *mIV;
    UIImageView *mMaskIV;
    UIView *centerView;
    
    CGFloat centerOffsetX;//中心位置时候，scrollview的offset的x
    CGFloat offsetXMin;
    CGFloat offsetXMax;
    CGFloat angleOffsetX;//一度对应偏移的x值
    
}
@end

@implementation APCalibrationView
- (void)awakeFromNib {
    [super awakeFromNib];
    [self updateUI];
}

- (APCalibrationView *)init {
    if (self = [super init]) {
        [self updateUI];
    }
    return self;
}

- (void)updateUI {
    if (!scrollView) {
        _angle = 0;
        centerOffsetX = 0;
        offsetXMin = 0;
        offsetXMax = 0;
        _enable = YES;
        self.backgroundColor = [UIColor clearColor];
        scrollView = [[UIScrollView alloc]init];
        scrollView.scrollEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.delegate = self;
        [self addSubview:scrollView];
        
        UIImageView *iv = [[UIImageView alloc]init];
        iv.backgroundColor = [UIColor clearColor];
        UIImage *img = [UIImage imageNamed:@"G2_photo_tt"];
        iv.image = img;
        [scrollView addSubview:iv];
        
        mIV = iv;
        centerOffsetX = -1000;
        
        
        UIImageView *maskIV = [[UIImageView alloc]init];
        maskIV.image = [UIImage imageNamed:@"G2_photo_zz"];
        mMaskIV = maskIV;
        maskIV.backgroundColor = [UIColor clearColor];
        [self addSubview: maskIV];
        
        UIView *view = [[UIView alloc]init];
        [self addSubview:view];
        view.backgroundColor = [UIColor colorWithRed:0 green:133/255.0 blue:1 alpha:1];
        centerView = view;
    }
}

- (void)layoutSubviews {
    CGSize size = self.bounds.size;
    mMaskIV.frame = scrollView.frame = CGRectMake(0, 0, size.width, size.height);
    CGSize imgSize = mIV.image.size;

    centerView.frame = CGRectMake(size.width/2, 0, 1, size.height);
    
    CGFloat height =  MIN(imgSize.height, 20);
    CGFloat width = imgSize.width / imgSize.height * height;
    mIV.frame = CGRectMake(size.width/2, (size.height-height)/2, width, height);
    centerOffsetX = (width-1)/2;
    
    //30大格   第16大格线为中心0度， 左右各可转15大格。一大格5°
    angleOffsetX = (width-1) / 90;
    offsetXMin = centerOffsetX - 45*angleOffsetX;
    offsetXMax = centerOffsetX + 45*angleOffsetX;
    
    scrollView.contentSize = CGSizeMake(width-1+size.width, height);
    scrollView.contentOffset = CGPointMake(centerOffsetX, 0);
}
#pragma mark - public
- (void)setAngle:(CGFloat)angle {
    angle = [self correctAngle:angle];
    _angle = angle;
    [self updateAngleUI:angle];
}

- (void)setEnable:(BOOL)enable {
    scrollView.scrollEnabled = enable;
}
#pragma mark - private
- (CGFloat)correctAngle:(CGFloat)angle {
    if (angle > 45) {
        angle = 45;
    }
    if (angle < -45) {
        angle = -45;
    }
    return angle;
}

- (void)updateAngleUI:(CGFloat)angle {
    CGFloat angleX = angle * angleOffsetX;
    CGFloat offsetX = centerOffsetX + angleX;
    CGRect rect = CGRectMake(offsetX, 0, self.bounds.size.width, self.bounds.size.height);
    [scrollView scrollRectToVisible:rect animated:YES];
}
#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    CGFloat offsetX = offset.x - centerOffsetX;
    
    CGFloat angleVal = offsetX / angleOffsetX;
    angleVal = [self correctAngle:angleVal];
    _angle = angleVal;
    if (self.valueChangedBlock) {
        self.valueChangedBlock((NSInteger)roundf(angleVal));
    }
}

@end
