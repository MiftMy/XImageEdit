//
//  APImageDrawboard.h
//  AreoxPlay
//
//  Created by mifit on 2017/9/8.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>
@class APDrawModel;

//画板view。包含手势、显示绘画内容、原始图片
@interface APImageDrawboard : UIView
//当前画笔属性
@property (nonatomic, assign) NSInteger drawType;//  0：画    1：马赛克   2：删除
@property (nonatomic, assign) NSInteger shapeType;// 0：曲线   1：直线   2：椭圆   3：圆   4：矩形
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) NSString *strokeColor;

//图片
@property (nonatomic, strong) UIImage *orgImg;
@property (nonatomic, readonly, strong) UIImage *desImg;

@property (nonatomic, assign) BOOL isShowOrg;//原图、绘图层切换
@property (nonatomic, copy) void (^gestureDidBlock)(void);
- (void)undo;
- (void)redu;
@end
