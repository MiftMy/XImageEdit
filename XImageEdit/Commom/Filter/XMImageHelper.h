//
//  XMImageHelper.h
//  AreoxPlay
//
//  Created by mifit on 2016/12/23.
//  Copyright © 2016年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMImageHelper : NSObject
+ (unsigned char *) convertUIImageToBitmapRGBA8:(UIImage *) image;

+ (UIImage *) convertBitmapRGBA8ToUIImage:(unsigned char *) buffer
                                withWidth:(int) width
                               withHeight:(int) height;
@end
