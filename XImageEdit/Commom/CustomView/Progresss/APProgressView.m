//
//  APProgressView.m
//  AreoxPlay
//
//  Created by mifit on 2017/10/26.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APProgressView.h"
#import "SVProgressHUD.h"

@implementation APProgressView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)show {
    [SVProgressHUD show];
}

- (void)hide {
    [SVProgressHUD dismiss];
}
@end
