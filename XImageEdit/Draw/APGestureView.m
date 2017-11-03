//
//  APPanView.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/8.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APGestureView.h"

@interface APGestureView()


@end


@implementation APGestureView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initGesture];
}

- (APGestureView *)init {
    if (self = [super init]) {
        [self initGesture];
    }
    return self;
}

- (void)initGesture {
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panGr = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGr];
    panGr.maximumNumberOfTouches = 1;
    
    UIPanGestureRecognizer *panGr2 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture22223:)];
    [self addGestureRecognizer:panGr2];
    panGr2.minimumNumberOfTouches = 2;
    
    UIPinchGestureRecognizer *pinchGr = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(hangdlePinchGesture:)];
    [self addGestureRecognizer:pinchGr];
    
    UIRotationGestureRecognizer *rotationGr = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(handleRotation:)];
    [self addGestureRecognizer:rotationGr];
}

#pragma mark - gesture
//单指pan
- (void)handlePanGesture:(UIPanGestureRecognizer *)gr {
    CGPoint point = [gr locationInView:self];
    CGRect rect = self.bounds;
    if (CGRectContainsPoint(rect, point)) {
        if (self.panDrawGRChanged) {
            self.panDrawGRChanged(gr.state, point);
        }
    }
}

- (void)handlePanGesture22223:(UIPanGestureRecognizer *)gr {
    CGPoint point = [gr locationInView:self];
    if (self.panGRChanged) {
        self.panGRChanged(gr.state, point, gr.numberOfTouches);
    }
}

- (void)hangdlePinchGesture:(UIPinchGestureRecognizer *)gr {
    if (self.pinchGRChanged) {
        self.pinchGRChanged(gr.state, gr.scale, gr.numberOfTouches);
    }
}

- (void)handleRotation:(UIRotationGestureRecognizer *)gr {
    if (self.rotationGRChanged) {
        self.rotationGRChanged(gr.state, gr.rotation);
    }
}
@end
