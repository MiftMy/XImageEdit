//
//  APImageFilterBoard.h
//  AreoxPlay
//
//  Created by mifit on 2017/9/13.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, APBlurType) {
    APBlurTypeCircle = 0,   //圆
    APBlurTypeEllipse,      //椭圆        ---未实现
    APBlurTypeLine,         //直线
    APBlurTypeNone
};

@interface APImageBlurBoard : UIView
@property (nonatomic ,assign) APBlurType type;      //绘制类型 圆
@property (nonatomic ,assign) CGPoint drawCenter;   //绘制中心 center
@property (nonatomic ,assign) CGFloat radius;       //半径    50
@property (nonatomic ,assign) CGFloat rotationAngle;//旋转角度 弧度制，0
@property (nonatomic ,assign) CGFloat gradientWith; //渐进宽   30

- (void)showMask;
- (void)hideMask;
- (void)flashMask;
@property (nonatomic, copy) void (^touchEndBlock)(void);
@property (nonatomic, copy) void (^touchBeginBlock)(void);
@end
