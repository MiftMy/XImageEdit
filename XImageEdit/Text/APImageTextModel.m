//
//  APImageTextModel.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/13.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageTextModel.h"

@implementation APImageTextModel

- (id)copyWithZone:(nullable NSZone *)zone {
    APImageTextModel *newModel = [APImageTextModel new];
    newModel.text = self.text;
    newModel.textH = self.textH;
    newModel.textZ = self.textZ;
    newModel.color = self.color;
    newModel.colorAlpha = self.colorAlpha;
    newModel.fontName = self.fontName;
    newModel.fontSize = self.fontSize;
    newModel.rect = self.rect;
    newModel.alignment = self.alignment;
    newModel.angle = self.angle;
    newModel.scale = self.scale;
    return newModel;
}
@end
