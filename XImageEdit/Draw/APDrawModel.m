//
//  APDrawModel.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/8.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APDrawModel.h"
#import "APDrawPathModel.h"

@implementation APDrawModel
- (id)copyWithZone:(nullable NSZone *)zone {
    APDrawModel *newModel = [APDrawModel new];
    newModel.paintSize = self.paintSize;
    newModel.isEraser = self.isEraser;
    newModel.strokeColor = self.strokeColor;
    newModel.pathModel = [self.pathModel copy];
    return newModel;
}
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [self copyWithZone:zone];
}
@end
