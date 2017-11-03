//
//  APImageDrawboard.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/8.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APShowDrawView.h"
#import "APDrawManager.h"
#import "APDrawModel.h"
#import "UIColor_XMColor.h"

@implementation APShowDrawView

- (void)addStep:(APDrawModel *)model {
    if (self.stepList.count > _activeStep) {
        NSInteger len = self.stepList.count-_activeStep;
        NSRange range = NSMakeRange(_activeStep, len);
        [self.stepList removeObjectsInRange:range];
    }
    [self.stepList addObject:model];
    _activeStep++;
}

- (NSMutableArray *)stepList {
    if (!_stepList) {
        _stepList = [NSMutableArray array];
    }
    return _stepList;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    for (NSInteger indx = 0; indx < self.activeStep; indx++) {
        APDrawModel *model = self.stepList[indx];
        UIBezierPath *path = [APDrawManager pathFromModel:model.pathModel];
        if (model.isEraser) {
            [[UIColor clearColor]set];
            [path strokeWithBlendMode:kCGBlendModeClear alpha:1];
        } else {
            [[UIColor colorWithHexString:model.strokeColor]set];
            [path strokeWithBlendMode:kCGBlendModeNormal alpha:1];
        }
        [path stroke];
    }
}
@end
