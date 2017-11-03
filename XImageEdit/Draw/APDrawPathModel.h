//
//  APDrawPathModel.h
//  AreoxPlay
//
//  Created by mifit on 2017/9/8.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, APDrawShapeType) {
    APDrawShapeTypeCurve = 0,
    APDrawShapeTypeLine,            //pointList的第一个和最有一个点
    APDrawShapeTypeEllipse,         //前两个点
    APDrawShapeTypeCircle,          //前两个点
    APDrawShapeTypeSquare           //前两个点
};

@interface APDrawPathModel : NSObject <NSCopying, NSMutableCopying>
@property (nonatomic, strong) NSMutableArray *pointList;//绘画点集 ，点的字符串形式
@property (nonatomic, assign) CGFloat lineWidth;//线宽
@property (nonatomic, assign) APDrawShapeType shapeType;//绘图类型

@end
