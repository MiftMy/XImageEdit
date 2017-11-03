//
//  APMiddleSlider.h
//  XMFilter
//
//  Created by mifit on 2017/9/1.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APMiddleSlider : UIControl
@property (nonatomic, assign) NSInteger floatNum;//小数点几位
@property (nonatomic, assign) CGFloat value;

@property (nonatomic, assign) CGFloat minValue;//必须负数
@property (nonatomic, assign) CGFloat maxValue;//必须正数

@property (nonatomic, assign) CGRect thumbRect;

@property (nonatomic, strong) UIImage *thumbImage;

@property (nonatomic, copy) void (^valueChanged)(CGFloat val);
@end
