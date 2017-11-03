//
//  APImageDrawboard.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/8.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageDrawboard.h"
#import "APDrawManager.h"
#import "APDrawModel.h"
#import "APDrawPathModel.h"
#import "Masonry.h"
#import "APShowDrawView.h"
#import "APGestureView.h"

@interface APImageDrawboard()
<UIScrollViewDelegate>
{
    CGRect imgRect;//图片在imageview的位置大小
    CGFloat imgScaleInIV;// 图片在imageView的缩放比例   image.size.witdh / imageView

    //缩放用
    CGFloat lastScale;
    
    //平移用
    CGPoint beginPt;
    CGPoint beginOffset;
    
    //子view：scrolView、containerView、gestureView
    UIScrollView *scrolView;
    APGestureView *gestureView;
    UIView *containerView;// 子view：imgView、showView
    UIImageView *imgView;
    APShowDrawView *showView;
}
@end


@implementation APImageDrawboard

- (void)awakeFromNib {
    [super awakeFromNib];
    [self resetUI];
}

- (APImageDrawboard *)init {
    if (self = [super init]) {
        [self resetUI];
    }
    return self;
}

- (void)resetUI {
    _lineWidth = 10;
    _shapeType = 0;
    lastScale = 1;
    beginOffset = CGPointZero;
    
    scrolView = [[UIScrollView alloc]init];
    scrolView.backgroundColor = [UIColor clearColor];
    scrolView.minimumZoomScale = 1;
    scrolView.maximumZoomScale = 4;
    scrolView.userInteractionEnabled= YES;
    scrolView.bounces = YES;
    scrolView.delegate = self;
    scrolView.scrollsToTop = NO;
    [self addSubview:scrolView];
    [scrolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self);
    }];
    
    containerView = [UIView new];
    containerView.backgroundColor = [UIColor clearColor];
//    containerView.alpha = 0.5;
    [scrolView addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(scrolView);
        make.center.equalTo(scrolView);
        make.height.mas_equalTo(200);
    }];
    
    imgView = [UIImageView new];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.backgroundColor = [UIColor clearColor];
    [containerView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(containerView);
    }];
    
    showView = [APShowDrawView new];
    [containerView addSubview:showView];
    showView.backgroundColor = [UIColor clearColor];
//    showView.alpha = 0.5;
    [showView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(containerView);
    }];
    
    gestureView = [APGestureView new];
//    gestureView.backgroundColor = [UIColor redColor];
    gestureView.alpha = 0.5;
    [self addSubview:gestureView];
    [gestureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self);
    }];
    __weak typeof(self) weakSelf = self;
    gestureView.panDrawGRChanged = ^(NSInteger state, CGPoint pint) {
        __strong typeof(self) wsSelf = weakSelf;
        CGPoint dPt = [weakSelf pointFromGestureView2IV:pint];
        if (state == 1) {
            APDrawModel *model = [APDrawModel new];
            model.isEraser = (weakSelf.drawType == 1);
            model.paintSize = weakSelf.orgImg.size;
            model.strokeColor = weakSelf.strokeColor;
            APDrawPathModel *pathModel = [APDrawPathModel new];
            pathModel.lineWidth = roundf(self.lineWidth / scrolView.zoomScale);
            pathModel.shapeType = APDrawShapeTypeCurve;
            pathModel.pointList = [NSMutableArray array];
            [pathModel.pointList addObject:NSStringFromCGPoint(dPt)];
            model.pathModel = pathModel;
            [wsSelf->showView addStep:model];
            if (wsSelf.gestureDidBlock) {
                wsSelf.gestureDidBlock();
            }
        }
        if (state > 1) {
            APDrawModel *model = [wsSelf->showView.stepList lastObject];
            [model.pathModel.pointList addObject:NSStringFromCGPoint(dPt)];
        }
        [wsSelf->showView setNeedsDisplay];
    };
    gestureView.panGRChanged = ^(NSInteger state, CGPoint pint, NSInteger touches) {
        __strong typeof(self) wsSelf = weakSelf;
        if (touches >= 2) {
            if (state == 1) {
                beginPt = pint;
                beginOffset = scrolView.contentOffset;
            }
            if (state == 3 || state == 2) {
                CGPoint offset = CGPointMake(beginOffset.x - (pint.x-beginPt.x), beginOffset.y - (pint.y-beginPt.y));
                wsSelf->scrolView.contentOffset = offset;
                [wsSelf updateImageShow];
            }
        }
    };
    gestureView.pinchGRChanged = ^(NSInteger state, CGFloat scale, NSInteger touches) {
        __strong typeof(self) wsSelf = weakSelf;
        if (state == 1) {
            lastScale = wsSelf->scrolView.zoomScale;
        }
        if (state > 1 && touches >= 2) {
            wsSelf->scrolView.zoomScale = wsSelf->lastScale * scale;
        }
        [wsSelf scaleUpdateGestureView];
        [wsSelf updateImageShow];
    };
}

- (void)layoutSubviews {
    [containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(scrolView.bounds.size.height);
    }];
    [self scaleUpdateGestureView];
}

#pragma mark - public
- (void)undo {
    showView.activeStep--;
    if (showView.activeStep < 0) {
        showView.activeStep = 0;
    }
    [showView setNeedsDisplay];
}
- (void)redu {
    if (showView.activeStep < showView.stepList.count) {
        showView.activeStep++;
    }
    [showView setNeedsDisplay];
}

- (void)setOrgImg:(UIImage *)image {
    _orgImg = image;
    imgView.image = image;
    imgRect = [self imageRectInIV];
    [self scaleUpdateGestureView];
}

- (void)setIsShowOrg:(BOOL)isShowOrg {
    _isShowOrg = isShowOrg;
    showView.hidden = !isShowOrg;
}

- (UIImage *)desImg {
    if (showView.stepList.count <= 0) {
        return _orgImg;
    } else {
        //iv坐标
        NSArray *list = showView.stepList;
        NSMutableArray *desList = [NSMutableArray arrayWithCapacity:list.count];
        for (APDrawModel *model in showView.stepList) {
            APDrawModel *newModel = [model copy];
            NSMutableArray *ptList = [NSMutableArray arrayWithCapacity:model.pathModel.pointList.count];
            for (NSString *pStr in model.pathModel.pointList) {
                NSString *strPt = [self pointFromIV2Image:pStr];
                [ptList addObject:strPt];
            }
            newModel.pathModel.pointList = ptList;
            [desList addObject:newModel];
        }
        UIImage *img = [APDrawManager imageFromModels:desList orgImage:self.orgImg scale:imgScaleInIV];
        return img;
    }
}
#pragma mark - scroll view
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if (containerView) {
        return containerView;
    }
    return nil;
}

#pragma mark - private
//imageview 上的坐标转为图片上对应的屏幕坐标
- (NSString *)pointFromIV2Image:(NSString *)ptStr {
    CGPoint pt = CGPointFromString(ptStr);
//    pt.x = (pt.x-imgRect.origin.x)*imgScaleInIV;
//    pt.y = (pt.y-imgRect.origin.y)*imgScaleInIV;
    pt.x -= imgRect.origin.x;
    pt.y -= imgRect.origin.y;
    NSString *desPtStr = NSStringFromCGPoint(pt);
    return desPtStr;
}

//gestureVIew上的point转为UIImageView上的point，可能缩放平移
- (CGPoint)pointFromGestureView2IV:(CGPoint)point {
    CGPoint desPoint = point;
    desPoint.x = (desPoint.x + gestureView.frame.origin.x + scrolView.contentOffset.x)/scrolView.zoomScale;
    desPoint.y = (desPoint.y + gestureView.frame.origin.y + scrolView.contentOffset.y)/scrolView.zoomScale;
    return desPoint;
}

//计算image在imageview的位置大小
- (CGRect)imageRectInIV {
    CGSize imgSize = self.orgImg.size;
    CGSize size = self.bounds.size;
    CGSize desSize = size;
    CGFloat scaleW = imgSize.width / size.width;
    CGFloat scaleH = imgSize.height / size.height;
    if (scaleH > scaleW) {
        imgScaleInIV = scaleH;
        desSize.width = size.height * imgSize.width / imgSize.height;
    } else {
        desSize.height = size.width * imgSize.height / imgSize.width;
        imgScaleInIV = scaleW;
    }
    return CGRectMake((size.width-desSize.width)/2, (size.height-desSize.height)/2, desSize.width, desSize.height);
}

//控制绘画区域在图片内
- (void)scaleUpdateGestureView {
    CGFloat scale = scrolView.zoomScale;
    CGFloat scaleW = imgRect.size.width * scale;
    CGFloat scaleH = imgRect.size.height * scale;
    CGSize scSize = scrolView.bounds.size;
    CGFloat offsetLR = 0;
    if (scaleW <= scSize.width) { //宽度不够，显示有空白
        offsetLR = (scSize.width-scaleW)/2;
    }
    
    [gestureView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).mas_offset(offsetLR);
        make.right.equalTo(self.mas_right).mas_offset(-offsetLR);
    }];
//    [showView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(containerView.mas_left).mas_offset(offsetLR);
//        make.right.equalTo(containerView.mas_right).mas_offset(-offsetLR);
//    }];
//    [imgView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(containerView.mas_left).mas_offset(offsetLR);
//        make.right.equalTo(containerView.mas_right).mas_offset(-offsetLR);
//    }];
    
    CGFloat offsetTB = 0;
    if (scaleH <= scSize.height) {//高度不够，显示有空白
        offsetTB = (scSize.height-scaleH)/2;
    }
    [gestureView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).mas_offset(offsetTB);
        make.bottom.equalTo(self.mas_bottom).mas_offset(-offsetTB);
    }];
//    [showView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(containerView.mas_top).mas_offset(offsetTB);
//        make.bottom.equalTo(containerView.mas_bottom).mas_offset(-offsetTB);
//    }];
//    [imgView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(containerView.mas_top).mas_offset(offsetTB);
//        make.bottom.equalTo(containerView.mas_bottom).mas_offset(-offsetTB);
//    }];
}

//避免图片显示空白
- (void)updateImageShow {
    CGFloat scaleX = imgRect.origin.x * scrolView.zoomScale;
    CGFloat scaleY = imgRect.origin.y * scrolView.zoomScale;
    CGFloat scaleW = imgRect.size.width * scrolView.zoomScale;
    CGFloat scaleH = imgRect.size.height * scrolView.zoomScale;
    CGPoint offset = scrolView.contentOffset;
    CGSize scSize = scrolView.bounds.size;
    //高度显示有空白
    if (scaleH < scSize.height) {
        offset.y = (scaleH + scaleY*2 - scSize.height)/2;
    } else {
        if (offset.y < scaleY) {//上边有空
            offset.y = scaleY;
        }
        if (scaleY+scaleH < offset.y+scSize.height) {//下边有空
            offset.y = scaleY + scaleH - scSize.height;
        }
    }
    //宽度显示有空白
    if (scaleW < scSize.width) {
        offset.x = (scaleW + scaleX*2 - scSize.width)/2;
    } else {
        if (offset.x < scaleX) {//左边有空
            offset.x = scaleX;
        }
        if (scaleX+scaleW < offset.x+scSize.width) {//右边有空
            offset.x = scaleX + scaleW - scSize.width;
        }
    }
    scrolView.contentOffset = offset;
}
@end
