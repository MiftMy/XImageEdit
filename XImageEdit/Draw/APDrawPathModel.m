//
//  APDrawPathModel.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/8.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APDrawPathModel.h"

@implementation APDrawPathModel

- (id)copyWithZone:(nullable NSZone *)zone {
    APDrawPathModel *newModel = [[[self class] alloc] init];
    newModel.lineWidth = self.lineWidth;
    newModel.shapeType = self.shapeType;
    newModel.pointList = [self. pointList copy];
    return newModel;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [self copyWithZone:zone];
}
@end
