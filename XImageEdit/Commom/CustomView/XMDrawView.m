//
//  XMDrawView.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/20.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "XMDrawView.h"
#import "APImageTextModel.h"
#import "UIColor_XMColor.h"

@interface XMDrawView()
@property (nonatomic, strong) NSMutableArray *labelList;
@end
@implementation XMDrawView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor blackColor];
}
- (XMDrawView *)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (UIImage *)shotView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSMutableArray *)labelList {
    if (!_labelList) {
        _labelList = [NSMutableArray array];
    }
    return _labelList;
}

- (UIImage *)imgFromView {
    return [self shotView:self];
}

- (void)setTextList:(NSArray *)textList {
    CGRect r = self.frame;
    _textList = textList;
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    for (NSInteger indx = 0; indx < textList.count; indx++) {
        APImageTextModel *model = textList[indx];
        UILabel *label = [[UILabel alloc]init];
        [self addSubview:label];
        [self.labelList addObject:label];
        APImageTextModel *newModel = [self scaleModel:model];
        label.backgroundColor = [UIColor clearColor];
        label.tag = indx;
        label.frame = newModel.rect;
        label.textAlignment = newModel.alignment;
        label.textColor = [UIColor colorWithHexString:newModel.color];
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformRotate(transform, newModel.angle);
        transform = CGAffineTransformScale(transform, newModel.scale, newModel.scale);
        label.transform = transform;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = newModel.textH;
        NSDictionary *dic = @{NSParagraphStyleAttributeName:paragraphStyle,
                               NSKernAttributeName:@(newModel.textZ),
                               NSFontAttributeName:[UIFont fontWithName:newModel.fontName size:newModel.fontSize]};
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:newModel.text attributes:dic];
        label.attributedText = attributedString;
    }
}

- (APImageTextModel *)scaleModel:(APImageTextModel *)model {
    APImageTextModel *newModel = [APImageTextModel new];
    newModel.angle = model.angle;
    newModel.scale = model.scale;
    newModel.alignment = model.alignment;
    CGPoint pt = model.rect.origin;
    CGSize size = model.rect.size;
    newModel.rect = CGRectMake(pt.x*_scaleInImage, pt.y*_scaleInImage, size.width*_scaleInImage, size.height*_scaleInImage);
//    newModel.rect = model.re                              ct;
    newModel.fontSize = model.fontSize * _scaleInImage;
    newModel.fontName = model.fontName;
    newModel.colorAlpha = model.colorAlpha;
    newModel.color = model.color;
    newModel.textZ = model.textZ * _scaleInImage;
    newModel.textH = model.textH * _scaleInImage;
    newModel.text = model.text;
    return newModel;
}
@end
