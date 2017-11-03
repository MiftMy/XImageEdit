//
//  APImageTextModel.h
//  AreoxPlay
//
//  Created by mifit on 2017/9/13.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APImageTextModel : NSObject
@property (nonatomic, copy) NSString *text;         //文本
@property (nonatomic, assign) CGFloat textH;        //行间距
@property (nonatomic, assign) CGFloat textZ;        //字间距
@property (nonatomic, copy) NSString *color;        //字体颜色
@property (nonatomic, assign) CGFloat colorAlpha;   //字体颜色透明度
@property (nonatomic, copy) NSString *fontName;     //字体名字
@property (nonatomic, assign) NSInteger fontSize;   //字体大小
@property (nonatomic, assign) CGRect rect;          //文本位置大小
@property (nonatomic, assign) NSInteger alignment;  //文本对齐方式
@property (nonatomic, assign) CGFloat angle;        //旋转角度
@property (nonatomic, assign) CGFloat scale;        //旋转角度
@end
