//
//  XMDrawView.h
//  AreoxPlay
//
//  Created by mifit on 2017/9/20.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMDrawView : UIImageView
@property (nonatomic, assign) CGFloat scaleInImage;
@property (nonatomic, strong) NSArray *textList;
- (UIImage *)imgFromView;
@end
