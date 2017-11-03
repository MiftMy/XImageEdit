//
//  APDrawManager.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/8.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APDrawManager.h"
#import "APDrawModel.h"
#import "APDrawPathModel.h"
#import "UIColor_XMColor.h"

@implementation APDrawManager
+ (UIImage *)imageFromModel:(APDrawModel *)model scale:(CGFloat)scale {
    CGSize size = model.paintSize;
    APDrawPathModel *pathModel = model.pathModel;
    if (scale > 0) {
        pathModel = [self model:model.pathModel withScale:scale];
    }
    UIGraphicsBeginImageContextWithOptions(size, false, 0);
    UIBezierPath *path = [self pathFromModel:pathModel];
    if (model.isEraser) {
        [[UIColor clearColor]set];
        [path strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
    } else {
        [[UIColor colorWithHexString:model.strokeColor] set];
    }
    [path stroke];
    UIImage *desImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  desImg;
}

+ (UIImage *)imageFromModels:(NSArray *)list scale:(CGFloat)scale {
    APDrawModel *model = list[0];
    CGSize size = model.paintSize;
    UIGraphicsBeginImageContextWithOptions(size, false, 0);
    UIBezierPath *temPath = [UIBezierPath new];
    for (APDrawModel *model in list) {
        APDrawPathModel *pathModel = model.pathModel;
        if (scale > 0) {
            pathModel = [self model:model.pathModel withScale:scale];
        }
        UIBezierPath *path = [self pathFromModel:pathModel];
        [temPath appendPath:path];
        if (model.isEraser) {
            [[UIColor clearColor]set];
            [path strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
        } else {
            [[UIColor colorWithHexString:model.strokeColor] set];
        }
        [path stroke];
    }
    
    UIImage *desImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  desImg;
}

+ (UIImage *)imageFromModel:(APDrawModel *)model orgImage:(UIImage *)imgOrg scale:(CGFloat)scale {
    CGSize size = model.paintSize;
    CGSize imgSize = imgOrg.size;
    APDrawPathModel *pathModel = model.pathModel;
    if (!CGSizeEqualToSize(size, imgSize) || scale > 0) {
        CGFloat scaleDes = scale>0 ? scale : imgSize.width / size.width;
        size = imgSize;
        pathModel = [self model:model.pathModel withScale:scaleDes];
    }
    UIGraphicsBeginImageContextWithOptions(size, false, 0);
    [imgOrg drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [[UIColor clearColor]set];
    UIBezierPath *path = [self pathFromModel:pathModel];
    if (model.isEraser) {
        [path strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
    } else {
        [[UIColor colorWithHexString:model.strokeColor] set];
    }
    [path stroke];
    UIImage *desImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  desImg;
}

+ (UIImage *)imageFromModels:(NSArray *)list orgImage:(UIImage *)imgOrg scale:(CGFloat)scale {
    APDrawModel *model = list[0];
    CGSize size = model.paintSize;
    CGSize imgSize = imgOrg.size;
    CGFloat scaleDes = scale;
    if (!CGSizeEqualToSize(size, imgSize) || scale > 0) {
        scaleDes = scale>0 ? scale : imgSize.width / size.width;
        size = imgSize;
    }
    UIGraphicsBeginImageContextWithOptions(imgSize, false, 0);
    [imgOrg drawInRect:CGRectMake(0, 0, size.width, size.height)];
//    [[UIColor clearColor]set];
    
    for (APDrawModel *model in list) {
        CGSize size = model.paintSize;
        APDrawPathModel *pathModel = model.pathModel;
        if (!CGSizeEqualToSize(size, imgSize) || scale > 0) {
            CGFloat scaleDes = scale>0 ? scale : imgSize.width / size.width;
            size = imgSize;
            pathModel = [self model:model.pathModel withScale:scaleDes];
        }
        UIBezierPath *path = [self pathFromModel:pathModel];
        if (model.isEraser) {
            [path strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
        } else {
            [[UIColor colorWithHexString:model.strokeColor] set];
        }
        [path stroke];
    }
    
    UIImage *desImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  desImg;
}

+ (APDrawPathModel *)model:(APDrawPathModel *)model withScale:(CGFloat)scale {
    APDrawPathModel *newModel = [APDrawPathModel new];
    NSMutableArray *newList = [NSMutableArray arrayWithCapacity:model.pointList.count];
    for (NSString *pointStr in model.pointList) {
        CGPoint point = CGPointFromString(pointStr);
        point.x *= scale;
        point.y *= scale;
        [newList addObject:NSStringFromCGPoint(point)];
    }
    newModel.pointList = newList;
    newModel.lineWidth = model.lineWidth * scale;
    return newModel;
}

+ (UIBezierPath *)pathFromModel:(APDrawPathModel *)model {
    UIBezierPath *path;
    switch (model.shapeType) {
        case APDrawShapeTypeCurve:
        case APDrawShapeTypeLine:
            path = [UIBezierPath bezierPath];
            for (NSInteger indx = 0; indx < model.pointList.count; indx++) {
                NSString *pointStr = model.pointList[indx];
                CGPoint point = CGPointFromString(pointStr);
                if (indx == 0) {
                    
                    [path moveToPoint:point];
                } else {
                    [path addLineToPoint:point];
                }
            }
            break;
        case APDrawShapeTypeCircle:
        case APDrawShapeTypeEllipse:
            path = [UIBezierPath bezierPathWithRect:[self rectFrom2Point:model.pointList]];
            break;
        case APDrawShapeTypeSquare:
            path = [UIBezierPath bezierPathWithOvalInRect:[self rectFrom2Point:model.pointList]];
            break;
        default:
            break;
    }
    path.lineWidth = model.lineWidth;
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    return path;
}

+ (CGRect)rectFrom2Point:(NSArray *)points {
    CGPoint begin = CGPointFromString(points[0]);
    CGPoint end = CGPointFromString([points lastObject]);
    return CGRectMake(begin.x, begin.y, begin.x-end.x, begin.y-end.y);
}


+ (UIImage *)screenshot:(UIView *)shotView {
    UIGraphicsBeginImageContextWithOptions(shotView.frame.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [shotView.layer renderInContext:context];
    UIImage *getImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return getImage;
}
@end
